//
//  NFRecordFetchRequest.m
//  NFRecord
//
//  Created by Andrew Williams on 11/10/2014.
//  Copyright (c) 2014 NextFaze. All rights reserved.
//

#import "NFRecordFetchRequest.h"

@implementation NFRecordFetchRequest

- (id)init {
    self = [super init];
    if(self) {
        self.notify = YES;
        self.convert = YES;
    }
    return self;
}

@end
