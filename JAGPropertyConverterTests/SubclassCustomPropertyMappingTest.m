//
//  SubclassCustomPropertyMappingTest.m
//  JAGPropertyConverter
//
//  Created by Yen-Chia Lin on 17.07.15.
//
//

#import <XCTest/XCTest.h>

#import "JAGPropertyConverter.h"
//#import "NSDictionary+JsonString.h"
#import "TestModelCustomSubclass.h"

/** Tests of inherited custom property mapping is working correctly. Even if some subclass in between returns nil for the mappings (TestModelCustomNilSubclass)
 
 TestModel                      // has some mapping
     ^
     |
 TestModelCustomNilSubclass     // returns nil mapping
     ^
     |
 TestModelCustomSubclass        // has some mapping
 
 Resulting mappings dict/array should contain all from all classes (TestModel + TestModelCustomNilSubclass + TestModelCustomSubclass)
 */
@interface SubclassCustomPropertyMappingTest : XCTestCase

@property (nonatomic, strong) TestModelCustomSubclass *model;
@property (nonatomic, strong) JAGPropertyConverter *converter;

@end

@implementation SubclassCustomPropertyMappingTest

- (void)setUp {
    [super setUp];
    self.model = [TestModelCustomSubclass new];
    [self populate];
    
    self.converter = [[JAGPropertyConverter alloc] init];
    self.converter.classesToConvert = [NSSet setWithObject:[TestModel class]];
    self.converter.identifyDict = ^ Class (NSString *dictName, NSDictionary *dict)  {
        if ([dictName isEqualToString:@"dictionaryProperty"]) {
            return nil; // leave NSDictionary as is
        }
        return [TestModelCustomSubclass class];
    };
    self.converter.convertFromEnum = ^NSString *(NSString *propertyName, id propertyValue, Class parentClass) {
        if ([propertyName isEqualToString:@"subclassEnumProperty"] || [propertyName isEqualToString:@"customMappedProperty"]) {
            NSNumber *value = (NSNumber *) propertyValue;
            
            switch (value.integerValue) {
                case TestModelEnumTypeA: return @"no";
                case TestModelEnumTypeB: return @"juhu";
                default: return nil;
            }
        }
        
        return nil;
    };
    
    self.converter.convertToEnum = ^NSInteger (NSString *propertyName, id propertyValue, Class parentClass) {
        NSString *str = (NSString *)propertyValue;
        
        if ([str isEqualToString:@"no"] && parentClass == TestModelCustomSubclass.class) {
            return TestModelEnumTypeA;
        }
        if ([str isEqualToString:@"juhu"] && parentClass == TestModelCustomSubclass.class) {
            return TestModelEnumTypeB;
        }
        return TestModelEnumTypeA;
    };
}

- (void)tearDown {
    [super tearDown];
}

- (void)testInheritedCustomMappingToJSON {
    self.converter.outputType = kJAGJSONOutput;
    NSDictionary *dict = [self.converter convertToDictionary:self.model];
    
    [self assert:self.model isEqualTo:dict];
    
    // mapping from superclass
    XCTAssertEqualObjects(dict[@"someProperty"], @"very different");
    XCTAssertEqualObjects(dict[@"enumProperty2"], @"juhu");
    XCTAssertNil(dict[@"ignoreProperty2"]);
    
    // mapping from subclass
    XCTAssertNil(dict[@"subclassIgnoreProperty"], @"this value should be ignored");
    XCTAssertEqualObjects(dict[@"differentSubclassCustomMapped"], @"custom mapped");
    XCTAssertEqualObjects(dict[@"subclassEnumProperty"], @"no");
}

