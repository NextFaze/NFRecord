//
//  NSArray+NFRecord.m
//  NFRecord
//
//  Created by Andrew Williams on 10/10/2014.
//  Copyright (c) 2014 NextFaze. All rights reserved.
//

#import "NSArray+NFRecord.h"
#import "NFRecordBase.h"

@implementation NSArray (NFRecord)

- (NSDictionary *)nfrecordById {
    NSMutableDictionary *itemsById = [NSMutableDictionary dictionaryWithCapacity:self.count];

    for(NFRecordBase *item in self) {
        if(item.recordId)
            itemsById[item.recordId] = item;
    }
    return itemsById;
}

- (NSSet *)nfrecordIdSet {
    NSMutableSet *ids = [NSMutableSet setWithCapacity:self.count];

    for(NFRecordBase *item in self) {
        if(item.recordId)
            [ids addObject:item.recordId];
    }
    return ids;
}

- (BOOL)nfrecordContainsId:(NSNumber *)recordId {
    for(NFRecordBase *item in self) {
        if([item.recordId isEqual:recordId])
            return YES;
    }
    return NO;
}

@end
