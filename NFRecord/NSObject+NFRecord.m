//
//  NSObject+NFRecord.m
//  NFRecord
//
//  Created by Andrew Williams on 22/01/2015.
//  Copyright (c) 2015 NextFaze. All rights reserved.
//

#import "NSObject+NFRecord.h"
#import "NFRecordProperty.h"
#import "NFRecordBase.h"

@implementation NSObject (NFRecord)

- (NSString *)nfrecordStringValue {
    if([self respondsToSelector:@selector(stringValue)]) {
        return [self performSelector:@selector(stringValue)];
    }
    else {
        return [self description];
    }
}

- (NSDictionary *)nfrecordAttributes {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for(NFRecordProperty *property in [NFRecordProperty propertiesFromClass:[self class]]) {
        NSString *key = [property.name nfrecordUnderscore];  // controversial!
        if([key isEqualToString:@"attributes"])
            continue;
        
        id value = [self valueForKey:property.name];

        // recursively get attributes for NFRecord objects
        if([value isKindOfClass:[NFRecordBase class]])
            value = [value nfrecordAttributes];
        
        [dict setValue:value forKey:key];
    }
    return dict;
}

@end
