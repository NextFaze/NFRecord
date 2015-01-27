//
//  NFRecordDatabaseConfiguration.m
//  NFRecord
//
//  Created by Andrew Williams on 23/01/2015.
//  Copyright (c) 2015 NextFaze. All rights reserved.
//

#import "NFRecordDatabaseConfiguration.h"

#define NFRecordDatabaseConfigurationFile @"nfrecord_database"

@interface NFRecordDatabaseConfiguration ()
@property (nonatomic, strong) NSDictionary *config;
@end

@implementation NFRecordDatabaseConfiguration

- (id)init {
    self = [super init];
    if(self) {
        [self readConfiguration:NFRecordDatabaseConfigurationFile];
    }
    return self;
}

#pragma mark - Private

- (void)readConfiguration:(NSString *)configurationFile {
    NSString *path = [[NSBundle mainBundle] pathForResource:configurationFile ofType:@"plist"];
    if(path) {
        NSDictionary *config = [NSDictionary dictionaryWithContentsOfFile:path];
        self.config = config;
    }
}

@end
