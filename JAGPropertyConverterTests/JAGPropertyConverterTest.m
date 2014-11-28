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
    converter.identifyDict = ^ Class (NSDictionary *dict)  {
        if ([dict valueForKey:@"testModelID"]) {
            return [TestModel class];
        }
        return nil;

    };
}

- (void) assert: (TestModel*) testModel isEqualTo: (NSDictionary*) dict {
    STAssertEqualObjects(testModel.testModelID, [dict valueForKey:@"testModelID"], 
                         @"Model and Dictionary should have same testModelID");
    STAssertEqualObjects(testModel.stringProperty, [dict valueForKey:@"stringProperty"], 
                         @"Model and Dictionary should have same stringProperty");
    STAssertEqualObjects(testModel.modelProperty.testModelID, [dict valueForKeyPath:@"modelProperty.testModelID"], 
                         @"Model and Dictionary should have same modelProperty");
    STAssertEqualObjects(testModel.arrayProperty, [dict valueForKey:@"arrayProperty"], 
                         @"Model and Dictionary should have same arrayProperty");
    STAssertEqualObjects(testModel.dictionaryProperty, [dict valueForKey:@"dictionaryProperty"], 
                         @"Model and Dictionary should have same dictionaryProperty");
    STAssertEquals(testModel.intProperty, [[dict valueForKey:@"intProperty"] intValue], 
                         @"Model and Dictionary should have same intProperty");    
}

- (void) testToDictionaryJSON {
    converter.outputType = kJAGJSONOutput;
    NSDictionary *dict = [converter convertToDictionary:model];
    NSLog(@"Converted to dictionary.");
    [self assert:model isEqualTo:dict];
    STAssertNil([dict valueForKey:@"dateProperty"], @"JSON Dictionary should not have a date value.");
    STAssertNil([dict valueForKey:@"cfProperty"], @"JSON Dictionary should not have a CF value.");
    
}

- (void) testToDictionaryPropertyList {
    converter.outputType = kJAGPropertyListOutput;
    NSDictionary *dict = [converter convertToDictionary:model];
    [self assert:model isEqualTo:dict];
    STAssertEqualObjects(model.dateProperty, [dict valueForKey:@"dateProperty"], @"PropertyList Dictionary should have a date value.");
    STAssertNil([dict valueForKey:@"cfProperty"], @"PropertyList Dictionary should not have a CF value.");
    
}

- (void) testToDictionaryFull {
    converter.outputType = kJAGFullOutput;
    NSDictionary *dict = [converter convertToDictionary:model];
    [self assert:model isEqualTo:dict];
    STAssertEqualObjects(model.dateProperty, [dict valueForKey:@"dateProperty"], @"Full Dictionary should have a date value.");
    NSValue *cfValue = [dict valueForKey:@"cfProperty"];
    STAssertNotNil(cfValue, @"Full Dictionary should have a CF value.");
    
    
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
    // custom mapping is directly implemented by TestModel with <JAGPropertyMappingProtocol>
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"M123122", @"testModelID",
                          [NSNumber numberWithInt:5], @"intProperty",
                          [NSNumber numberWithBool:YES], @"boolProperty",
                          @"new name" , @"someProperty",
                          nil];
    TestModel *testModel = [TestModel testModel];
    [converter setPropertiesOf:testModel fromDictionary:dict];
    
    STAssertNotNil(testModel.differentNameProperty, @"");
    STAssertEqualObjects(testModel.differentNameProperty, @"new name", @"");
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
    STAssertNotNil(setValue, @"Converted setProperty should not be nil.");
    STAssertTrue([setValue isKindOfClass:[NSArray class]], 
                 @"setProperty %@ should be converted to an NSArray for JSON.", setValue);
    NSSet *setFromArray = [NSSet setWithArray:setValue];
    STAssertEqualObjects(model.setProperty, setFromArray, @"Converted setProperty should have same objects.");
    TestModel *returnedModel = [[TestModel alloc] initWithPropertiesFromDictionary:dict];
    STAssertEqualObjects(model.setProperty, returnedModel.setProperty,  @"setProperty should be unchanged over serialization/deserialization.");
}

