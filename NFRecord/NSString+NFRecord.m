//
//  NSString+NFRecord.m
//  NFRecord
//
//  Created by Andrew Williams on 22/01/2015.
//  Copyright (c) 2015 NextFaze. All rights reserved.
//

#import "NSString+NFRecord.h"

@implementation NSString (NFRecord)

- (NSString *)nfrecordUnderscored {
    NSMutableString *text = [self mutableCopy];
    for(;;) {
        NSRange range = [text rangeOfString:@"[a-z][A-Z]" options:NSRegularExpressionSearch];
        if(range.location == NSNotFound)
            break;
        [text insertString:@"_" atIndex:range.location + 1];
    }
    return [text lowercaseString];
}

@end
