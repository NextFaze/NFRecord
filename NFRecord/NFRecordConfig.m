//
//  NFRecordConfig.m
//  NFRecord
//
//  Created by Andrew Williams on 27/01/2015.
//  Copyright (c) 2015 NextFaze. All rights reserved.
//

#import "NFRecordConfig.h"

static NFRecordConfig *instance = nil;

@implementation NFRecordConfig

+ (void)initialize {
    if(instance == nil) {
        instance = [[NFRecordConfig alloc] initPrivate];
    }
}

+ (NFRecordConfig *)sharedInstance {
    return instance;
}

#pragma mark -

- (id)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"use the sharedInstance method" userInfo:nil];
    return nil;
}

- (id)initPrivate {
    return [super init];
}

@end
