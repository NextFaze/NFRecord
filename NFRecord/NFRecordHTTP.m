//
//  NFRecordHTTP.m
//  NFRecord
//
//  Created by Andrew Williams on 23/01/2015.
//  Copyright (c) 2015 NextFaze. All rights reserved.
//

#import "NFRecordHTTP.h"

@implementation NFRecordHTTP

+ (NSDictionary *)flattenParameters:(NSDictionary *)dict {
    return [self flattenParameters:dict keyPath:nil];
}

// flatten dictionary to a list of rails-style url parameters.
// { 'foo' => { 'bar' => 1 } } becomes foo[bar]=1
+ (NSDictionary *)flattenParameters:(NSDictionary *)dict keyPath:(NSArray *)keyPath {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    for(NSString *key in [dict allKeys]) {
        id value = [dict valueForKey:key];
        NSArray *newKeyPath = keyPath ? [keyPath arrayByAddingObject:key] : @[key];
        
        if([value isKindOfClass:[NSDictionary class]]) {
            NSDictionary *subDict = [self flattenParameters:value keyPath:newKeyPath];
            [params addEntriesFromDictionary:subDict];
        }
        else {
            // construct encoded key
            NSString *encodedKey = nil;
            for(NSString *k in newKeyPath) {
                NSString *kenc = [k nfrecordUrlEncodeUsingEncoding:NSUTF8StringEncoding];
                if(encodedKey == nil) {
                    encodedKey = kenc;
                } else {
                    encodedKey = [NSString stringWithFormat:@"%@[%@]", encodedKey, kenc];
                }
            }
            [params setValue:value forKey:encodedKey];
        }
    }
    return params;
}

+ (NSString *)stringWithEncodedQueryParameters:(NSDictionary *)parameters
{
    NSMutableArray *parameterPairs = [NSMutableArray array];
    NSDictionary *params = [self flattenParameters:parameters];
    
    for (NSString *key in [params allKeys]) {
        id value = [params valueForKey:key];
        
        // support for arrays of parameters, e.g. key=value1, key=value2
        NSArray *valueList = nil;
        if([value isKindOfClass:[NSArray class]]) {
            valueList = value;
        } else {
            valueList = @[value];
        }

        for(value in valueList) {
            if(![value isKindOfClass:[NSString class]]) {
                value = [value description];
            }
            NSString *pair = [NSString stringWithFormat:@"%@=%@",
                              key,  // key is already url encoded by flattenParameters
                              [value nfrecordUrlEncodeUsingEncoding:NSUTF8StringEncoding]];
            [parameterPairs addObject:pair];
        }
    }
    return [parameterPairs componentsJoinedByString:@"&"];
}

@end
