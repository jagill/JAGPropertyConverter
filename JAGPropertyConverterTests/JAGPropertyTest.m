//
//  JAGPropertyTest.m
//
//  Created by James Gill on 11/22/11.
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

#import "JAGPropertyTest.h"
#import "TestModel.h"
#import "JAGPropertyConverter.h"
#import "JAGPropertyFinder.h"
#import "JAGProperty.h"

@interface JAGPropertyTest () {
    @private
    JAGPropertyConverter *converter;
    TestModel *model;
    JAGProperty *intProp;
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

@implementation JAGPropertyTest

- (void) setUp {
    converter = [TestModel testConverter];
    model = [TestModel testModel];
    intProp = [JAGPropertyFinder propertyForName:@"intProperty" inClass:[TestModel class]];
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

#pragma mark - Broad tests

- (void) testIntProperty {
    STAssertTrue([[intProp typeEncoding] isEqualToString:@"i"], @"Type encoding should be i, is %@", [intProp typeEncoding]);
    STAssertTrue([intProp isNumber], @"Property should be Number.");
    STAssertFalse([intProp isObject], @"Property should not be object.");
    STAssertEqualObjects([intProp ivarName], @"_intProperty", @"ivarName should be correct.");
    STAssertEquals([intProp setterSemantics], JAGPropertySetterSemanticsAssign, @"Setter semantics should be assign.");
    STAssertEqualObjects([intProp name], @"intProperty", @"Name should be correct.");
    STAssertFalse([intProp isReadOnly], @"intProperty should not be read-only.");
    STAssertNil([intProp propertyClass], @"intProperty should not have a propertyClass.");
}

- (void) testModelProperty {
    STAssertTrue([modelProp isObject], @"Property should be Object.");
    STAssertEquals([modelProp propertyClass], [TestModel class], 
                   @"Return object class is %@, should be %@", [modelProp propertyClass], [TestModel class]);

    STAssertTrue([[modelProp typeEncoding] isEqualToString:@"@\"TestModel\""], 
                 @"Type encoding should be @\"TestModel\", is %@", [modelProp typeEncoding]);
    STAssertFalse([modelProp isNumber], @"Property should not be Number.");
    STAssertEqualObjects([modelProp ivarName], @"_modelProperty", @"ivarName should be correct.");
    STAssertEquals([modelProp setterSemantics], JAGPropertySetterSemanticsRetain, @"Setter semantics should be retain.");
    STAssertEqualObjects([modelProp name], @"modelProperty", @"Name should be correct.");
    STAssertFalse([modelProp isReadOnly], @"Property should not be read-only.");
    STAssertFalse([modelProp isId], @"ModelProeprty should not be isId");
}

#pragma mark - Tests for propertyClass

- (void) testStringProperty {
    STAssertTrue([stringProp isObject], @"Property should be Object.");
    STAssertEquals([stringProp propertyClass], [NSString class], 
                   @"Return object class is %@, should be %@", [stringProp propertyClass], [NSString class]);
    
}

- (void) testArrayProperty {
    STAssertTrue([arrayProp isObject], @"Property should be Object.");
    STAssertEquals([arrayProp propertyClass], [NSArray class], 
                   @"Return object class is %@, should be %@", [arrayProp propertyClass], [NSArray class]);
    
}

- (void) testSetProperty {
    STAssertTrue([setProp isObject], @"Property should be Object.");
    STAssertEquals([setProp propertyClass], [NSSet class], 
                   @"Return object class is %@, should be %@", [setProp propertyClass], [NSSet class]);
    
}

- (void) testDictionaryProperty {
    STAssertTrue([dictProp isObject], @"Property should be Object.");
    STAssertEquals([dictProp propertyClass], [NSDictionary class], 
                   @"Return object class is %@, should be %@", [dictProp propertyClass], [NSDictionary class]);
    
}

#pragma mark - Selector tests

- (void) testGetter {
    SEL getter = [stringProp getter];
    STAssertEqualObjects(NSStringFromSelector(getter), @"stringProperty", 
                         @"Property should have stringProperty getter, but has %@",
                         NSStringFromSelector(getter));
}

- (void) testSetter {
    SEL setter = [stringProp setter];
    STAssertEqualObjects(NSStringFromSelector(setter), @"setStringProperty:", 
                         @"Property should have setStringProperty: setter, but has %@",
                         NSStringFromSelector(setter));
}

- (void) testCustomGetter {
    SEL customGetter = [activeProp customGetter];
    STAssertEqualObjects(NSStringFromSelector(customGetter), @"isActive", 
                         @"Property should have isActive custom getter, but has %@",
                         NSStringFromSelector(customGetter));
    SEL getter = [activeProp getter];
    STAssertEqualObjects(NSStringFromSelector(getter), @"isActive", 
                         @"Property should have isActive getter, but has %@",
                         NSStringFromSelector(getter));
}

- (void) testCustomSetter {
    SEL customSetter = [activeProp customSetter];
    STAssertEqualObjects(NSStringFromSelector(customSetter), @"makeActive:",
                         @"Property should have makeActive: custom setter, but has %@",
                         NSStringFromSelector(customSetter));
    SEL setter = [activeProp setter];
    STAssertEqualObjects(NSStringFromSelector(setter), @"makeActive:", 
                         @"Property should have makeActive: setter, but has %@",
                         NSStringFromSelector(setter));
}

#pragma mark - YES/NO methods

- (void) testIsCollection {
    STAssertFalse([stringProp isCollection], @"String property should not be a collection.");
    STAssertFalse([intProp isCollection], @"Int property should not be a collection.");
    STAssertTrue([setProp isCollection], @"Set property should be a collection.");
    STAssertTrue([arrayProp isCollection], @"Array property should be a collection.");
    STAssertFalse([dictProp isCollection], @"Dict property should not be a collection.");
    STAssertFalse([modelProp isCollection], @"Model property should not be a collection.");
}

- (void) testWeakProperty {
    NSLog(@"weakProperty attributeEncodings: %@", [weakProperty attributeEncodings]);
    STAssertTrue([weakProperty isWeak], @"Weak property should have isWeake true.");
}

- (void) testBlockProperty {
    NSLog(@"blockProperty attributeEncodings: %@", [blockProperty attributeEncodings]);
    STAssertEqualObjects([blockProperty typeEncoding], @"@?", @"Block property should have type encoding @?");
    STAssertTrue([blockProperty isBlock], @"Block property should have isBlock == true");   
    STAssertNil([blockProperty propertyClass], @"Block properties should return nill properties.");
}

- (void) testIdPropertyIsObject {
    STAssertTrue([idProperty isObject], @"idProperty should be object.");
}

- (void) testIdProperyIsId {
    STAssertTrue([idProperty isId], @"idProperty should have isId == true.");
}

#pragma mark - Tests for canAcceptValue:

- (void) testIntCanAcceptNSNumber {
    NSNumber *num = [NSNumber numberWithInt:8];
    STAssertTrue([intProp canAcceptValue:num], @"int properties should be able to accept NSNumber.");
}

- (void) testBoolCanAcceptNSNumber {
    NSNumber *num = [NSNumber numberWithInt:1];
    STAssertTrue([boolProperty canAcceptValue:num], @"BOOL properties should be able to accept NSNumber.");
}

- (void) testBoolCanAcceptNSNumberWithBool {
    NSNumber *num = [NSNumber numberWithBool:YES];
    STAssertTrue([boolProperty canAcceptValue:num], @"BOOL properties should be able to accept NSNumber numberWithBool:.");
}

- (void) testModelCanAcceptSubmodel {
    STAssertTrue([modelProp canAcceptValue:[[TestModelSubclass alloc] init] ], @"TestModel properties should be able to accept TestModelSubclass.");
}

- (void) testStringCanAcceptString {
    STAssertTrue([stringProp canAcceptValue:[[NSString alloc] init] ], @"NSString properties should be able to accept NSString.");    
}

- (void) testStringCannotAcceptNumber {
    STAssertFalse([stringProp canAcceptValue:[NSNumber numberWithInt:8] ], @"NSString properties should not be able to accept NSNumber.");    
}

- (void) testIntCannotAcceptString {
    STAssertFalse([intProp canAcceptValue:[[NSString alloc] init] ], @"int properties should not be able to accept NSString.");    
}

- (void) testIdCanAcceptModel {
    STAssertTrue([idProperty canAcceptValue:[[TestModel alloc] init] ], @"id properties should be able to accept TestModels.");
}

- (void) testModelCanAcceptId {
    id value = [[TestModel alloc] init];
    STAssertTrue([modelProp canAcceptValue:value], @"model properties should be able to accept TestModel-valued ids.");
}

@end
