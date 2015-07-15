//
//  JAGPropertyConverterWithKeypathMappingTest.m
//  JAGPropertyConverter
//
//  Created by Stanislav Stavrev on 06/03/15.
//
//

#import <XCTest/XCTest.h>
#import "TestModel.h"
#import "JAGPropertyConverter.h"

@interface JAGPropertyConverterWithKeypathMappingTest : XCTestCase {
@private
    TestModel *model;
    JAGPropertyConverter *converter;
}

@end

@implementation JAGPropertyConverterWithKeypathMappingTest

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
    XCTAssertEqualObjects(testModel.modelProperty.testModelID, [dict valueForKeyPath:@"modelProperty.testModelID"],
                         @"Model and Dictionary should have same modelProperty");
    XCTAssertEqualObjects(testModel.arrayProperty, [dict valueForKey:@"arrayProperty"],
                         @"Model and Dictionary should have same arrayProperty");
    XCTAssertEqualObjects(testModel.dictionaryProperty, [dict valueForKey:@"dictionaryProperty"],
                         @"Model and Dictionary should have same dictionaryProperty");
    XCTAssertEqual(testModel.intProperty, [[dict valueForKey:@"intProperty"] intValue],
                   @"Model and Dictionary should have same intProperty");
}

- (void) testKeypathPropertiesToDictionaryJSON {
    converter.outputType = kJAGJSONOutput;
    NSDictionary *dict = [converter convertToDictionary:model];
    NSLog(@"Converted to dictionary.");
    [self assert:model isEqualTo:dict];

    XCTAssertEqual(dict[@"keypathProperty1"], model.modelProperty.testModelID, @"JSON Dictionary should have set the keypath property properly.");
    XCTAssertEqual(dict[@"keypathProperty2"], model.modelProperty.modelProperty.testModelID, @"JSON Dictionary should have set the keypath property properly.");
}


- (void)testToModelWithKeypathCustomMapping {
    // custom mapping is directly implemented by TestModel with <JAGPropertyMapping>
    NSDictionary *dict = @{@"testModelID": @"M123122",
                           @"keypathProperty1": @"MPID001",
                           @"keypathProperty2": @"MPID002"};

    TestModel *testModel = [TestModel testModel];
    [converter setPropertiesOf:testModel fromDictionary:dict];

    XCTAssertEqual(testModel.modelProperty.testModelID, @"MPID001", @"Converted property not the same.");
    XCTAssertEqual(testModel.modelProperty.modelProperty.testModelID, @"MPID002", @"Converted property not the same.");
}

- (void) testSetKeypathPropertyJSON {
    NSDictionary *testModelDict = @{@"testModelID": @"G653",
                                    @"stringProperty": @"Happy",
                                    @"keypathProperty1": @"MPID001",
                                    @"keypathProperty2": @"MPID002"};

    TestModel *testModel = [converter composeModelFromObject:testModelDict];

    XCTAssertEqual(testModel.modelProperty.testModelID, @"MPID001", @"Converted property not the same.");
    XCTAssertEqual(testModel.modelProperty.modelProperty.testModelID, @"MPID002", @"Converted property not the same.");
}

- (void) testSetDirectKeypathPropertyJSON {
    NSDictionary *testModelDict = @{@"testModelID": @"G653",
                                    @"modelProperty.intProperty": @(1337),
                                    @"modelProperty.modelProperty.intProperty": @(13377331),
                                    @"modelProperty.modelProperty.stringProperty": @(10920)};

    TestModel *testModel = [converter composeModelFromObject:testModelDict];

    XCTAssertEqual(testModel.modelProperty.intProperty, 1337, @"Converted property not the same.");
    XCTAssertEqual(testModel.modelProperty.modelProperty.intProperty, 13377331, @"Converted property not the same.");
}

- (void)testKeypathPropertyWithWrongTypeOfValue {
    NSDictionary *testModelDict = @{@"testModelID": @(999),
                                    @"stringProperty": @(888),
                                    @"keypathProperty1": @(1111),
                                    @"keypathProperty2": @(777),
                                    @"modelProperty.arrayProperty": @(1337),
                                    @"modelProperty.modelProperty.intProperty": @"1337",
                                    @"modelProperty.stringProperty": [NSNull null]};

    TestModel *testModel = [converter composeModelFromObject:testModelDict];

    XCTAssertNil(testModel.modelProperty.testModelID, @"Converter is passed wrong value type. Property should be nil.");
    XCTAssertNil(testModel.modelProperty.modelProperty.testModelID, @"Converter is passed wrong value type. Property should be nil.");
    XCTAssertNil(testModel.modelProperty.stringProperty, @"Converter is passed wrong value type. Property should be nil.");
    XCTAssertEqual(testModel.modelProperty.modelProperty.intProperty, 0, @"Converter is passed wrong value type. Property should be nil.");
    XCTAssertNil(testModel.modelProperty.arrayProperty, @"Converter is passed wrong value type. Property should be nil.");
}

- (void)testKeypathPropertyWithNullValue {
    NSDictionary *testModelDict = @{@"testModelID": @"G653",
                                    @"modelProperty.modelProperty.setProperty": [NSNull null]};

    TestModel *testModel = [converter composeModelFromObject:testModelDict];

    XCTAssertNil(testModel.modelProperty.modelProperty.setProperty, @"setProperty should be nil.");
}

- (void) testKeypathJSON {
    converter.outputType = kJAGJSONOutput;
    NSDictionary *dict = [converter decomposeObject:model];

    id keypathPropertyValue1 = [dict valueForKey:@"keypathProperty1"];
    XCTAssertNotNil(keypathPropertyValue1, @"Converted keypathProperty1 should not be nil.");
    XCTAssertTrue([keypathPropertyValue1 isKindOfClass:[NSString class]],
                 @"keypathProperty1 %@ should be converted to an NSString for JSON.", keypathPropertyValue1);

    id keypathPropertyValue2 = [dict valueForKey:@"keypathProperty2"];
    XCTAssertNotNil(keypathPropertyValue2, @"Converted keypathProperty2 should not be nil.");
    XCTAssertTrue([keypathPropertyValue2 isKindOfClass:[NSString class]],
                 @"keypathProperty2 %@ should be converted to an NSString for JSON.", keypathPropertyValue2);

    TestModel *returnedModel = [[TestModel alloc] initWithPropertiesFromDictionary:dict];
    XCTAssertEqualObjects(model.modelProperty.testModelID, returnedModel.modelProperty.testModelID,  @"modelProperty should be unchanged over serialization/deserialization.");
    XCTAssertEqualObjects(model.modelProperty.modelProperty.testModelID, returnedModel.modelProperty.modelProperty.testModelID,  @"modelProperty should be unchanged over serialization/deserialization.");
}

@end
