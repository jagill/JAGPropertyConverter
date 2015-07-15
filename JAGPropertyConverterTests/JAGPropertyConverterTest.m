//
//  JAGConverterTest.m
//
//  Created by James Gill on 1/23/12.
//
// Copyright (c) 2012 James A. Gill
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "JAGPropertyConverterTest.h"
#import "TestModel.h"
#import "JAGPropertyConverter.h"

@interface JAGPropertyConverterTest () {
@private
    TestModel *model;
    JAGPropertyConverter *converter;
}

@end

@implementation JAGPropertyConverterTest

- (void) setUp {
    model = [TestModel testModel];
    [model populate];
    
    converter = [[JAGPropertyConverter alloc] init];
    converter.classesToConvert = [NSSet setWithObject:[TestModel class]];
    converter.identifyDict = ^ Class (NSString *dictName, NSDictionary *dict)  {
        if ([dict valueForKey:@"testModelID"]) {
            return [TestModel class];
        }
        return nil;

    };
}

- (void) assert: (TestModel*) testModel isEqualTo: (NSDictionary*) dict {
    XCTAssertEqualObjects(testModel.testModelID, [dict valueForKey:@"testModelID"], 
                         @"Model and Dictionary should have same testModelID");
    XCTAssertEqualObjects(testModel.stringProperty, [dict valueForKey:@"stringProperty"], 
                         @"Model and Dictionary should have same stringProperty");
    XCTAssertEqualObjects(testModel.arrayProperty, [dict valueForKey:@"arrayProperty"], 
                         @"Model and Dictionary should have same arrayProperty");
    XCTAssertEqualObjects(testModel.dictionaryProperty, [dict valueForKey:@"dictionaryProperty"], 
                         @"Model and Dictionary should have same dictionaryProperty");
    XCTAssertEqual(testModel.intProperty, [[dict valueForKey:@"intProperty"] intValue], 
                         @"Model and Dictionary should have same intProperty");    
}

- (void) testToDictionaryJSON {
    converter.outputType = kJAGJSONOutput;
    NSDictionary *dict = [converter convertToDictionary:model];
    NSLog(@"Converted to dictionary.");
    [self assert:model isEqualTo:dict];

    XCTAssertNil([dict valueForKey:@"dateProperty"], @"JSON Dictionary should not have a date value.");
    XCTAssertNil([dict valueForKey:@"cfProperty"], @"JSON Dictionary should not have a CF value.");
}

- (void) testToDictionaryPropertyList {
    converter.outputType = kJAGPropertyListOutput;
    NSDictionary *dict = [converter convertToDictionary:model];
    [self assert:model isEqualTo:dict];
    XCTAssertEqualObjects(model.dateProperty, [dict valueForKey:@"dateProperty"], @"PropertyList Dictionary should have a date value.");
    XCTAssertNil([dict valueForKey:@"cfProperty"], @"PropertyList Dictionary should not have a CF value.");
    
}

- (void) testToDictionaryFull {
    converter.outputType = kJAGFullOutput;
    NSDictionary *dict = [converter convertToDictionary:model];
    [self assert:model isEqualTo:dict];
    XCTAssertEqualObjects(model.dateProperty, [dict valueForKey:@"dateProperty"], @"Full Dictionary should have a date value.");
    NSValue *cfValue = [dict valueForKey:@"cfProperty"];
    XCTAssertNotNil(cfValue, @"Full Dictionary should have a CF value.");
    
    
}

- (void) testToModel {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"M123122", @"testModelID",
                          [NSNumber numberWithInt:5], @"intProperty",
                          [NSNumber numberWithBool:YES], @"boolProperty",
                          [NSDictionary dictionaryWithObjectsAndKeys:
                               @"red", @"RED",
                               @"blue", @"BLUE",
                               nil], @"dictionaryProperty",
                          [NSArray arrayWithObjects:
                               @"one", @"two", @"three", 
                                nil], @"arrayProperty",
                          [NSArray arrayWithObjects: @"alpha", @"beta", @"gamma",
                                nil], @"setProperty",
                          nil];
    TestModel *testModel = [TestModel testModel];
    [converter setPropertiesOf:testModel fromDictionary:dict];
    [self assert:testModel isEqualTo:dict];
}

