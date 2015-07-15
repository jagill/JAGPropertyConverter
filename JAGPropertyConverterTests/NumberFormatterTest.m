//
//  NumberFormatterTest.m
//  JAGPropertyConverter
//
//  Created by James Gill on 9/19/12.
//
//

#import "NumberFormatterTest.h"
#import "JAGPropertyConverter.h"
#import "NumberTestModel.h"

@interface NumberFormatterTest () {
    NumberTestModel *model;
    JAGPropertyConverter *converter;
}

@end

@implementation NumberFormatterTest

- (void) setUp
{
    model = [[NumberTestModel alloc] init];
    converter = [[JAGPropertyConverter alloc] init];
    converter.classesToConvert = [NSSet setWithObject:[NumberTestModel class]];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en"];
    converter.numberFormatter = formatter;
}

- (void) testNSStringToBool
{
    NSDictionary *dict = @{ @"boolProperty" : @"true" };
    [converter setPropertiesOf:model fromDictionary:dict];
    XCTAssertTrue(model.boolProperty, @"boolProperty should be set correctly.");
}

- (void) testNSStringToInt
{
    NSDictionary *dict = @{ @"intProperty" : @"7" };
    [converter setPropertiesOf:model fromDictionary:dict];
    XCTAssertEqual(7, model.intProperty, @"intProperty should be set correctly.");
}

- (void) testNSStringToFloat
{
    NSDictionary *dict = @{ @"floatProperty" : @"6.8" };
    [converter setPropertiesOf:model fromDictionary:dict];
    float myFloat = 6.8;
    XCTAssertEqualWithAccuracy(myFloat, model.floatProperty, 0.01, @"floatProperty %f should be %f.", model.floatProperty, myFloat);
}

- (void) testNSStringToDouble
{
    NSDictionary *dict = @{ @"doubleProperty" : @"6.1234567890123" };
    [converter setPropertiesOf:model fromDictionary:dict];
    double myDouble = 6.1234567890123;
    XCTAssertEqualWithAccuracy(myDouble, model.doubleProperty, 0.01, @"doubleProperty %f should be %f.", model.doubleProperty, myDouble);
}

- (void) testNSStringToLongLong
{
    NSDictionary *dict = @{ @"longLongProperty" : @"61234567890123" };
    [converter setPropertiesOf:model fromDictionary:dict];
    long long myLongLong = 61234567890123;
    XCTAssertEqual(myLongLong, model.longLongProperty, @"longLongProperty should be set correctly.");
}

- (void) testNSStringToNSNumberLong
{
    NSDictionary *dict = @{ @"numberProperty" : @"300" };
    [converter setPropertiesOf:model fromDictionary:dict];
    NSNumber *myNum = [NSNumber numberWithLong:300];
    XCTAssertTrue([myNum isEqualToNumber: model.numberProperty], @"numberProperty %@ should be equal to %@.", model.numberProperty, myNum);
}

- (void) testNSStringToNSNumberBool
{
    NSDictionary *dict = @{ @"boolNumberProperty" : @"true" };
    [converter setPropertiesOf:model fromDictionary:dict];
    NSNumber *myNum = [NSNumber numberWithBool:YES];
    XCTAssertTrue([myNum isEqualToNumber: model.boolNumberProperty], @"numberProperty %@ should be equal to %@.", model.boolNumberProperty, myNum);
}

- (void) testNSStringToNSNumberFloat
{
    NSDictionary *dict = @{ @"numberProperty" : @"3.3" };
    [converter setPropertiesOf:model fromDictionary:dict];
    NSNumber *myNum = [NSNumber numberWithFloat:3.3];
    XCTAssertEqualWithAccuracy([myNum floatValue], [model.numberProperty floatValue],  0.01, @"numberProperty %@ should be equal to %@.", model.numberProperty, myNum);
}

- (void) testNSStringToNSString
{
    NSDictionary *dict = @{ @"stringProperty" : @"4" };
    [converter setPropertiesOf:model fromDictionary:dict];
    XCTAssertEqualObjects(@"4", model.stringProperty, @"stringProperty should not be converted.");
}

@end
