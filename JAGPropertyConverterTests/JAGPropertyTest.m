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
}
@end

@implementation JAGPropertyTest

- (void) setUp {
    converter = [TestModel testConverter];
    model = [TestModel testModel];
}

- (void) testIntProperty {
    JAGProperty *intProp = [JAGPropertyFinder propertyForName:@"intProperty" inClass:[TestModel class]];
    STAssertTrue([[intProp typeEncoding] isEqualToString:@"i"], @"Type encoding should be i, is %@", [intProp typeEncoding]);
    STAssertTrue([intProp isNumber], @"Property should be Number.");
    STAssertFalse([intProp isCharacterType], @"Property should not be CharacterType.");
    STAssertTrue([intProp isScalar], @"Property should be scalar.");
    STAssertFalse([intProp isObject], @"Property should not be object.");
    STAssertEqualObjects([intProp ivarName], @"_intProperty", @"ivarName should be correct.");
    STAssertEquals([intProp setterSemantics], JAGPropertySetterSemanticsAssign, @"Setter semantics should be assign.");
    STAssertEqualObjects([intProp name], @"intProperty", @"Name should be correct.");
    STAssertFalse([intProp isReadOnly], @"intProperty should not be read-only.");
    STAssertNil([intProp propertyClass], @"intProperty should not have a propertyClass.");
}

- (void) testModelProperty {
    JAGProperty *modelProp = [JAGPropertyFinder propertyForName:@"modelProperty" inClass:[TestModel class]];
    STAssertTrue([modelProp isObject], @"Property should be Object.");
    STAssertEquals([modelProp propertyClass], [TestModel class], 
                   @"Return object class is %@, should be %@", [modelProp propertyClass], [TestModel class]);

    STAssertTrue([[modelProp typeEncoding] isEqualToString:@"@\"TestModel\""], 
                 @"Type encoding should be @\"TestModel\", is %@", [modelProp typeEncoding]);
    STAssertFalse([modelProp isNumber], @"Property should not be Number.");
    STAssertFalse([modelProp isCharacterType], @"Property should not be CharacterType.");
    STAssertFalse([modelProp isScalar], @"Property should not be scalar.");
    STAssertEqualObjects([modelProp ivarName], @"_modelProperty", @"ivarName should be correct.");
    STAssertEquals([modelProp setterSemantics], JAGPropertySetterSemanticsRetain, @"Setter semantics should be retain.");
    STAssertEqualObjects([modelProp name], @"modelProperty", @"Name should be correct.");
    STAssertFalse([modelProp isReadOnly], @"Property should not be read-only.");
}

- (void) testStringProperty {
    JAGProperty *stringProp = [JAGPropertyFinder propertyForName:@"stringProperty" inClass:[TestModel class]];
    STAssertTrue([stringProp isObject], @"Property should be Object.");
    STAssertEquals([stringProp propertyClass], [NSString class], 
                   @"Return object class is %@, should be %@", [stringProp propertyClass], [NSString class]);
    
}

- (void) testArrayProperty {
    JAGProperty *arrayProp = [JAGPropertyFinder propertyForName:@"arrayProperty" inClass:[TestModel class]];
    STAssertTrue([arrayProp isObject], @"Property should be Object.");
    STAssertEquals([arrayProp propertyClass], [NSArray class], 
                   @"Return object class is %@, should be %@", [arrayProp propertyClass], [NSArray class]);
    
}

- (void) testSetProperty {
    JAGProperty *setProp = [JAGPropertyFinder propertyForName:@"setProperty" inClass:[TestModel class]];
    STAssertTrue([setProp isObject], @"Property should be Object.");
    STAssertEquals([setProp propertyClass], [NSSet class], 
                   @"Return object class is %@, should be %@", [setProp propertyClass], [NSSet class]);
    
}

