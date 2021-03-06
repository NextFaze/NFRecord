//
//  NFTestDog.h
//  NFRecord
//
//  Created by Andrew Williams on 23/01/2015.
//  Copyright (c) 2015 NextFaze. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NFRecordBase.h"
#import "NFTestPerson.h"

@interface NFTestDog : NFRecordBase

@property (nonatomic, strong) NSString *breed;
@property (nonatomic, strong) NSNumber *age;
@property (nonatomic, strong) NSString *color;
@property (nonatomic, strong) NSString *raceName;

@property (nonatomic, strong) NFTestPerson *owner;

@property (nonatomic, assign) BOOL isHungry;

@end
