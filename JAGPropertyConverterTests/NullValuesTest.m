//
//  NullValuesTest.m
//  JAGPropertyConverter
//
//  Created by Yen-Chia Lin on 29.01.15.
//
//

#import <XCTest/XCTest.h>

#import "JAGPropertyConverter.h"
#import "NumberTestModel.h"

@interface NullValuesTest : XCTestCase {
    NumberTestModel *model;
    JAGPropertyConverter *converter;
}

@end

@implementation NullValuesTest

- (void)setUp {
    [super setUp];
    model = [[NumberTestModel alloc] init];
    converter = [[JAGPropertyConverter alloc] init];
    converter.classesToConvert = [NSSet setWithObject:[NumberTestModel class]];
    
    // we want NSNull values
    converter.shouldIgnoreNullValues = NO;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en"];
    converter.numberFormatter = formatter;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testNullBool {
    model.boolProperty = YES;
    XCTAssertTrue(model.boolProperty, @"boolProperty should be set correctly.");
    
    NSDictionary *dict = @{ @"boolProperty" :[NSNull null] };
    [converter setPropertiesOf:model fromDictionary:dict];
    XCTAssertFalse(model.boolProperty, @"boolProperty should be set correctly.");
}

- (void)testNullInt {
    model.intProperty = 1337;
    XCTAssertEqual(1337, model.intProperty, @"intProperty should be set correctly.");
    
    NSDictionary *dict = @{ @"intProperty" : [NSNull null] };
    [converter setPropertiesOf:model fromDictionary:dict];
    XCTAssertEqual(0, model.intProperty, @"intProperty should be set correctly.");
}

- (void) testNullFloat {
    float myFloat = 6.8f;
    model.floatProperty = myFloat;
    XCTAssertEqualWithAccuracy(myFloat, model.floatProperty, 0.01, @"floatProperty %f should be %f.", model.floatProperty, myFloat);
    
    NSDictionary *dict = @{ @"floatProperty" : [NSNull null] };
    [converter setPropertiesOf:model fromDictionary:dict];
    XCTAssertEqualWithAccuracy(0.0f, model.floatProperty, 0.01, @"floatProperty %f should be %f.", model.floatProperty, 0.0f);
}

- (void) testNullDouble {
    double myDouble = 6.1234567890123;
    model.doubleProperty = myDouble;
    XCTAssertEqualWithAccuracy(myDouble, model.doubleProperty, 0.01, @"doubleProperty %f should be %f.", model.doubleProperty, myDouble);
    
    NSDictionary *dict = @{ @"doubleProperty" : [NSNull null] };
    [converter setPropertiesOf:model fromDictionary:dict];
    XCTAssertEqualWithAccuracy(0.0, model.doubleProperty, 0.01, @"doubleProperty %f should be %f.", model.doubleProperty, 0.0);
}

- (void) testLongLong {
    long long myLongLong = 61234567890123;
    model.longLongProperty = myLongLong;
    XCTAssertEqual(myLongLong, model.longLongProperty, @"longLongProperty should be set correctly.");
    
    NSDictionary *dict = @{ @"longLongProperty" : [NSNull null] };
    [converter setPropertiesOf:model fromDictionary:dict];
    XCTAssertEqual(0ll, model.longLongProperty, @"longLongProperty should be set correctly.");
}

- (void) testNullNSNumber {
    NSNumber *myNum = [NSNumber numberWithLong:300];
    model.numberProperty = myNum;
    XCTAssertTrue([myNum isEqualToNumber: model.numberProperty], @"numberProperty %@ should be equal to %@.", model.numberProperty, myNum);
    
    NSDictionary *dict = @{ @"numberProperty" : [NSNull null] };
    [converter setPropertiesOf:model fromDictionary:dict];
    XCTAssertNil(model.numberProperty, @"numberProperty should be nil!");
}

- (void) testNullString {
    model.stringProperty = @"Everything is awesome!";
    XCTAssertEqualObjects(@"Everything is awesome!", model.stringProperty, @"");

    NSDictionary *dict = @{ @"stringProperty" : [NSNull null] };
    [converter setPropertiesOf:model fromDictionary:dict];
    XCTAssertNil(model.stringProperty, @"should be nil");
}

@end
