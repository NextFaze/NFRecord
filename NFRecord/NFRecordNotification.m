//
//  NFRecordNotification.m
//  NFRecord
//
//  Created by Andrew Williams on 9/10/2014.
//  Copyright (c) 2014 NextFaze. All rights reserved.
//

#import "NFRecordNotification.h"

@implementation NFRecordNotification

+ (void)addObserver:(id<NFRecordNotificationObserver>)observer forName:(NSString *)name {
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:@selector(handleNotification:) name:name object:nil];
}

+ (void)removeObserver:(id<NFRecordNotificationObserver>)observer {
    [[NSNotificationCenter defaultCenter] removeObserver:observer];
}

+ (void)sendNotification:(NSString *)name {
    [self sendNotification:name object:nil userInfo:nil];
}

+ (void)sendNotification:(NSString *)name object:(id)object userInfo:(NSDictionary *)userInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:name object:object userInfo:userInfo];
    });
}

@end
