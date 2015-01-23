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

    self.updatedAt = [NSDate date];
    NSArray *dictKeys = [dict allKeys];
    for(NFRecordProperty *property in [NFRecordProperty propertiesFromClass:[self class]]) {
        NSString *name = property.name;
        NSString *underscoredName = [name nfrecordUnderscore];
        NSString *capitalizedName = [name nfrecordCapitalize];
        id value = nil;
        
        for(NSString *key in @[name, underscoredName, capitalizedName]) {
            if([dictKeys containsObject:key]) {
                value = dict[key];
                break;
            }
        }
        //NFLog(@"%@ -> %@", name, underscoredName);

        if([value isKindOfClass:[NSDictionary class]] && [property.valueClass isSubclassOfClass:[NFRecordBase class]]) {
            NFRecordBase *target = [self valueForKey:name];
            target.attributes = value;
        }
        else {
            // skip read-only properties on to object
            if(property.readonly)
                continue;

            // type casting
            value = [NFRecordBase castValue:value toClass:property.valueClass];

            //BOOL isNull = !value || [value isKindOfClass:[NSNull class]];
            // apply value
            [self setValue:value forKey:name];
        }
    }
}

- (NSDictionary *)attributes {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for(NFRecordProperty *property in [NFRecordProperty propertiesFromClass:[self class]]) {
        NSString *key = [property.name nfrecordUnderscore];  // controversial!
        if([key isEqualToString:@"attributes"])
            continue;
        
        id value = [self valueForKey:property.name];
        [dict setValue:value forKey:key];
    }
    return dict;
}

// merge property values from other into this object.
// values in this object are overwritten with non-nil values from other.
- (void)merge:(NSObject *)other {
    [NFRecordBase merge:other into:self];
}

+ (void)merge:(NSObject *)from into:(NSObject *)to {
    // skip nil objects
    if(to == nil || from == nil)
        return;
    
    NSArray *toProperties = [NFRecordProperty propertiesFromClass:[to class]];
    NSArray *fromProperties = [NFRecordProperty propertiesFromClass:[from class]];
    
    // iterate to-object properties
    for(NFRecordProperty *toProperty in toProperties) {
        NSString *name = toProperty.name;
        NFRecordProperty *fromProperty = nil;
        BOOL toNFRecord = [toProperty.valueClass isSubclassOfClass:[NFRecordBase class]];
        
        // skip read-only properties on to object (unless merge into NFRecordBase)
        if(toProperty.readonly && !toNFRecord)
            continue;
        
        for(NFRecordProperty *prop in fromProperties) {
            if([prop.name isEqualToString:name]) {
                fromProperty = prop;
                break;
            }
        }
        
        // skip if the from object does not have the corresponding property
        if(fromProperty == nil)
            continue;
        
        // skip if the from value is nil
        id fromValue = [from valueForKey:name];
        if(fromValue == nil || [fromValue isKindOfClass:[NSNull class]])
            continue;
        
        //LOG(@"merge %@.%@ %@", [from class], name, fromValue);
        
        if(toNFRecord) {
            // recursive merge into NFRecordBase
            NFRecordBase *toValue = [to valueForKey:name];
            [toValue merge:fromValue];
        }
        else {
            // assign value
            NSObject *toValue = [self castValue:fromValue toClass:toProperty.valueClass];
            [to setValue:toValue forKey:name];
        }
    }
}

#pragma mark - Private

+ (NSObject *)castValue:(NSObject *)value toClass:(Class)toClass {
    if(value == nil || [value isKindOfClass:[NSNull class]])
        return nil;

    if([value isKindOfClass:toClass])
        return value;

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

    return value;
}

@end
