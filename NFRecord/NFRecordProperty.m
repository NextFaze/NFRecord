//
//  NFRecordProperty.m
//  NFRecord
//
//  Created by Andrew Williams on 20/02/2014.
//  Copyright (c) 2014 NextFaze SD. All rights reserved.
//
// inspired by code from boliva
// (http://stackoverflow.com/questions/754824/get-an-object-properties-list-in-objective-c)

#import "NFRecordProperty.h"
#import <objc/runtime.h>

static NSDictionary *objectProperties = nil;  // map of class name to property data array

// redefine properties as read/write internally
@interface NFRecordProperty ()
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NFRecordPropertyDataType valueType;
@property (nonatomic, assign) int pointerLevel;
@property (nonatomic, assign) Class valueClass;
@end

@implementation NFRecordProperty

- (BOOL)isPointer {
    return self.pointerLevel > 0;
}

+ (NSDictionary *)propertiesDictionaryFromClass:(Class)klass {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for(NFRecordProperty *property in [self propertiesFromClass:klass]) {
        [dict setValue:property forKey:property.name];
    }
    return dict;
}

// retrieves and caches property list for the given class
+ (NSArray *)propertiesFromClass:(Class)klass {
    NSArray *properties = nil;
    if(klass == nil) return nil;
    
    @synchronized(self) {
        NSString *key = NSStringFromClass(klass);
        properties = [objectProperties valueForKey:key];
        if(properties == nil) {
            //NFLog(@"getting properties for %@", key);
            // load properties for this class, and save in dictionary
            NSMutableDictionary *dict = [objectProperties mutableCopy];
            if(dict == nil)
                dict = [NSMutableDictionary dictionary];
            
            properties = dict[key] = [self findPropertiesFromClass:klass];
            objectProperties = dict;
        }
    }
    return properties;
}

+ (NSArray *)findPropertiesFromClass:(Class)klass {
    NSMutableArray *list = [NSMutableArray array];
    unsigned int outCount, i;
    
    while(klass != [NSObject class]) {
        objc_property_t *properties = class_copyPropertyList(klass, &outCount);
        for(i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            const char *propName = property_getName(property);
            if(propName) {
                NSArray *attributes = [NFRecordProperty attributesOfProperty:property];
                NSString *propertyName = [NSString stringWithUTF8String:propName];
                
                NFRecordProperty *property = [[NFRecordProperty alloc] init];
                property.name = propertyName;
                property.attributes = attributes;
                
                //NFLog(@"property: %@", property);
                
                [list addObject:property];
            }
        }
        free(properties);
        
        klass = [klass superclass];
    }
    return list;
}

- (void)setAttributes:(NSArray *)attributes {
    NSString *propertyType = nil;
    _attributes = attributes;
    
    for(NSString *attribute in attributes) {
        if([attribute hasPrefix:@"T"] && !propertyType) {
            propertyType = attribute;
        }
        else if([attribute isEqualToString:@"R"]) {
            _readonly = YES;
        }
        else if([attribute isEqualToString:@"W"]) {
            _weak = YES;
        }
        else if([attribute isEqualToString:@"N"]) {
            _nonatomic = YES;
        }
        else if([attribute isEqualToString:@"C"]) {
            _copy = YES;
        }
        else if([attribute isEqualToString:@"D"]) {
            _dynamic = YES;
        }
        else if([attribute isEqualToString:@"&"]) {
            _strong = YES;
        }
    }
    
    [self processPropertyType:propertyType];
}

- (NSString *)description {
    NSMutableArray *modifiers = [NSMutableArray array];
    
    [modifiers addObject:self.nonatomic ? @"nonatomic" : @"atomic"];
    if(self.weak) [modifiers addObject:@"weak"];
    if(self.copy) [modifiers addObject:@"copy"];
    if(self.readonly) [modifiers addObject:@"readonly"];
    if(self.strong) [modifiers addObject:@"strong"];
    if(self.dynamic) [modifiers addObject:@"dynamic"];
    
    return [NSString stringWithFormat:@"(%@) %@ %.*s%@ (class %@)",
            [modifiers componentsJoinedByString:@", "],
            [self dataTypeToString], self.pointerLevel, "***************", self.name,
            NSStringFromClass(self.valueClass)];
}

