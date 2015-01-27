//
//  NFRecordTransaction.h
//  NFRecord
//
//  Created by Andrew Williams on 27/01/2015.
//  Copyright (c) 2015 NextFaze. All rights reserved.
//

#import "NFRecordBase.h"

@interface NFRecordTransaction : NFRecordBase

@property (nonatomic, strong) NSArray *records;

+ (NFRecordTransaction *)currentTransaction;
+ (NFRecordTransaction *)startTransaction;
+ (void)endTransaction;

@end
