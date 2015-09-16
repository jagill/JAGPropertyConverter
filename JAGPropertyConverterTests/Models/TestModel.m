//
//  TestModel.m
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

#import "TestModel.h"
#import "JAGPropertyConverter.h"

@interface TestModel ()


@end

@implementation TestModel

@synthesize testModelID=_testModelID;
@synthesize intProperty=_intProperty;
@synthesize stringProperty=_stringProperty;
@synthesize modelProperty=_modelProperty;
@synthesize arrayProperty=_arrayProperty;
@synthesize setProperty=_setProperty;
@synthesize dictionaryProperty=_dictionaryProperty;
@synthesize dateProperty = _dateProperty;
@synthesize cfProperty = _cfProperty;
@synthesize boolProperty = _boolProperty;
@synthesize urlProperty = _urlProperty;
@synthesize readOnlyProperty = _readOnlyProperty;
@synthesize active = _active;
@synthesize weakProperty = _weakProperty;
@synthesize blockProperty = _blockProperty;
@synthesize idProperty = _idProperty;

+ (JAGPropertyConverter *) testConverter {
    JAGPropertyConverter *converter = [JAGPropertyConverter converterWithOutputType:kJAGPropertyListOutput];
    converter.identifyDict = ^ Class (NSString *propertyName, NSDictionary *dict) {
        if ([dict valueForKey:@"testModelID"])
            return [TestModel class];
        return nil;
    };
    converter.classesToConvert = [NSSet setWithObject:[TestModel class]];

    return converter;
}
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id) initWithPropertiesFromDictionary: (NSDictionary*) values {
    self = [super init];
    if (self) {
        [self setPropertiesFromDictionary:values];
    }
    
    return self;    
}

- (void) setPropertiesFromDictionary: (NSDictionary*) values {
    [[TestModel testConverter] setPropertiesOf:self fromDictionary:values];
}

- (NSDictionary*) propertiesAsDictionary {
    return [[TestModel testConverter] convertToDictionary:self];
}

- (void) populate
{
    self.testModelID = @"XYZZ1";
    self.intProperty = 5;
    self.stringProperty = @"Hello Kitty!";
    self.modelProperty = [TestModel testModel];
    self.modelProperty.testModelID = @"KOPES56";
    self.modelProperty.modelProperty = [TestModel testModel];
    self.modelProperty.modelProperty.testModelID = @"KPATH101";
    self.arrayProperty = [NSArray arrayWithObjects:@"red", @"green", @"blue", nil];
    self.setProperty = [NSSet setWithObjects:@"alpha", @"beta", @"gamma", nil];
    self.dictionaryProperty = [NSDictionary dictionaryWithObjectsAndKeys: 
                               [NSNumber numberWithInt:1], @"one",
                               [NSNumber numberWithBool:NO], @"false", 
                               @"Harry", @"Potter",
                               nil];
    self.dateProperty = [NSDate date];
    CLLocationCoordinate2D center;
    center.latitude = 44.40;
    center.longitude = -120.71;
    self.cfProperty = center;
    self.boolProperty = YES;
    self.urlProperty = [NSURL URLWithString:@"http://www.gooogle.com"];
    self.differentNameProperty = @"Some New Property this is";
}

+ (TestModel*) testModel {
    return [[TestModel alloc] init];
}

+ (Class) findClassForDictionary: (NSDictionary *)dictionary {
    NSString *testModelID = [dictionary valueForKey:@"testModelID"];
    if (testModelID)
        return [TestModel class];
    return nil;
}

- (CLLocationCoordinate2D) coordinate
{
	CLLocationCoordinate2D result;
	result.latitude = -40.0;
	result.longitude = 121.0;
	
	return result;
}

- (BOOL) isActive {
    return _active;
}

- (void) makeActive:(BOOL)active {
    _active = active;
}

#pragma mark - JAGPropertyMapping

+ (NSDictionary *)customPropertyNamesMapping {
    return @{@"differentNameProperty" : @"someProperty",
             @"customMappedProperty" : @"enumProperty2",
             @"customMappedIgnoreProperty" : @"ignoreProperty2",
             @"modelProperty.testModelID" : @"keypathProperty1",
             @"modelProperty.modelProperty.testModelID" : @"keypathProperty2"};
}

+ (NSDictionary *)enumPropertiesToConvert {
    return @{@"enumProperty" : @"enumProperty",
             @"customMappedProperty" : @"enumProperty2",
             @"snakeCaseEnumProperty" : @"snake_case_enum_property",
             };
}

+ (NSArray *)ignorePropertiesFromJSON {
    return @[@"ignoreProperty", @"ignoreProperty2", @"snake_case_ignore_property"];
}

+ (NSArray *)ignorePropertiesToJSON {
    return @[@"ignoreProperty", @"customMappedIgnoreProperty", @"snakeCaseIgnoreProperty"];
}

@end

@implementation TestModelSubclass

@synthesize subclassStringProperty = _subclassStringProperty;

- (void) populate {
    [super populate];
    self.subclassStringProperty = @"Subclass String!";
}

@end
