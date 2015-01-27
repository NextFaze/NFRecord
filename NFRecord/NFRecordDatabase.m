//
//  NFRecordDatabase.m
//  NFRecord
//
//  Created by Andrew Williams on 22/01/2015.
//  Copyright (c) 2015 NextFaze. All rights reserved.
//

#import "NFRecordDatabase.h"
#import "NFRecordNotification.h"
#import "NFRecordProperty.h"

#define NFRecordBasePrimaryKey @"recordId"

@interface NFRecordDatabase ()
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (assign, nonatomic) BOOL sendNotifications;
@property (strong, nonatomic) NSDictionary *primaryKeyPredicates;
@property (nonatomic, strong) NSString *dataModelName;
@property (nonatomic, strong) NSBundle *bundle;
@end

@implementation NFRecordDatabase

- (id)initWithDataModelName:(NSString *)name bundle:(NSBundle *)bundle {
    self = [super init];
    if(self) {
        // create context
        NFLog(@"database initialising");
        _dataModelName = name;
        _bundle = bundle;
        _context = [self managedObjectContext];
        _sendNotifications = YES;
    }
    return self;
}

#pragma mark - Utility

- (NSString *)entityNameForRecordClass:(Class)klass {
    if(klass == nil)
        return nil;

    // TODO: allow custom class name -> entity mapping
    NSString *entityName = NSStringFromClass(klass);
    return entityName;
}

- (Class)recordClassForEntityName:(NSString *)entityName {
    // TODO: allow custom entity -> class name mapping
    return NSClassFromString(entityName);
}

- (void)sendNotification:(NSString *)name object:(id)object userInfo:(NSDictionary *)userInfo {
    if(self.sendNotifications)
        [NFRecordNotification sendNotification:name object:object userInfo:userInfo];
}

// caches primary key predicates, as they are slow to create
- (NSPredicate *)primaryKeyPredicate:(NSString *)primaryKey {
    NSPredicate *predicate = self.primaryKeyPredicates[primaryKey];
    if(predicate == nil) {
        // create primary key predicate
        NSString *predicateStr = [NSString stringWithFormat:@"%@ = $ITEM_ID", primaryKey];
        predicate = [NSPredicate predicateWithFormat:predicateStr];
        
        // cache it
        NSMutableDictionary *dict = [self.primaryKeyPredicates mutableCopy];
        dict[primaryKey] = predicate;
        self.primaryKeyPredicates = dict;
    }
    return predicate;
}

- (NSManagedObjectModel *)findOrCreate:(NSString *)entityName primaryKey:(NSString *)key recordId:(NSObject *)recordId {
    NSPredicate *primaryKeyPredicate = [self primaryKeyPredicate:key];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.context];
    NSError *error = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    request.predicate = [primaryKeyPredicate predicateWithSubstitutionVariables:@{ @"ITEM_ID" : recordId }];
    request.fetchLimit = 1;
    
    NSManagedObjectModel *mo = [[self.context executeFetchRequest:request error:&error] firstObject];
    if(mo == nil) {
        mo = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.context];
    }
    return mo;
}

// create map of existing items in the database by key
// e.g. given params [array(Record), @"Listing"], it returns a map of recordId -> Record items referenced by the items
- (NSMutableDictionary *)objectMap:(NSArray *)items entityName:(NSString *)entityName {
    NSSet *relatedrecordIds = [items nfrecordIdSet];
    NSPredicate *predicate = nil;

    if([relatedrecordIds count] == 0) {
        return [NSMutableDictionary dictionary];
    } else if([relatedrecordIds count] == 1) {
        predicate = [NSPredicate predicateWithFormat:@"recordId = %@", [[relatedrecordIds allObjects] firstObject]];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"recordId IN %%@", relatedrecordIds];
    }

    // read related items
    NSArray *relatedItems = [self readItems:entityName requestBlock:^(NFRecordFetchRequest *request) {
        request.predicate = predicate;
        request.notify = NO;   // do not send read notifications
        request.convert = NO;  // do not convert to NFRecordBase
    }];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for(NSManagedObjectModel *mo in relatedItems) {
        id value = [mo valueForKey:@"recordId"];
        if(value)
            [dict setObject:mo forKey:value];
    }
    return dict;
}

