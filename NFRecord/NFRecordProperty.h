//
//  NFRecordProperty.h
//  NFRecord
//
//  Created by Andrew Williams on 20/02/2014.
//  Copyright (c) 2014 NextFaze SD. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum  {
    NFRecordPropertyValueTypeUnknown,
    NFRecordPropertyValueTypeObject,
    NFRecordPropertyValueTypePrimitive
} NFRecordPropertyValueType;

typedef enum {
    NFRecordPropertyDataTypeUnknown,
    NFRecordPropertyDataTypeInt,
    NFRecordPropertyDataTypeUnsignedInt,
    NFRecordPropertyDataTypeLong,
    NFRecordPropertyDataTypeLongLong,
    NFRecordPropertyDataTypeUnsignedLong,
    NFRecordPropertyDataTypeUnsignedLongLong,
    NFRecordPropertyDataTypeShort,
    NFRecordPropertyDataTypeUnsignedShort,
    NFRecordPropertyDataTypeChar,
    NFRecordPropertyDataTypeUnsignedChar,
    NFRecordPropertyDataTypeObject,
} NFRecordPropertyDataType;

@interface NFRecordProperty : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NFRecordPropertyDataType valueType;
@property (nonatomic, readonly) NSArray *attributes;
@property (nonatomic, readonly) int pointerLevel;
@property (nonatomic, readonly) BOOL readonly;
@property (nonatomic, readonly) BOOL nonatomic;
@property (nonatomic, readonly) BOOL weak;
@property (nonatomic, readonly) BOOL copy;
@property (nonatomic, readonly) BOOL dynamic;
@property (nonatomic, readonly) BOOL strong;

// if valueType == NFRecordPropertyDataTypeObject, this will be set to the class of the value
@property (nonatomic, readonly) Class valueClass;

- (BOOL)isPointer;

+ (NSArray *)propertiesFromClass:(Class)klass;
+ (NSDictionary *)propertiesDictionaryFromClass:(Class)klass;

@end
