//
//  NFRecordTransaction.m
//  NFRecord
//
//  Created by Andrew Williams on 27/01/2015.
//  Copyright (c) 2015 NextFaze. All rights reserved.
//

#import "NFRecordTransaction.h"
#import "NFRecordConfig.h"

static NSMutableDictionary *transactions = nil;

@interface NFRecordTransaction ()
@property (nonatomic, assign) NSUInteger level;
@end

@implementation NFRecordTransaction

+ (void)initialize {
    if(transactions == nil) {
        transactions = [NSMutableDictionary dictionary];
    }
}

+ (NSString *)transactionKey {
    NSString *threadId = [[NSThread currentThread] description];
    return threadId;
}

// return the transaction object for the current thread.
// returns nil if there is no current transaction
+ (NFRecordTransaction *)currentTransaction {
    NSString *key = [self transactionKey];
    @synchronized(self) {
        NFRecordTransaction *transaction = [transactions valueForKey:key];
        return transaction;
    }
}

// create transaction for the current thread.
// returns existing transaction if it already exists
+ (NFRecordTransaction *)startTransaction {
    NSString *key = [self transactionKey];
    NFRecordTransaction *transaction = [self currentTransaction];
    
    if(transaction == nil) {
        // create new transaction
        @synchronized(self) {
            NFRecordTransaction *transaction = [[NFRecordTransaction alloc] init];
            [transactions setValue:transaction forKey:key];
        }
    }
    transaction.level++;
    
    return transaction;
}

+ (void)endTransaction {
    @synchronized(self) {
        NFRecordTransaction *transaction = [self currentTransaction];
        transaction.level--;
        
        if(transaction.level == 0) {
            // end transaction when all nested transactions have exited
            [transaction commit];
            
            NSString *key = [self transactionKey];
            [transactions removeObjectForKey:key];
        }
    }
}

#pragma mark -

- (id)init {
    self = [super init];
    if(self) {
        _records = [NSArray array];
    }
    return self;
}

- (void)commit {
    // TODO: this code will not behave as expected if a model overrides the +database method.
    // ideally this would allow saving to multiple databases.
    // (save method of record could add database details to the transaction's list of records to be saved, e.g. via a NFRecordTransactionSave object to encapsulate this).
    [[[NFRecordConfig sharedInstance] database] saveItems:self.records];
}

@end