- (void) testToModelWithDifferntPropertyName {
    // custom mapping is directly implemented by TestModel with <JAGPropertyMapping>
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"M123122", @"testModelID",
                          [NSNumber numberWithInt:5], @"intProperty",
                          [NSNumber numberWithBool:YES], @"boolProperty",
                          @"new name" , @"someProperty",
                          nil];
    TestModel *testModel = [TestModel testModel];
    [converter setPropertiesOf:testModel fromDictionary:dict];
    
    XCTAssertNotNil(testModel.differentNameProperty, @"");
    XCTAssertEqualObjects(testModel.differentNameProperty, @"new name", @"");
}

- (void) testIdentifyModel {
    NSDictionary *auxTestModelDict = [NSDictionary dictionaryWithObject:@"D524234" forKey:@"testModelID"];
    NSDictionary *testModelDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"G653", @"testModelID",
                                   @"Happy", @"stringProperty",
                                   auxTestModelDict, @"modelProperty",
                                   nil];
    
    TestModel *testModel = [converter composeModelFromObject:testModelDict];
    [self assert:testModel isEqualTo:testModelDict];
}

- (void) testSetPropertyJSON {
    converter.outputType = kJAGJSONOutput;
    NSDictionary *dict = [converter decomposeObject:model];
    id setValue = [dict valueForKey:@"setProperty"];
    XCTAssertNotNil(setValue, @"Converted setProperty should not be nil.");
    XCTAssertTrue([setValue isKindOfClass:[NSArray class]], 
                 @"setProperty %@ should be converted to an NSArray for JSON.", setValue);
    NSSet *setFromArray = [NSSet setWithArray:setValue];
    XCTAssertEqualObjects(model.setProperty, setFromArray, @"Converted setProperty should have same objects.");
    TestModel *returnedModel = [[TestModel alloc] initWithPropertiesFromDictionary:dict];
    XCTAssertEqualObjects(model.setProperty, returnedModel.setProperty,  @"setProperty should be unchanged over serialization/deserialization.");
}

- (void) testURLPropertyJSON {
    converter.outputType = kJAGJSONOutput;
    NSDictionary *dict = [converter decomposeObject:model];
    id urlValue = [dict valueForKey:@"urlProperty"];
    XCTAssertNotNil(urlValue, @"Converted urlProperty should not be nil.");
    XCTAssertTrue([urlValue isKindOfClass:[NSString class]], 
                 @"urlValue %@ should be converted to an NSString for JSON.", urlValue);
    NSURL *urlFromArray = [NSURL URLWithString:urlValue];
    XCTAssertEqualObjects(urlFromArray, model.urlProperty, @"URL property should have same absolute string.");
}

- (void) testURLPropertyJSONDeserialize {
    converter.outputType = kJAGJSONOutput;
    NSDictionary *dict = [converter decomposeObject:model];
    TestModel *model2 = [TestModel testModel];
    [model2 setPropertiesFromDictionary:dict];
    XCTAssertNotNil(model2.urlProperty, @"urlProperty should not be nil.");
    XCTAssertTrue([model2.urlProperty isKindOfClass: [NSURL class]], @"urlProperty should be an NSURL.");
    XCTAssertEqualObjects(model2.urlProperty, model.urlProperty, @"urlProperties should be equal.");
}

- (void) testWeakProperty {
    TestModel *strongReference = [TestModel testModel];
    model.weakProperty = strongReference;
    converter.outputType = kJAGFullOutput;
    NSDictionary *dict = [converter decomposeObject:model];
    XCTAssertNil([dict valueForKey:@"weakProperty"], @"By default, converter should not convert weak properties");
}

