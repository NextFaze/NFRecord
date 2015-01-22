//
//  NFRecordFetchRequest.h
//  NFRecord
//
//  Created by Andrew Williams on 11/10/2014.
//  Copyright (c) 2014 NextFaze. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NFRecordFetchRequest : NSFetchRequest

@property (nonatomic, strong) NSObject *context;
@property (nonatomic, assign) BOOL notify;
@property (nonatomic, assign) BOOL convert;

@end