- (id)newItem:(NSString *)entityName {
    NFLog(@"entity name: %@, context: %@", entityName, self.context);
    return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.context];
}

#pragma mark - Public API

- (void)performBlockWithoutNotifications:(void (^)())block {
    [self performAndWait:NO notify:NO block:block];
}

- (void)performAndWait:(BOOL)wait notify:(BOOL)notify block:(void (^)())block {
    if(wait) {
        [self.context performBlockAndWait:^{
            self.sendNotifications = notify;
            if(block) block();
            self.sendNotifications = YES;
        }];
    } else {
        [self.context performBlock:^{
            self.sendNotifications = notify;
            if(block) block();
            self.sendNotifications = YES;
        }];
    }
}

- (id)maximum:(NSString *)key entityName:(NSString *)entityName {
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:key];
    NSExpression *maxIdExpression = [NSExpression expressionForFunction:@"max:" arguments:@[keyPathExpression]];
    
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    [expressionDescription setName:key];
    [expressionDescription setExpression:maxIdExpression];
    [expressionDescription setExpressionResultType:NSDecimalAttributeType];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.context];
    request.propertiesToFetch = @[expressionDescription];
    request.resultType = NSDictionaryResultType;
    
    // Execute the fetch.
    NSError *error = nil;
    NSArray *objects = [self.context executeFetchRequest:request error:&error];
    id max = [[objects firstObject] valueForKey:key];
    
    return max;
}

// save items, a list of NFRecordBases, to the database.
- (void)saveItems:(NSArray *)items name:(NSString *)entityName {
    //Class moItemClass = NSClassFromString([NSString stringWithFormat:@"MO%@", entityName]);
    //NSDictionary *moProperties = [NFRecordProperty propertiesDictionaryFromClass:moItemClass];
    NSMutableDictionary *itemMap = [self objectMap:items entityName:entityName];
    NSError *error = nil;

    NFLog(@"started save %@", entityName);

    for(NFRecordBase *item in items) {
        // try to find existing item by id, else create new item
        NSObject<NSCopying> *recordId = item.recordId;
        //NSManagedObjectModel *moItem = [self findOrCreate:entityName primaryKey:item.primaryKey recordId:recordId];
        NSManagedObjectModel *moItem = recordId ? [itemMap objectForKey:recordId] : nil;
        if(moItem == nil) {
            moItem = [self newItem:entityName];

            if(recordId != nil)
                [itemMap setObject:moItem forKey:recordId];
        }

        // merge data into database item
        [NFRecordBase merge:item into:moItem];
    }

    error = nil;
    [self.context save:&error];
    if(error) {
        NFLog(@"error: %@", error);
    }
    else {
        NFLog(@"saved %lu %@ items to database", (unsigned long)items.count, [entityName lowercaseString]);
        [self sendNotification:NFRecordDatabaseSaveNotification object:entityName
                      userInfo:@{ @"entityName": entityName, @"items": items, @"method" : @"update" }];
    }
    //NFLog(@"save completed in %f seconds", -[startDate timeIntervalSinceNow]);
}

- (void)saveItems:(NSArray *)items {
    NSString *entityName = [self entityNameForRecordClass:[[items firstObject] class]];
    [self saveItems:items name:entityName];
}

// read items from database.
// returns array of NFRecordFetchRequest items
- (NSArray *)readItems:(NSString *)entityName requestBlock:(NFRecordDatabaseRequestBlock)block {
    NSManagedObjectContext *context = self.context;
    NSError *error = nil;
    NSString *className = entityName;
    Class recordClass = NSClassFromString(className);
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:entityName inManagedObjectContext:context];
    NSArray *items = nil;
    
    NFRecordFetchRequest *request = [[NFRecordFetchRequest alloc] init];
    request.entity = entityDescription;
    if(block)
        block(request);
    
    NSArray *moItems = [context executeFetchRequest:request error:&error];
    
    if(error) {
        NFLog(@"error: %@", error);
    }
    
    if(request.convert) {
        // convert database objects to NFRecordBase objects
        NSMutableArray *records = [NSMutableArray array];
        for(NSManagedObjectModel *moItem in moItems) {
            NFRecordBase *item = [[recordClass alloc] init];
            if(item == nil) continue;

            [NFRecordBase merge:moItem into:item];
            [records addObject:item];
        }
        items = records;
    }
    else {
        // do not convert
        items = moItems;
    }
    
    NFLog(@"read %lu %@ items from database", (unsigned long)items.count, [entityName lowercaseString]);
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    userInfo[@"entityName"] = entityName;
    userInfo[@"items"] = items;
    userInfo[@"request"] = request;
    userInfo[@"items"] = items;
    
    if(request.context)
        userInfo[@"context"] = request.context;
    
    if(request.notify) {
        [self sendNotification:NFRecordDatabaseReadNotification
                        object:entityName
                      userInfo:userInfo];
    }
    
    //NFLog(@"read completed in %f seconds", -[startDate timeIntervalSinceNow]);
    return items;
}