- (void) testURLPropertyJSON {
    converter.outputType = kJAGJSONOutput;
    NSDictionary *dict = [converter decomposeObject:model];
    id urlValue = [dict valueForKey:@"urlProperty"];
    STAssertNotNil(urlValue, @"Converted urlProperty should not be nil.");
    STAssertTrue([urlValue isKindOfClass:[NSString class]], 
                 @"urlValue %@ should be converted to an NSString for JSON.", urlValue);
    NSURL *urlFromArray = [NSURL URLWithString:urlValue];
    STAssertEqualObjects(urlFromArray, model.urlProperty, @"URL property should have same absolute string.");
}

- (void) testURLPropertyJSONDeserialize {
    converter.outputType = kJAGJSONOutput;
    NSDictionary *dict = [converter decomposeObject:model];
    TestModel *model2 = [TestModel testModel];
    [model2 setPropertiesFromDictionary:dict];
    STAssertNotNil(model2.urlProperty, @"urlProperty should not be nil.");
    STAssertTrue([model2.urlProperty isKindOfClass: [NSURL class]], @"urlProperty should be an NSURL.");
    STAssertEqualObjects(model2.urlProperty, model.urlProperty, @"urlProperties should be equal.");
}

- (void) testWeakProperty {
    model.weakProperty = [TestModel testModel];
    converter.outputType = kJAGFullOutput;
    NSDictionary *dict = [converter decomposeObject:model];
    STAssertNil([dict valueForKey:@"weakProperty"], @"By default, converter should not convert weak properties");
}

- (void) testWeakProperty2 {
    model.weakProperty = [TestModel testModel];
    converter.outputType = kJAGFullOutput;
    converter.shouldConvertWeakProperties = YES;
    NSDictionary *dict = [converter decomposeObject:model];
    STAssertNotNil([dict valueForKey:@"weakProperty"], @"By default, converter should not convert weak properties");
}

- (void) testNSArrayWithNSNumberWithBoolFalse {
    NSNumber *falseNum = [NSNumber numberWithBool:NO];
    NSNumber *zeroNum = [NSNumber numberWithInt:0];
    NSArray *array = [NSArray arrayWithObjects:falseNum, zeroNum, nil];
    id decomposed = [converter decomposeObject:array];
    STAssertTrue([decomposed count] == 2, @"Array should have two elements after decomposing.");
    id composed = [converter composeModelFromObject:array];
    STAssertTrue([composed count] == 2, @"Array should have two elements after composing.");
}

- (void) testNSDictWithNSNumberWithBoolFalse {
    NSNumber *falseNum = [NSNumber numberWithBool:NO];
    NSNumber *zeroNum = [NSNumber numberWithInt:0];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          falseNum, @"one", 
                          zeroNum, @"two",
                          nil];
    id decomposed = [converter decomposeObject:dict];
    STAssertTrue([decomposed count] == 2, @"Dict should have two elements after decomposing.");
    id composed = [converter composeModelFromObject:dict];
    STAssertTrue([composed count] == 2, @"Dict should have two elements after composing.");
}

- (void)testIgnoringNSNullValues {
    converter.shouldIgnoreNullValues = YES;
    
    NSDictionary *dict = @{ @"stringProperty" : [NSNull null] };
    
    TestModel *testModel = [TestModel testModel];
    [converter setPropertiesOf:testModel fromDictionary:dict];
    STAssertNil(testModel.stringProperty, @"");
}

- (void)testSnakeCaseSupport1 {
    converter.shouldConvertSnakeCaseToCamelCase = YES;
    
    NSDictionary *dict = @{ @"int_property" : @12345,
                            @"stringProperty" : @"same" };
    
    TestModel *testModel = [TestModel testModel];
    [converter setPropertiesOf:testModel fromDictionary:dict];
    STAssertEquals(testModel.intProperty, 12345, @"camel case property should be set to 12345");
    STAssertEqualObjects(testModel.stringProperty, @"same", @"normal property should also work normally");
}

- (void)testSnakeCaseSupport2 {
    converter.shouldConvertSnakeCaseToCamelCase = YES;
    
    NSDictionary *dict = @{ @"String_Property" : @"same" };
    
    TestModel *testModel = [TestModel testModel];
    [converter setPropertiesOf:testModel fromDictionary:dict];
    STAssertNil(testModel.stringProperty, @"not correct snake case --> nil");
}

@end
