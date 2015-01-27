//
//  NFRecordConfig.h
//  NFRecord
//
//  Created by Andrew Williams on 27/01/2015.
//  Copyright (c) 2015 NextFaze. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NFRecordDatabase.h"

@interface NFRecordConfig : NSObject

@property (nonatomic, strong) NFRecordDatabase *database;

+ (NFRecordConfig *)sharedInstance;

@end
