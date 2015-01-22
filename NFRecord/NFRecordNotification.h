//
//  NFRecordNotification.h
//  NFRecord
//
//  Created by Andrew Williams on 9/10/2014.
//  Copyright (c) 2014 NextFaze. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NFRecordNotificationObserver
- (void)handleNotification:(NSNotification *)notification;
@end

@interface NFRecordNotification : NSObject

+ (void)addObserver:(id<NFRecordNotificationObserver>)observer forName:(NSString *)name;
+ (void)removeObserver:(id<NFRecordNotificationObserver>)observer;

+ (void)sendNotification:(NSString *)name;
+ (void)sendNotification:(NSString *)name object:(id)object userInfo:(NSDictionary *)userInfo;

@end