- (void) testWeakProperty2 {
    TestModel *strongReference = [TestModel testModel];
    model.weakProperty = strongReference;
    converter.outputType = kJAGFullOutput;
    converter.shouldConvertWeakProperties = YES;
    NSDictionary *dict = [converter decomposeObject:model];
    XCTAssertNotNil([dict valueForKey:@"weakProperty"], @"By default, converter should not convert weak properties");
}

- (void) testNSArrayWithNSNumberWithBoolFalse {
    NSNumber *falseNum = [NSNumber numberWithBool:NO];
    NSNumber *zeroNum = [NSNumber numberWithInt:0];
    NSArray *array = [NSArray arrayWithObjects:falseNum, zeroNum, nil];
    id decomposed = [converter decomposeObject:array];
    XCTAssertTrue([decomposed count] == 2, @"Array should have two elements after decomposing.");
    id composed = [converter composeModelFromObject:array];
    XCTAssertTrue([composed count] == 2, @"Array should have two elements after composing.");
}

- (void) testNSDictWithNSNumberWithBoolFalse {
    NSNumber *falseNum = [NSNumber numberWithBool:NO];
    NSNumber *zeroNum = [NSNumber numberWithInt:0];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          falseNum, @"one", 
                          zeroNum, @"two",
                          nil];
    id decomposed = [converter decomposeObject:dict];
    XCTAssertTrue([decomposed count] == 2, @"Dict should have two elements after decomposing.");
    id composed = [converter composeModelFromObject:dict];
    XCTAssertTrue([composed count] == 2, @"Dict should have two elements after composing.");
}

#pragma mark - Null Values

- (void)testIgnoringNSNullValues {
    converter.shouldIgnoreNullValues = YES;
    
    NSDictionary *dict = @{ @"stringProperty" : [NSNull null] };
    
    TestModel *testModel = [TestModel testModel];
    [converter setPropertiesOf:testModel fromDictionary:dict];
    XCTAssertNil(testModel.stringProperty, @"");
}

#pragma mark - Snake Case

- (void)testSnakeCaseSupport1 {
    converter.enableSnakeCaseSupport = YES;
    
    NSDictionary *dict = @{ @"int_property" : @12345,
                            @"stringProperty" : @"same" };
    
    TestModel *testModel = [TestModel testModel];
    [converter setPropertiesOf:testModel fromDictionary:dict];
    XCTAssertEqual(testModel.intProperty, 12345, @"camel case property should be set to 12345");
    XCTAssertEqualObjects(testModel.stringProperty, @"same", @"normal property should also work normally");
}

- (void)testSnakeCaseSupport2 {
    converter.enableSnakeCaseSupport = YES;
    
    NSDictionary *dict = @{ @"String_Property" : @"same" };
    
    TestModel *testModel = [TestModel testModel];
    [converter setPropertiesOf:testModel fromDictionary:dict];
    XCTAssertNil(testModel.stringProperty, @"not correct snake case --> nil");
}

#pragma mark - Enums

- (void)testConvertPropertyToEnum {
    converter.identifyDict = ^Class (NSString *dictName, NSDictionary *dictionary) { return TestModel.class; };
    
    converter.convertToEnum = ^NSInteger (NSString *propertyName, id propertyValue, Class parentClass) {
        NSString *str = (NSString *)propertyValue;
        
        if ([str isEqualToString:@"juhu"] && parentClass == TestModel.class) {
            return TestModelEnumTypeB;
        }
        
        return TestModelEnumTypeA;
    };
    
    NSDictionary *dict = @{ @"enumProperty" : @"juhu" };
    
    TestModel *resultModel = [converter composeModelFromObject:dict];
    XCTAssertEqual(resultModel.enumProperty, TestModelEnumTypeB, @"");
}

