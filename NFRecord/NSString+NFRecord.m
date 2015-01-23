//
//  NSString+NFRecord.m
//  NFRecord
//
//  Created by Andrew Williams on 22/01/2015.
//  Copyright (c) 2015 NextFaze. All rights reserved.
//

#import "NSString+NFRecord.h"

@implementation NSString (NFRecord)

- (NSString *)nfrecordTrim {
    NSString *value = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return value.length ? value : nil;
}

- (NSString *)nfrecordUrlEncodeUsingEncoding:(NSStringEncoding)encoding {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (CFStringRef)self,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                                 CFStringConvertNSStringEncodingToEncoding(encoding)));
}

- (NSString *)nfrecordUnderscore {
    NSMutableString *text = [self mutableCopy];
    for(;;) {
        NSRange range = [text rangeOfString:@"[a-z][A-Z]" options:NSRegularExpressionSearch];
        if(range.location == NSNotFound)
            break;
        [text insertString:@"_" atIndex:range.location + 1];
    }
    return [text lowercaseString];
}

- (NSString *)nfrecordCapitalize {
    NSMutableString *text = [self mutableCopy];
    return [self capitalizeCharacterAtIndex:0 string:text];
}

- (NSString *)nfrecordCamelize {
    NSMutableString *text = [[self lowercaseString] mutableCopy];
    for(;;) {
        NSRange range = [text rangeOfString:@"_[a-z]" options:NSRegularExpressionSearch];
        if(range.location == NSNotFound)
            break;
        
        // convert second character to uppercase
        unichar ch = [text characterAtIndex:range.location + 1] - 'a' + 'A';
        NSString *replacement = [NSString stringWithFormat:@"%c", ch];
        [text replaceCharactersInRange:range withString:replacement];
    }
    
    // capitalize first character
    return [self capitalizeCharacterAtIndex:0 string:text];
}

#pragma mark - Utility

- (NSMutableString *)capitalizeCharacterAtIndex:(NSUInteger)index string:(NSMutableString *)string {
    unichar ch = string.length > index ? [string characterAtIndex:index] : '\0';
    if(ch >= 'a' && ch <= 'z') {
        ch = ch - 'a' + 'A';
        NSString *replacement = [NSString stringWithFormat:@"%c", ch];
        NSRange range = NSMakeRange(index, 1);
        [string replaceCharactersInRange:range withString:replacement];
    }
    return string;
}

@end
