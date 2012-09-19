//
//  NumberFormatterTest.m
//  JAGPropertyConverter
//
//  Created by James Gill on 9/19/12.
//
//

#import "NumberFormatterTest.h"
#import "JAGPropertyConverter.h"

@implementation NumberTestModel

@synthesize intProperty, floatProperty, numberProperty, stringProperty;

@end


@implementation NumberFormatterTest

NumberTestModel *model;
JAGPropertyConverter *converter;


- (void) setUp
{
    model = [[NumberTestModel alloc] init];
    converter = [[JAGPropertyConverter alloc] init];
    converter.numberFormatter = [[NSNumberFormatter alloc] init];
    converter.classesToConvert = [NSSet setWithObject:[NumberTestModel class]];
}

- (void) testNSStringToInt
{
    NSDictionary *dict = [NSDictionary dictionaryWithObject:@"7" forKey:@"intProperty"];
    [converter setPropertiesOf:model fromDictionary:dict];
    STAssertEquals(7, model.intProperty, @"intProperty should be set correctly.");
}

- (void) testNSStringToFloat
{
    NSDictionary *dict = [NSDictionary dictionaryWithObject:@"6.8" forKey:@"floatProperty"];
    [converter setPropertiesOf:model fromDictionary:dict];
    float myFloat = 6.8;
    STAssertEqualsWithAccuracy(myFloat, model.floatProperty, 0.01, @"floatProperty %f should be %f.", model.floatProperty, myFloat);
}

- (void) testNSStringToNSNumberLong
{
    NSDictionary *dict = [NSDictionary dictionaryWithObject:@"300" forKey:@"numberProperty"];
    [converter setPropertiesOf:model fromDictionary:dict];
    NSNumber *myNum = [NSNumber numberWithLong:300];
    STAssertTrue([myNum isEqualToNumber: model.numberProperty], @"numberProperty %@ should be equal to %@.", model.numberProperty, myNum);
}

- (void) testNSStringToNSNumberFloat
{
    NSDictionary *dict = [NSDictionary dictionaryWithObject:@"3.3" forKey:@"numberProperty"];
    [converter setPropertiesOf:model fromDictionary:dict];
    NSNumber *myNum = [NSNumber numberWithFloat:3.3];
    STAssertEqualsWithAccuracy([myNum floatValue], [model.numberProperty floatValue],  0.01, @"numberProperty %@ should be equal to %@.", model.numberProperty, myNum);
}

- (void) testNSStringToNSString
{
    NSDictionary *dict = [NSDictionary dictionaryWithObject:@"4" forKey:@"stringProperty"];
    [converter setPropertiesOf:model fromDictionary:dict];
    STAssertEqualObjects(@"4", model.stringProperty, @"stringProperty should not be converted.");
}


@end
