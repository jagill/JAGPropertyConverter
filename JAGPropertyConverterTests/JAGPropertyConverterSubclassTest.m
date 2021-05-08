//
//  JAGPropertyConverterSubclassTest.m
//  JAGPropertyConverter
//
//  Created by Yen-Chia Lin on 24.10.15.
//
//

#import <XCTest/XCTest.h>
#import "TestModel.h"
#import "JAGPropertyConverter+Subclass.h"

@interface JAGPropertyConverterSubclassTest : XCTestCase {
@private
    TestModel *model;
    JAGPropertyConverter *converter;
}

@end

@implementation JAGPropertyConverterSubclassTest

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

- (void)testFindProperty {
    converter.outputType = kJAGJSONOutput;

    // this method crashed before because we were passing nil to *isKeyPath
    JAGProperty *property = [converter findPropertyOfObject:model forKey:@"boolProperty"];
    XCTAssertNotNil(property);
    XCTAssertTrue(property.isBoolean);
}

- (void)testFindPropertyWithKeyPath {
    converter.outputType = kJAGJSONOutput;

    BOOL isKeyPath = NO;
    NSString *remainingKeyPath = nil;
    
    JAGProperty *firstProperty = [converter findPropertyOfObject:model forKey:@"modelProperty.boolProperty" isKeyPath:&isKeyPath remainingKeyPath:&remainingKeyPath];
    XCTAssertNotNil(firstProperty);
    XCTAssertTrue(firstProperty.isObject);
    
    XCTAssertTrue(isKeyPath);
    XCTAssertNotNil(remainingKeyPath);
    XCTAssertEqualObjects(remainingKeyPath, @"boolProperty");
}

@end
