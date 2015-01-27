//
//  NFRecordDatabase.h
//  NFRecord
//
//  Created by Andrew Williams on 22/01/2015.
//  Copyright (c) 2015 NextFaze. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NFRecordBase.h"
#import "NFRecordFetchRequest.h"

#define NFRecordDatabaseSaveNotification @"NFRecordDatabaseSaveNotification"
#define NFRecordDatabaseReadNotification @"NFRecordDatabaseReadNotification"

typedef void(^NFRecordDatabaseRequestBlock)(NFRecordFetchRequest *request);

@interface NFRecordDatabase : NSObject

@property (readonly, atomic) NSManagedObjectContext *context;
@property (readonly, assign) BOOL enabled;

- (id)initWithDataModelName:(NSString *)name bundle:(NSBundle *)bundle;

- (void)performBlockWithoutNotifications:(void (^)())block;
- (void)performAndWait:(BOOL)wait notify:(BOOL)notify block:(void (^)())block;

- (void)saveItems:(NSArray *)items;
- (void)saveItems:(NSArray *)items name:(NSString *)itemType;

- (NSArray *)readItems:(NSString *)entityName;
- (NSArray *)readItems:(NSString *)entityName predicate:(NSPredicate *)predicate;
- (NSArray *)readItems:(NSString *)entityName requestBlock:(NFRecordDatabaseRequestBlock)block;

- (NSSet *)readrecordIds:(NSString *)entityName predicate:(NSPredicate *)predicate;
- (NSSet *)readItem:(NSString *)entityName property:(NSString *)property predicate:(NSPredicate *)predicate;

- (void)deleteItems:(NSArray *)items;
- (void)deleteItems:(NSString *)entityName predicate:(NSPredicate *)predicate;
- (void)deleteAll:(NSString *)entityName;

- (id)maximum:(NSString *)key entityName:(NSString *)entityName;

@end
