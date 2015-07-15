//
//  JAGPropertyFinderTest.m
//  spotnote-ios
//
//  Created by James Gill on 1/28/12.
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

#import "JAGPropertyFinderTest.h"
#import "TestModel.h"
#import "JAGPropertyFinder.h"
#import "JAGProperty.h"

@implementation JAGPropertyFinderTest

- (void) testPropertiesForSubclass {
    NSArray *properties = [JAGPropertyFinder propertiesForSubclass:[TestModelSubclass class]];
    XCTAssertTrue([properties count] == 1, 
                 @"There should be 1 property in TestModelSubclass, but there are %tu", [properties count]);
    JAGProperty *property = [properties objectAtIndex:0];
    XCTAssertEqualObjects(property.name, @"subclassStringProperty", @"Property should have right name");
    
    
}

- (void) testPropertiesForClass {
    NSArray *properties = [JAGPropertyFinder propertiesForClass:[TestModelSubclass class]];
    XCTAssertTrue([properties count] > 1, 
                 @"There should be more than 1 properties in TestModelSubclass, but there are %tu", [properties count]);
//    JAGProperty *property = [properties objectAtIndex:0];
//    STAssertEqualObjects(property.name, @"subclassStringProperty", @"Property should have right name");
}

- (void) testPropertyForNameSubclass {
    JAGProperty* subclassStringProp = [JAGPropertyFinder propertyForName:@"subclassStringProperty" 
                                                               inClass:[TestModelSubclass class]];
    XCTAssertNotNil(subclassStringProp, @"SubclassStringProp should be found.");
}

- (void) testPropertyForNameSuperclass {
    JAGProperty* stringProp = [JAGPropertyFinder propertyForName:@"stringProperty" 
                                                               inClass:[TestModelSubclass class]];
    XCTAssertNotNil(stringProp, @"StringProp should be found.");
}

@end
