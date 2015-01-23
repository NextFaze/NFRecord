//
//  NFRecordBaseTest.m
//  NFRecord
//
//  Created by Andrew Williams on 23/01/2015.
//  Copyright (c) 2015 NextFaze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NFTestDog.h"

@interface NFRecordBaseTest : XCTestCase
@end

@implementation NFRecordBaseTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark -

- (void)testAssignAttributes {
    NFTestDog *dog = [[NFTestDog alloc] init];
    dog.attributes = @{ @"breed": @"Doge" };
    XCTAssertEqualObjects(dog.breed, @"Doge");
}

// test camel case with capitalized first letter
- (void)testAssignAttributesCamelCapitalized {
    NFTestDog *dog = [[NFTestDog alloc] init];
    dog.attributes = @{ @"RaceName": @"Crafty" };
    XCTAssertEqualObjects(dog.raceName, @"Crafty");
}

// test camel case
- (void)testAssignAttributesCamel {
    NFTestDog *dog = [[NFTestDog alloc] init];
    dog.attributes = @{ @"raceName": @"Crafty" };
    XCTAssertEqualObjects(dog.raceName, @"Crafty");
}

// test underscore -> camel case conversion
- (void)testAssignAttributesUnderscore {
    NFTestDog *dog = [[NFTestDog alloc] init];
    dog.attributes = @{ @"race_name": @"Crafty" };
    XCTAssertEqualObjects(dog.raceName, @"Crafty");
}

- (void)testGetAttributes {
    NFTestDog *dog = [[NFTestDog alloc] init];
    dog.breed = @"Doge";
    NSDictionary *attribs = dog.attributes;
    //NSLog(@"attributes: %@", attribs);
    XCTAssertEqualObjects(attribs[@"breed"], @"Doge");
}

/*
- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}
 */

@end
