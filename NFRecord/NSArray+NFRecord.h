//
//  NSArray+NFRecord.h
//  NFRecord
//
//  Created by Andrew Williams on 10/10/2014.
//  Copyright (c) 2014 NextFaze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (NFRecord)

- (NSDictionary *)nfrecordById;
- (NSSet *)nfrecordIdSet;
- (BOOL)nfrecordContainsId:(NSNumber *)recordId;

@end
