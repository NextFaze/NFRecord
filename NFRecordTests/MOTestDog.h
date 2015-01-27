//
//  MOTestDog.h
//  NFRecord
//
//  Created by Andrew Williams on 27/01/2015.
//  Copyright (c) 2015 NextFaze. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MOTestDog : NSManagedObject

@property (nonatomic, retain) NSString * breed;
@property (nonatomic, retain) NSString * raceName;
@property (nonatomic, retain) NSNumber * recordId;

@end