- (NSString *)dataTypeToString {
    switch(self.valueType) {
        case NFRecordPropertyDataTypeChar:
            return @"char";
        case NFRecordPropertyDataTypeUnsignedChar:
            return @"unsigned char";
        case NFRecordPropertyDataTypeInt:
            return @"int";
        case NFRecordPropertyDataTypeLong:
            return @"long";
        case NFRecordPropertyDataTypeObject:
            return self.valueClass ? NSStringFromClass(self.valueClass) : @"NSObject";
        case NFRecordPropertyDataTypeUnsignedInt:
            return @"unsigned int";
        case NFRecordPropertyDataTypeUnsignedLong:
            return @"unsigned long";
        case NFRecordPropertyDataTypeUnknown:
            return @"?";
        case NFRecordPropertyDataTypeLongLong:
            return @"long long";
        case NFRecordPropertyDataTypeUnsignedLongLong:
            return @"unsigned long long";
        case NFRecordPropertyDataTypeShort:
            return @"short";
        case NFRecordPropertyDataTypeUnsignedShort:
            return @"unsigned short";
        case NFRecordPropertyDataTypeBool:
            return @"BOOL";
    }
}

#pragma mark -

- (void)processPropertyType:(NSString *)propertyType {
    
    self.valueClass = [self propertyTypeClass:propertyType];
    
    if(self.valueClass) {
        // object, e.g. T@"NSString"
        self.valueType = NFRecordPropertyDataTypeObject;
        self.pointerLevel = 1;
    } else if([propertyType characterAtIndex:1] == '^') {
        // pointer, e.g. T^i
        self.pointerLevel = (int)[propertyType length] - 2;  // e.g T^^i == int **value;
        self.valueType = [self propertyDataType:propertyType];
    } else {
        // primitive, e.g. Ti
        self.valueType = [self propertyDataType:propertyType];
    }
    
    // special case T* = char *, T^* == char **
    if([propertyType hasSuffix:@"*"])
        self.pointerLevel++;
}

- (NFRecordPropertyDataType)propertyDataType:(NSString *)propertyType {
    unichar ptype = [propertyType characterAtIndex:[propertyType length] - 1];
    
    switch(ptype) {
        case 'i':
            return NFRecordPropertyDataTypeInt;
        case 'I':
            return NFRecordPropertyDataTypeUnsignedInt;
        case 's':
            return NFRecordPropertyDataTypeShort;
        case 'S':
            return NFRecordPropertyDataTypeUnsignedShort;
        case 'l':
            return NFRecordPropertyDataTypeLong;
        case 'L':
            return NFRecordPropertyDataTypeUnsignedLong;
        case 'B':  // boolean, only returned by newer devices
            return NFRecordPropertyDataTypeBool;
        case 'c':
            return NFRecordPropertyDataTypeChar;
        case 'C':
            return NFRecordPropertyDataTypeUnsignedChar;
        case '*':
            return NFRecordPropertyDataTypeChar;  // char *
        case 'Q':
            return NFRecordPropertyDataTypeUnsignedLongLong;
        case 'q':
            return NFRecordPropertyDataTypeLongLong;
        default:
            NFLog(@"unhandled property type: %c", ptype);
            return NFRecordPropertyDataTypeUnknown;
    }
}

- (Class)propertyTypeClass:(NSString *)propertyType {
    if([propertyType hasPrefix:@"T@\""]) {
        NSRange range = NSMakeRange(3, [propertyType length] - 4);
        NSString *className = [propertyType substringWithRange:range];
        return NSClassFromString(className);
    }
    return nil;
}

+ (NSArray *)attributesOfProperty:(objc_property_t)property {
    const char * propAttr = property_getAttributes(property);
    NSString *propString = [NSString stringWithUTF8String:propAttr];
    NSArray *attrArray = [propString componentsSeparatedByString:@","];
    return attrArray;
}

@end