- (void)testInheritedCustomMappingFromJSON {
    NSDictionary *dict = @{ @"someProperty" : @"very different",
                            @"enumProperty2" : @"juhu",
                            @"ignoreProperty" : @"ignore me",
                            @"ignoreProperty2" : @"ignore me",
                            
                            // subclass values
                            @"subclassIgnoreProperty" : @"also ignore me",
                            @"differentSubclassCustomMapped" : @"custom mapped",
                            @"subclassEnumProperty" : @"no",
                            };
    
    TestModelCustomSubclass *resultModel = [self.converter composeModelFromObject:dict];

    XCTAssertEqualObjects(resultModel.differentNameProperty, @"very different", @"");
    XCTAssertEqual(resultModel.customMappedProperty, TestModelEnumTypeB, @"");
    XCTAssertNil(resultModel.ignoreProperty, @"should be ignored");
    XCTAssertNil(resultModel.customMappedIgnoreProperty, @"should be ignored");
    
    // subclass
    XCTAssertEqualObjects(resultModel.subclassCustomMapped, @"custom mapped", @"");
    XCTAssertEqual(resultModel.subclassEnumProperty, TestModelEnumTypeA, @"");
    XCTAssertNil(resultModel.subclassIgnoreProperty, @"should be ignored");
}

#pragma mark - Benchmarks

- (void)testBenchmarkModelToJson {
    self.converter.outputType = kJAGJSONOutput;
    
    [self measureBlock:^{
        NSDictionary *dict = [self.converter convertToDictionary:self.model];
        
        //NSLog(@"json: \n%@", dict.jsonDescription);
        
        [self assert:self.model isEqualTo:dict];
        
        // mapping from superclass
        XCTAssertEqualObjects(dict[@"someProperty"], @"very different");
        XCTAssertEqualObjects(dict[@"enumProperty2"], @"juhu");
        XCTAssertNil(dict[@"ignoreProperty2"]);
        
        // mapping from subclass
        XCTAssertNil(dict[@"subclassIgnoreProperty"], @"this value should be ignored");
        XCTAssertEqualObjects(dict[@"differentSubclassCustomMapped"], @"custom mapped");
        XCTAssertEqualObjects(dict[@"subclassEnumProperty"], @"no");
    }];
}

- (void)testBenchmarkJsonToModel {
    NSDictionary *dict = [self dictForJsonFile:@"SubclassModelTestData.json"];
    
    XCTAssertNotNil(dict);
    XCTAssertEqual(dict.count, 16u);
    
    [self measureBlock:^{
        TestModelCustomSubclass *resultModel = [self.converter composeModelFromObject:dict];
        
        XCTAssertNotNil(resultModel);
        XCTAssertTrue(resultModel.active);
        XCTAssertTrue(resultModel.boolProperty);
        
        TestModel *model = resultModel.modelProperty;
        XCTAssertNotNil(model);
        XCTAssertTrue(model.active);
        XCTAssertTrue(model.boolProperty);
        
        TestModel *submodel = model.modelProperty;
        XCTAssertNotNil(submodel);
        XCTAssertTrue(submodel.active);
        XCTAssertTrue(submodel.boolProperty);
        
        // no need to assert further properties. already done by other tests.
    }];
}

#pragma mark - Private

- (void)assert:(TestModel *)testModel isEqualTo:(NSDictionary *)dict {
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

- (void) populate {
    [self.model populate];
    
    // superclass
    self.model.differentNameProperty = @"very different";
    self.model.customMappedProperty = TestModelEnumTypeB;
    self.model.customMappedIgnoreProperty = @"surely ignore me";
    
    // subclass
    self.model.subclassEnumProperty = TestModelEnumTypeA;
    self.model.subclassIgnoreProperty = @"pls ignore me :(";
    self.model.subclassCustomMapped = @"custom mapped";
}

// helper methods to load .json files from bundle
- (NSDictionary *)dictForJsonFile:(NSString *)filename {
    NSData *data = [self dataForFile:filename];
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

- (NSData *)dataForFile:(NSString *)filename {
    NSString *filePath = [self pathForFile:filename inBundle:[NSBundle bundleForClass:self.class]];
    return [NSData dataWithContentsOfFile:filePath options:0 error:nil];
}

- (NSString *)pathForFile:(NSString *)filename inBundle:(NSBundle *)bundle {
    return [bundle.bundlePath stringByAppendingPathComponent:filename];
}

@end
