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

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testConvertToCamelCase {
    STAssertEqualObjects([@"hello" asCamelCaseFromUnderscore], @"hello", @"no change");
    STAssertEqualObjects([@"Hello" asCamelCaseFromUnderscore], @"Hello", @"no change");
    STAssertEqualObjects([@"hello there" asCamelCaseFromUnderscore], @"hello there", @"no change");
    STAssertEqualObjects([@"hello_there" asCamelCaseFromUnderscore], @"helloThere", @"convert");
    STAssertEqualObjects([@"stay awhile and listen" asCamelCaseFromUnderscore], @"stay awhile and listen", @"no change");
    STAssertEqualObjects([@"stay_awhile_and_listen" asCamelCaseFromUnderscore], @"stayAwhileAndListen", @"convert");
    STAssertEqualObjects([@"created_at" asCamelCaseFromUnderscore], @"createdAt", @"convert");
}


@end
