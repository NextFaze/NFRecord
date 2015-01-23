//
//  NFRecordHTTP.h
//  NFRecord
//
//  Created by Andrew Williams on 23/01/2015.
//  Copyright (c) 2015 NextFaze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NFRecordHTTP : NSObject

+ (NSString *)stringWithEncodedQueryParameters:(NSDictionary *)parameters;

@end