- (NSArray *)readItems:(NSString *)entityName predicate:(NSPredicate *)predicate {
    return [self readItems:entityName requestBlock:^(NSFetchRequest *request) {
        request.predicate = predicate;
    }];
}

- (NSArray *)readItems:(NSString *)entityName {
    return [self readItems:entityName predicate:nil];
}

- (NSSet *)readrecordIds:(NSString *)entityName predicate:(NSPredicate *)predicate {
    return [self readItem:entityName property:@"recordId" predicate:predicate];
}

- (NSSet *)readItem:(NSString *)entityName property:(NSString *)property predicate:(NSPredicate *)predicate {
    
    NSArray *items = [self readItems:entityName requestBlock:^(NFRecordFetchRequest *request) {
        request.predicate = predicate;
        request.propertiesToFetch = @[property];
        request.returnsDistinctResults = YES;
        request.resultType = NSDictionaryResultType;  // needed for distinct to work
        request.convert = NO;
    }];
    NSMutableSet *idSet = [NSMutableSet setWithCapacity:items.count];
    for(NSDictionary *item in items) {
        id key = [item valueForKey:property];
        if(key)
            [idSet addObject:key];
    }
    return idSet;
}

// http://stackoverflow.com/questions/1383598/core-data-quickest-way-to-delete-all-instances-of-an-entity
- (void)deleteItems:(NSString *)entityName predicate:(NSPredicate *)predicate
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:entityName];
    fetchRequest.predicate = predicate;
    fetchRequest.includesPropertyValues = NO; // only fetch the managedObjectID
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *object in fetchedObjects)
    {
        [self.context deleteObject:object];
    }
    
    error = nil;
    [self.context save:&error];
    
    NFLog(@"deleted %lu %@ items from database", (unsigned long)fetchedObjects.count, [entityName lowercaseString]);
    [self sendNotification:NFRecordDatabaseSaveNotification
                    object:entityName userInfo: @{ @"entityName": entityName, @"method" : @"destroy" }];
}

// http://stackoverflow.com/questions/1383598/core-data-quickest-way-to-delete-all-instances-of-an-entity
- (void)deleteAll:(NSString *)entityName
{
    [self deleteItems:entityName predicate:nil];
}

- (void)deleteItems:(NSArray *)items {
    NSString *entityName = [self entityNameForRecordClass:[[items firstObject] class]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"recordId IN %%@", [items nfrecordIdSet]];

    [self deleteItems:entityName predicate:predicate];
}

#pragma mark - Core Data stack

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [self.bundle URLForResource:self.dataModelName withExtension:@"momd"];
    if(modelURL == nil) {
        // model not found
        NFLog(@"model file not found: %@", self.dataModelName);
        abort();
    }
    NFLog(@"model url: %@", modelURL);
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSString *storeFilename = [NSString stringWithFormat:@"%@.sqlite", self.dataModelName];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:storeFilename];
    NFLog(@"store url: %@", storeURL);
    NSError *error = nil;
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NFLog(@"error setting up persistent store coordinator: %@", error);
        // blow away sqlite file
        NFLog(@"blowing away database");
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        
        // retry
        error = nil;
        NFLog(@"recreating database");
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            NFLog(@"fail 2: persistent store setup failed again, disabling database");
            _enabled = NO;
        }
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns a managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    // private queue: Specifies that the context will be associated with a private dispatch queue.
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [context setPersistentStoreCoordinator:coordinator];
    return context;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NFLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