- (void)testConvertPropertyFromEnum {
    converter.identifyDict = ^Class (NSString *dictName, NSDictionary *dictionary) { return TestModel.class; };
    
    converter.convertFromEnum = ^NSString *(NSString *propertyName, id propertyValue, Class parentClass) {
        if ([propertyName isEqualToString:@"enumProperty"]) {
            NSNumber *value = (NSNumber *) propertyValue;
            
            switch (value.integerValue) {
                case TestModelEnumTypeA: return @"no";
                case TestModelEnumTypeB: return @"juhu";
                default: return nil;
            }
        }
        
        return nil;
    };
    
    TestModel *testModel = [[TestModel alloc] init];
    testModel.enumProperty = TestModelEnumTypeB;
    
    NSDictionary *resultDict = [converter convertToDictionary:testModel];
    
    NSString *resultEnum = resultDict[@"enumProperty"];
    XCTAssertNotNil(resultEnum, @"");
    XCTAssertTrue([resultEnum isEqualToString:@"juhu"], @"");
}

- (void)testConvertPropertyToEnumWithCustomMapping {
    converter.identifyDict = ^Class (NSString *dictName, NSDictionary *dictionary) { return TestModel.class; };
    
    converter.convertToEnum = ^NSInteger (NSString *propertyName, id propertyValue, Class parentClass) {
        NSString *str = (NSString *)propertyValue;
        
        if ([str isEqualToString:@"juhu"] && parentClass == TestModel.class) {
            return TestModelEnumTypeB;
        }
        
        return TestModelEnumTypeA;
    };
    
    NSDictionary *dict = @{ @"enumProperty2" : @"juhu" };
    
    TestModel *resultModel = [converter composeModelFromObject:dict];
    XCTAssertEqual(resultModel.customMappedProperty, TestModelEnumTypeB, @"");
}

- (void)testConvertPropertyFromEnumWithCustomMapping {
    converter.identifyDict = ^Class (NSString *dictName, NSDictionary *dictionary) { return TestModel.class; };
    
    converter.convertFromEnum = ^NSString *(NSString *propertyName, id propertyValue, Class parentClass) {
        if ([propertyName isEqualToString:@"customMappedProperty"]) {
            NSNumber *value = (NSNumber *) propertyValue;
            
            switch (value.integerValue) {
                case TestModelEnumTypeA: return @"no";
                case TestModelEnumTypeB: return @"juhu";
                default: return nil;
            }
        }
        
        return nil;
    };
    
    TestModel *testModel = [[TestModel alloc] init];
    testModel.customMappedProperty = TestModelEnumTypeB;
    
    NSDictionary *resultDict = [converter convertToDictionary:testModel];
    
    NSString *resultEnum = resultDict[@"enumProperty2"];
    XCTAssertNotNil(resultEnum, @"");
    XCTAssertTrue([resultEnum isEqualToString:@"juhu"], @"");
}

- (void)testConvertPropertyToEnumWithSnakeCase {
    converter.identifyDict = ^Class (NSString *dictName, NSDictionary *dictionary) { return TestModel.class; };
    
    converter.convertToEnum = ^NSInteger (NSString *propertyName, id propertyValue, Class parentClass) {
        NSString *str = (NSString *)propertyValue;
        
        if ([str isEqualToString:@"juhu"] && parentClass == TestModel.class) {
            return TestModelEnumTypeB;
        }
        
        return TestModelEnumTypeA;
    };
    converter.enableSnakeCaseSupport = YES;
    
    NSDictionary *dict = @{ @"snake_case_enum_property" : @"juhu" };
    
    TestModel *resultModel = [converter composeModelFromObject:dict];
    XCTAssertEqual(resultModel.snakeCaseEnumProperty, TestModelEnumTypeB, @"");
}

