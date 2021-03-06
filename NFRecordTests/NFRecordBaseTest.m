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
#import "NFRecordConfig.h"

@interface NFRecordBaseTest : XCTestCase
@end

@implementation NFRecordBaseTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NFRecordDatabase *db = [[NFRecordDatabase alloc] initWithDataModelName:@"NFTestDb" bundle:bundle];
    [[NFRecordConfig sharedInstance] setDatabase:db];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Setting attributes

- (void)testAssignAttributes {
    NFTestDog *dog = [[NFTestDog alloc] init];
    dog.attributes = @{ @"breed": @"Doge" };
    XCTAssertEqualObjects(dog.breed, @"Doge");
}

// test capitalized
- (void)testAssignAttributesCapitalized {
    NFTestDog *dog = [[NFTestDog alloc] init];
    dog.attributes = @{ @"Breed": @"Doge" };
    XCTAssertEqualObjects(dog.breed, @"Doge");
}

// test uppercase -> lowercase conversion
- (void)testAssignAttributesDowncased {
    NFTestDog *dog = [[NFTestDog alloc] init];
    dog.attributes = @{ @"BREED": @"Doge" };
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

// test that assigning attributes doesn't overwrite attributes not present in the dictionary
- (void)testAssignAttributesMissing {
    NFTestDog *dog = [[NFTestDog alloc] init];
    dog.raceName = @"Crafty";
    dog.attributes = @{ @"breed": @"Doge" };
    XCTAssertEqualObjects(dog.raceName, @"Crafty");
}

// test that assigning nil attributes deletes values
- (void)testAssignAttributesNil {
    NFTestDog *dog = [[NFTestDog alloc] init];
    dog.breed = @"Doge";
    dog.attributes = @{ @"breed": [NSNull null] };
    XCTAssertNil(dog.breed);
}

// test assigning nested attributes
- (void)testAssignAttributesNested {
    NFTestDog *dog = [[NFTestDog alloc] init];
    dog.attributes = @{ @"breed": @"Doge", @"owner": @{ @"name": @"Doge owner" } };
    XCTAssertEqualObjects(dog.owner.name, @"Doge owner");
}

#pragma mark - Getting attributes

- (void)testGetAttributes {
    NFTestDog *dog = [[NFTestDog alloc] init];
    dog.breed = @"Doge";
    NSDictionary *attribs = dog.attributes;
    //NSLog(@"attributes: %@", attribs);
    XCTAssertEqualObjects(attribs[@"breed"], @"Doge");
}

#pragma mark - Casting

- (void)testCastBoolTrueFalse {
    NFTestDog *dog = [[NFTestDog alloc] init];
    dog.attributes = @{ @"is_hungry": @"true" };
    XCTAssertEqual(dog.isHungry, YES);
    dog.attributes = @{ @"is_hungry": @"false" };
    XCTAssertEqual(dog.isHungry, NO);
}

- (void)testCastBoolNumber {
    NFTestDog *dog = [[NFTestDog alloc] init];
    dog.attributes = @{ @"is_hungry": [NSNumber numberWithBool:YES] };
    XCTAssertEqual(dog.isHungry, YES);
    dog.attributes = @{ @"is_hungry": [NSNumber numberWithBool:NO] };
    XCTAssertEqual(dog.isHungry, NO);
}

- (void)testCastStringNSNull {
    NFTestDog *dog = [[NFTestDog alloc] init];
    dog.attributes = @{ @"breed": [NSNull null] };
    XCTAssertEqualObjects(dog.breed, nil);
}

- (void)testCastBoolNSNull {
    NFTestDog *dog = [[NFTestDog alloc] init];
    dog.attributes = @{ @"is_hungry": [NSNull null] };
    XCTAssertEqual(dog.isHungry, NO);
}

#pragma mark - Persistence


- (void)testSaveRead {
    
    // delete all dogs
    NFRecordDatabase *db = [[NFRecordConfig sharedInstance] database];
    [db deleteAll:@"NFTestDog"];
    
    NFTestDog *dog = [[NFTestDog alloc] init];
    dog.raceName = @"Crafty";
    [dog save];
    
    //XCTestExpectation *saveExpectation = [self expectationWithDescription:@"record saved"];
    sleep(1);

    NFTestDog *dog2 = [[db readItems:@"NFTestDog"] firstObject];
    XCTAssertEqualObjects(dog2.raceName, @"Crafty");
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
