//
//  SnakeCaseTest.m
//  JAGPropertyConverter
//
//  Created by Yen-Chia Lin on 27.11.14.
//
//

#import <XCTest/XCTest.h>
#import "NSString+JAGSnakeCaseSupport.h"

@interface SnakeCaseTest : XCTestCase

@end

@implementation SnakeCaseTest

- (void)testConvertToCamelCase {
    XCTAssertEqualObjects([@"hello" asCamelCaseFromUnderscore], @"hello", @"no change");
    XCTAssertEqualObjects([@"Hello" asCamelCaseFromUnderscore], @"Hello", @"no change");
    XCTAssertEqualObjects([@"hello there" asCamelCaseFromUnderscore], @"hello there", @"no change");
    XCTAssertEqualObjects([@"hello_there" asCamelCaseFromUnderscore], @"helloThere", @"convert");
    XCTAssertEqualObjects([@"stay awhile and listen" asCamelCaseFromUnderscore], @"stay awhile and listen", @"no change");
    XCTAssertEqualObjects([@"stay_awhile_and_listen" asCamelCaseFromUnderscore], @"stayAwhileAndListen", @"convert");
    XCTAssertEqualObjects([@"created_at" asCamelCaseFromUnderscore], @"createdAt", @"convert");
    XCTAssertEqualObjects([@"created_at_1234" asCamelCaseFromUnderscore], @"createdAt1234", @"convert");
}

- (void)testConvertToSnakeCase {
    XCTAssertEqualObjects([@"createdAt1234" asUnderscoreFromCamelCase], @"created_at1234", @"convert");
}

@end
