//
//  SnakeCaseTest.m
//  JAGPropertyConverter
//
//  Created by Yen-Chia Lin on 27.11.14.
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "NSString+JAGSnakeCaseSupport.h"

@interface SnakeCaseTest : SenTestCase

@end

@implementation SnakeCaseTest

- (void)testConvertToCamelCase {
    STAssertEqualObjects([@"hello" asCamelCaseFromUnderscore], @"hello", @"no change");
    STAssertEqualObjects([@"Hello" asCamelCaseFromUnderscore], @"Hello", @"no change");
    STAssertEqualObjects([@"hello there" asCamelCaseFromUnderscore], @"hello there", @"no change");
    STAssertEqualObjects([@"hello_there" asCamelCaseFromUnderscore], @"helloThere", @"convert");
    STAssertEqualObjects([@"stay awhile and listen" asCamelCaseFromUnderscore], @"stay awhile and listen", @"no change");
    STAssertEqualObjects([@"stay_awhile_and_listen" asCamelCaseFromUnderscore], @"stayAwhileAndListen", @"convert");
    STAssertEqualObjects([@"created_at" asCamelCaseFromUnderscore], @"createdAt", @"convert");
    STAssertEqualObjects([@"created_at_1234" asCamelCaseFromUnderscore], @"createdAt1234", @"convert");
}

- (void)testConvertToSnakeCase {
    STAssertEqualObjects([@"createdAt1234" asUnderscoreFromCamelCase], @"created_at1234", @"convert");
}

@end
