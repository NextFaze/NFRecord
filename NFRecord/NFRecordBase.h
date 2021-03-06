//
//  NFRecordBase.h
//  NFRecord
//
//  Created by Andrew Williams on 22/01/2015.
//  Copyright (c) 2015 NextFaze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NFRecordBase : NSObject

- (id)initWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, strong) NSNumber *recordId;
@property (nonatomic, strong) NSDictionary *attributes;

@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSDate *updatedAt;

+ (void)applyAttributes:(NSDictionary *)dict to:(NSObject *)target;
+ (void)transaction:(void (^)())block;

- (void)save;

@end
