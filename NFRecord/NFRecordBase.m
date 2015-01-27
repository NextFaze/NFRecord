//
//  NFRecordBase.m
//  NFRecord
//
//  Created by Andrew Williams on 22/01/2015.
//  Copyright (c) 2015 NextFaze. All rights reserved.
//

#import "NFRecordBase.h"
#import "NFRecordProperty.h"

@implementation NFRecordBase

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    [self setAttributes:dict];
    return self;
}

#pragma mark -

- (void)setAttributes:(NSDictionary *)dict {
    if(dict == nil)
        return;
    
    if(![dict isKindOfClass:[NSDictionary class]]) {
        NSLog(@"When assigning attributes, you must pass a dictionary as an argument.");
#ifdef DEBUG
        abort();
#endif
        return;
    }
    
    NSMutableDictionary *attribs = [dict mutableCopy];
    if(attribs[@"id"])
        attribs[@"recordId"] = attribs[@"id"];
    
    NSArray *dictKeys = [attribs allKeys];
    for(NFRecordProperty *property in [NFRecordProperty propertiesFromClass:[self class]]) {
        NSString *name = property.name;
        NSString *underscoredName = [name nfrecordUnderscore];
        NSString *capitalizedName = [name nfrecordCapitalize];
        NSString *uppercasedName = [name uppercaseString];
        NSString *downcasedName = [name lowercaseString];
        id value = nil;
        BOOL foundValue = NO;

        for(NSString *key in @[name, underscoredName, capitalizedName, downcasedName, uppercasedName]) {
            if([dictKeys containsObject:key]) {
                value = attribs[key];
                foundValue = YES;
                break;
            }
        }
        if(!foundValue)
            continue;
        
        //NFLog(@"%@ -> %@", name, underscoredName);
        
        if([value isKindOfClass:[NSDictionary class]] && [property.valueClass isSubclassOfClass:[NFRecordBase class]]) {
            NFRecordBase *target = [self valueForKey:name];
            if(target == nil) {
                target = [[property.valueClass alloc] init];
                [self setValue:target forKey:name];
            }
            target.attributes = value;
        }
        else {
            // skip read-only properties on to object
            if(property.readonly)
                continue;
            
            // type casting
            value = [NFRecordBase castValue:value toProperty:property];
            
            //BOOL isNull = !value || [value isKindOfClass:[NSNull class]];
            // apply value
            [self setValue:value forKey:name];
        }
    }
    
    self.updatedAt = [NSDate date];
}

- (NSDictionary *)attributes {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for(NFRecordProperty *property in [NFRecordProperty propertiesFromClass:[self class]]) {
        NSString *key = [property.name nfrecordUnderscore];  // controversial!
        if([key isEqualToString:@"attributes"])
            continue;
        
        id value = [self valueForKey:property.name];

        // recursively get attributes for NFRecord objects
        if([value isKindOfClass:[NFRecordBase class]])
            value = [value attributes];
        
        [dict setValue:value forKey:key];
    }
    return dict;
}

#pragma mark - Private

+ (NSObject *)castValue:(NSObject *)value toProperty:(NFRecordProperty *)property {
    Class toClass = property.valueClass;
    
    if([value isKindOfClass:[NSNull class]])
        value = nil;
    
    if([value isKindOfClass:toClass])
        return value;
    
    if(value != nil) {
        // to class conversions
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if([toClass respondsToSelector:@selector(valueFromString:)]) {
            value = [toClass performSelector:@selector(valueFromString:) withObject:[value nfrecordStringValue]];;
        }
        else if([toClass respondsToSelector:@selector(nfrecordValueFromString:)]) {
            value = [toClass performSelector:@selector(nfrecordValueFromString:) withObject:[value nfrecordStringValue]];;
        }
#pragma clang diagnostic pop
        else if([toClass isEqual:[NSNumber class]]) {
            value = @([[value nfrecordStringValue] doubleValue]);
        }
        else if([toClass isEqual:[NSString class]]) {
            value = [value nfrecordStringValue];
        }
    }

    // property value type conversions
    if(property.valueType == NFRecordPropertyDataTypeBool) {
        if(value == nil || [value isKindOfClass:[NSNull class]]) {
            value = [NSNumber numberWithBool:NO];
        }
        else if([value respondsToSelector:@selector(boolValue)]) {
            value = @((BOOL)[value performSelector:@selector(boolValue)]);
        }
    }
    
    return value;
}

@end
