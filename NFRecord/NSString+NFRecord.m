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
    [self capitalizeCharacterAtIndex:0 string:text];
    return text;
}

#pragma mark - Utility

- (void)capitalizeCharacterAtIndex:(NSUInteger)index string:(NSMutableString *)string {
    unichar ch = [string characterAtIndex:index];
    if(ch >= 'a' && ch <= 'z') {
        ch = ch - 'a' + 'A';
        NSString *replacement = [NSString stringWithFormat:@"%c", ch];
        NSRange range = NSMakeRange(index, 1);
        [string replaceCharactersInRange:range withString:replacement];
    }
}

@end
