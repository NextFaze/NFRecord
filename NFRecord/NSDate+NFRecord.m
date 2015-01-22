//
//  NSDate+NFRecord.m
//  NFRecord
//
//  Created by Andrew Williams on 22/01/2015.
//  Copyright (c) 2015 NextFaze. All rights reserved.
//

#import "NSDate+NFRecord.h"

static NSArray *dateFormats = nil;

@implementation NSDate (NFRecord)

+ (void)load {
    if(dateFormats == nil) {
        // date formatters, executed in order when parsing dates
        dateFormats = @[[self nfrecordDateFormatterWithFormat:@"y-MM-dd'T'HH:mm:ss.SSS'Z'"],
                        [self nfrecordDateFormatterWithFormat:@"y-MM-dd"],
                        [self nfrecordDateFormatterWithFormat:@"MMM dd, HH:mm"],
                        [self nfrecordDateFormatterWithFormat:@"MMM dd, y HH:mm:ss"],
                        ];
    }
}

+ (NSDate *)nfrecordValueFromString:(NSString *)string {
    return [self nfrecordDateFromString:string];
}

- (NSString *)stringValue {
    return [dateFormats[0] stringFromDate:self];
}

+ (NSDateFormatter *)nfrecordDateFormatterWithFormat:(NSString *)format {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    df.dateFormat = format;
    return df;
}

// "paypal_account_date": "2008-02-25",
// "end_date": "2014-09-27T00:00:00.000Z",
+ (NSDate *)nfrecordDateFromString:(NSString *)value {
    for(NSDateFormatter *df in dateFormats) {
        NSDate *date = [df dateFromString:value];
        if(date) {
            if([value hasSuffix:@"Z"]) {
                // zulu time
                NSTimeInterval offset = [[NSTimeZone defaultTimeZone] secondsFromGMT];
                date = [date dateByAddingTimeInterval:offset];
            }
            return date;
        }
    }
    NFLog(@"could not parse date: %@", value);
    return nil;
}

@end
