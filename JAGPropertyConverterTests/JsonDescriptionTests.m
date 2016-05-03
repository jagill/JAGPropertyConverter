//
//  JsonDescriptionTests.m
//  JAGPropertyConverter
//
//  Created by Yen-Chia Lin on 03.05.16.
//
//

#import <XCTest/XCTest.h>

#import "NSDictionary+JsonString.h"

/** Tests the conversion from NSDictionary into a pretty formatted JSON string. */
@interface JsonDescriptionTests : XCTestCase

@end

@implementation JsonDescriptionTests

- (void)testEmptyDict {
    NSDictionary *dict = @{};
    XCTAssertEqualObjects(dict.jsonDescription, @"(empty)");
}

- (void)testUnsupportedObject {
    NSDictionary *dict = @{ @"wat?" : [[NSNumberFormatter alloc] init]};
    XCTAssertEqualObjects(dict.jsonDescription, @"<null>");
}

- (void)testJsonString {
    NSDictionary *dict = @{ @"who?" : @"I'm Batman!" };
    NSString *jsonString = dict.jsonDescription;
    
    XCTAssertEqualObjects(jsonString, @"{\n  \"who?\" : \"I\'m Batman!\"\n}");
}

- (void)testPerformanceExample {
    NSDictionary *dict = @{ @"who?" : @"I'm Batman!" };
    
    [self measureBlock:^{
        NSString *jsonString = dict.jsonDescription;
        
        XCTAssertEqualObjects(jsonString, @"{\n  \"who?\" : \"I\'m Batman!\"\n}");
    }];
}

@end