- (void)testConvertPropertyFromEnumWithCustomMapping2 {
    converter.identifyDict = ^Class (NSString *dictName, NSDictionary *dictionary) { return TestModel.class; };
    
    converter.convertFromEnum = ^NSString *(NSString *propertyName, id propertyValue, Class parentClass) {
        if ([propertyName isEqualToString:@"snakeCaseEnumProperty"]) {
            NSNumber *value = (NSNumber *) propertyValue;
            
            switch (value.integerValue) {
                case TestModelEnumTypeA: return @"no";
                case TestModelEnumTypeB: return @"juhu";
                default: return nil;
            }
        }
        
        return nil;
    };
    converter.enableSnakeCaseSupport = YES;
    
    TestModel *testModel = [[TestModel alloc] init];
    testModel.snakeCaseEnumProperty = TestModelEnumTypeB;
    
    NSDictionary *resultDict = [converter convertToDictionary:testModel];
    
    NSString *resultEnum = resultDict[@"snake_case_enum_property"];
    XCTAssertNotNil(resultEnum, @"");
    XCTAssertTrue([resultEnum isEqualToString:@"juhu"], @"");
    
    NSString *wrongKeyEnum = resultDict[@"snakeCaseEnumProperty"];
    XCTAssertNil(wrongKeyEnum, @"result shouldn't contain this key!");
}

#pragma mark - Ignore

- (void)testIgnorePropertiesFromJSON {
    converter.identifyDict = ^Class (NSString *dictName, NSDictionary *dictionary) { return TestModel.class; };
    
    TestModel *testModel = [[TestModel alloc] init];
    testModel.ignoreProperty = @"ignore me";
    
    NSDictionary *resultDict = [converter convertToDictionary:testModel];
    
    XCTAssertNil(resultDict[@"ignoreProperty"], @"");
}

- (void)testIgnorePropertiesToJSON {
    converter.identifyDict = ^Class (NSString *dictName, NSDictionary *dictionary) { return TestModel.class; };
    
    NSDictionary *dict = @{ @"ignoreProperty" : @"ignore me" };
    
    TestModel *resultModel = [converter composeModelFromObject:dict];
    XCTAssertNil(resultModel.ignoreProperty, @"");
}

- (void)testIgnorePropertiesFromJSONWithCustomMapping {
    converter.identifyDict = ^Class (NSString *dictName, NSDictionary *dictionary) { return TestModel.class; };
    
    TestModel *testModel = [[TestModel alloc] init];
    testModel.customMappedIgnoreProperty = @"ignore me";
    
    NSDictionary *resultDict = [converter convertToDictionary:testModel];
    
    XCTAssertNil(resultDict[@"ignoreProperty2"], @"");
}

- (void)testIgnorePropertiesToJSONWithCustomMapping {
    converter.identifyDict = ^Class (NSString *dictName, NSDictionary *dictionary) { return TestModel.class; };
    
    NSDictionary *dict = @{ @"ignoreProperty2" : @"ignore me" };
    
    TestModel *resultModel = [converter composeModelFromObject:dict];
    XCTAssertNil(resultModel.customMappedIgnoreProperty, @"");
}

- (void)testIgnorePropertiesFromJSONWithSnakeCase {
    converter.identifyDict = ^Class (NSString *dictName, NSDictionary *dictionary) { return TestModel.class; };
    converter.enableSnakeCaseSupport = YES;
    
    TestModel *testModel = [[TestModel alloc] init];
    testModel.snakeCaseIgnoreProperty = @"ignore me";
    
    NSDictionary *resultDict = [converter convertToDictionary:testModel];
    
    XCTAssertNil(resultDict[@"snake_case_ignore_property"], @"");
    XCTAssertNil(resultDict[@"snakeCaseIgnoreProperty"], @"");
}

- (void)testIgnorePropertiesToJSONWithSnakeCase {
    converter.identifyDict = ^Class (NSString *dictName, NSDictionary *dictionary) { return TestModel.class; };
    converter.enableSnakeCaseSupport = YES;
    
    NSDictionary *dict = @{ @"snake_case_ignore_property" : @"ignore me" };
    
    TestModel *resultModel = [converter composeModelFromObject:dict];
    XCTAssertNil(resultModel.snakeCaseIgnoreProperty, @"");
}

@end