- (void) testDictionaryProperty {
    JAGProperty *dictProp = [JAGPropertyFinder propertyForName:@"dictionaryProperty" inClass:[TestModel class]];
    STAssertTrue([dictProp isObject], @"Property should be Object.");
    STAssertEquals([dictProp propertyClass], [NSDictionary class], 
                   @"Return object class is %@, should be %@", [dictProp propertyClass], [NSDictionary class]);
    
}

- (void) testGetter {
    JAGProperty *stringProp = [JAGPropertyFinder propertyForName:@"stringProperty" inClass:[TestModel class]];    
    SEL getter = [stringProp getter];
    STAssertEqualObjects(NSStringFromSelector(getter), @"stringProperty", 
                         @"Property should have stringProperty getter, but has %@",
                         NSStringFromSelector(getter));
}

- (void) testSetter {
    JAGProperty *stringProp = [JAGPropertyFinder propertyForName:@"stringProperty" inClass:[TestModel class]];    
    SEL setter = [stringProp setter];
    STAssertEqualObjects(NSStringFromSelector(setter), @"setStringProperty:", 
                         @"Property should have setStringProperty: setter, but has %@",
                         NSStringFromSelector(setter));
}

- (void) testCustomGetter {
    JAGProperty *activeProp = [JAGPropertyFinder propertyForName:@"active" inClass:[TestModel class]];
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
    JAGProperty *activeProp = [JAGPropertyFinder propertyForName:@"active" inClass:[TestModel class]];
    SEL customSetter = [activeProp customSetter];
    STAssertEqualObjects(NSStringFromSelector(customSetter), @"makeActive:",
                         @"Property should have makeActive: custom setter, but has %@",
                         NSStringFromSelector(customSetter));
    SEL setter = [activeProp setter];
    STAssertEqualObjects(NSStringFromSelector(setter), @"makeActive:", 
                         @"Property should have makeActive: setter, but has %@",
                         NSStringFromSelector(setter));
}

- (void) testIsCollection {
    JAGProperty *stringProp = [JAGPropertyFinder propertyForName:@"stringProperty" inClass:[TestModel class]];
    STAssertFalse([stringProp isCollection], @"String property should not be a collection.");
    JAGProperty *intProp = [JAGPropertyFinder propertyForName:@"intProperty" inClass:[TestModel class]];
    STAssertFalse([intProp isCollection], @"Int property should not be a collection.");
    JAGProperty *setProp = [JAGPropertyFinder propertyForName:@"setProperty" inClass:[TestModel class]];
    STAssertTrue([setProp isCollection], @"Set property should be a collection.");
    JAGProperty *arrayProp = [JAGPropertyFinder propertyForName:@"arrayProperty" inClass:[TestModel class]];
    STAssertTrue([arrayProp isCollection], @"Array property should be a collection.");
    JAGProperty *dictProp = [JAGPropertyFinder propertyForName:@"dictionaryProperty" inClass:[TestModel class]];
    STAssertFalse([dictProp isCollection], @"Dict property should not be a collection.");
    JAGProperty *modelProp = [JAGPropertyFinder propertyForName:@"modelProperty" inClass:[TestModel class]];
    STAssertFalse([modelProp isCollection], @"Model property should not be a collection.");
}

- (void) testWeakProperty {
    JAGProperty *weakProperty = [JAGPropertyFinder propertyForName:@"weakProperty" inClass:[TestModel class]];
    NSLog(@"weakProperty attributeEncodings: %@", [weakProperty attributeEncodings]);
    STAssertTrue([weakProperty isWeak], @"Weak property should have isWeake true.");
}

- (void) testBlockProperty {
    JAGProperty *blockProperty = [JAGPropertyFinder propertyForName:@"blockProperty" inClass:[TestModel class]];
    NSLog(@"blockProperty attributeEncodings: %@", [blockProperty attributeEncodings]);
    STAssertEqualObjects([blockProperty typeEncoding], @"@?", @"Block property should have type encoding @?");
    STAssertTrue([blockProperty isBlock], @"Block property should have isBlock == true");    
}

@end
