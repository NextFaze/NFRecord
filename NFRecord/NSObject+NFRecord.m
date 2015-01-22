//
//  NSObject+NFRecord.m
//  NFRecord
//
//  Created by Andrew Williams on 22/01/2015.
//  Copyright (c) 2015 NextFaze. All rights reserved.
//

#import "NSObject+NFRecord.h"

@implementation NSObject (NFRecord)

- (NSString *)nfrecordStringValue {
    if([self respondsToSelector:@selector(stringValue)]) {
        return [self performSelector:@selector(stringValue)];
    }
    else {
        return [self description];
    }
}

@end
