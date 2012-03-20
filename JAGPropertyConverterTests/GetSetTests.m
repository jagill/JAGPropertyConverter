//
//  GetSetTests.m
//  JAGPropertyConverter
//
//  Created by James Gill on 3/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GetSetTests.h"
#import "TestModel.h"
#import "JAGProperty.h"
#import "JAGPropertyConverter.h"
#import "JAGPropertyFinder.h"
#import "NSNumber+JAGProperty.h"

@interface GetSetTests () {
@private
    JAGPropertyConverter *converter;
    TestModel *model;
    JAGProperty *intProp;
    JAGProperty *floatProp;
    JAGProperty *modelProp;
    JAGProperty *stringProp;
    JAGProperty *arrayProp;
    JAGProperty *setProp;
    JAGProperty *dictProp;
    JAGProperty *activeProp;
    JAGProperty *weakProperty;
    JAGProperty *blockProperty;
    JAGProperty *idProperty;
    JAGProperty *boolProperty;
    
}
@end


@implementation GetSetTests


- (void) setUp {
    converter = [TestModel testConverter];
    model = [TestModel testModel];
    intProp = [JAGPropertyFinder propertyForName:@"intProperty" inClass:[TestModel class]];
    floatProp = [JAGPropertyFinder propertyForName:@"floatProperty" inClass:[TestModel class]];
    modelProp = [JAGPropertyFinder propertyForName:@"modelProperty" inClass:[TestModel class]];
    stringProp = [JAGPropertyFinder propertyForName:@"stringProperty" inClass:[TestModel class]];
    arrayProp = [JAGPropertyFinder propertyForName:@"arrayProperty" inClass:[TestModel class]];
    setProp = [JAGPropertyFinder propertyForName:@"setProperty" inClass:[TestModel class]];
    dictProp = [JAGPropertyFinder propertyForName:@"dictionaryProperty" inClass:[TestModel class]];
    activeProp = [JAGPropertyFinder propertyForName:@"active" inClass:[TestModel class]];
    weakProperty = [JAGPropertyFinder propertyForName:@"weakProperty" inClass:[TestModel class]];
    blockProperty = [JAGPropertyFinder propertyForName:@"blockProperty" inClass:[TestModel class]];
    idProperty = [JAGPropertyFinder propertyForName:@"idProperty" inClass:[TestModel class]];
    boolProperty = [JAGPropertyFinder propertyForName:@"boolProperty" inClass:[TestModel class]];
}

- (void) testStringPropGet {
    [model populate];
    NSString *retrievedString = [stringProp getFrom:model];
    STAssertNotNil(retrievedString, @"stringProp should be able to get from a model.");
    STAssertEquals(retrievedString, model.stringProperty, @"Retrieved string should be same as on model.");
}

- (void) testStringPropSet {
    NSString *str = @"Happy Days!";
    [stringProp set:str on:model];
    STAssertEquals(model.stringProperty, str, @"stringProp should be able to set on a model.");
}

- (void) testIntPropGet {
    [model populate];
    NSNumber *retrievedIntValue = [intProp getFrom:model];
    STAssertNotNil(retrievedIntValue, @"intProp should be able to get from a model.");
    STAssertTrue([retrievedIntValue intValue] == model.intProperty, @"Retrieved int should be same as on model.");
}

- (void) testIntPropSet {
    int testInt = 7;
    NSNumber *intValue = [NSNumber numberWithInt:testInt];
    [intProp set:intValue on:model];
    STAssertTrue(model.intProperty == testInt, @"intProp should be able to set on a model.");
}

- (void) testFloatPropGet {
    [model populate];
    NSNumber *retrievedFloatValue = [floatProp getFrom:model];
    STAssertNotNil(retrievedFloatValue, @"floatProp should be able to get from a model.");
    STAssertEqualsWithAccuracy([retrievedFloatValue floatValue], model.floatProperty, 0.01, @"Retrieved float should be same as on model.");
    
}

- (void) testFloatPropSet {
    float testFloat = 3.21;
    NSNumber *floatValue = [NSNumber numberWithFloat:testFloat];
    [floatProp set:floatValue on:model];
    STAssertEqualsWithAccuracy(model.floatProperty, testFloat, 0.01, @"Floats should be equal after being set.");
}

- (void) testFloatPropGetSet {
    //In conversions to/from models, we've gotten issues with floats.
    [model populate];
    float initialFloat = model.floatProperty;
    NSNumber *retrievedFloatValue = [floatProp getFrom:model];
    [floatProp set:retrievedFloatValue on:model];
    STAssertEqualsWithAccuracy(initialFloat, model.floatProperty, 0.01, @"Retrieved float should be same as on model.");
    
}

- (void) testFloatPropSetGet {
    //In conversions to/from models, we've gotten issues with floats.
    float testFloat = 3.21;
    NSNumber *floatValue = [NSNumber numberWithFloat:testFloat];
    [floatProp set:floatValue on:model];
    NSNumber *retrievedFloatValue = [floatProp getFrom:model];
    
    STAssertEqualsWithAccuracy([retrievedFloatValue floatValue], testFloat, 0.01, @"Floats should be equal after being set.");
}

- (void) testDoubleToFloatSet {
    double testDouble = 5.772;
    NSNumber *doubleValue = [NSNumber numberWithDouble:testDouble];
    [floatProp set:doubleValue on:model];
    STAssertEqualsWithAccuracy(model.floatProperty, (float)testDouble, 0.01, @"Doubles should be converted to floats correctly.");
}

@end
