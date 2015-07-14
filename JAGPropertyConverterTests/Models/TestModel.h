//
//  TestModel.h
//  spotnote-ios
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

#import <MapKit/MapKit.h>
#import "JAGPropertyMapping.h"

typedef NS_ENUM(NSInteger, TestModelEnum) {
    TestModelEnumTypeA,
    TestModelEnumTypeB
};

@class JAGPropertyConverter;

@interface TestModel : NSObject <JAGPropertyMapping>

@property (copy)            NSString        *testModelID;
@property (assign)          int             intProperty;
@property (nonatomic, copy) NSString        *stringProperty;
@property (strong)          TestModel       *modelProperty;
@property (strong)          NSArray         *arrayProperty;
@property (strong)          NSSet           *setProperty;
@property (strong)          NSDictionary    *dictionaryProperty;
@property (strong)          NSDate          *dateProperty;
@property (assign)          BOOL            boolProperty;
@property (assign)          CLLocationCoordinate2D cfProperty;
@property (strong)          NSURL           *urlProperty;
@property (strong)          NSString        *readOnlyProperty;
@property (assign, getter = isActive, setter = makeActive:) BOOL            active;
@property (unsafe_unretained)            TestModel       *weakProperty;
@property (copy)            void(^blockProperty)(id);
@property (strong)          id              idProperty;
@property (copy)            NSString        *differentNameProperty;
@property (nonatomic, assign) TestModelEnum enumProperty;
@property (nonatomic, assign) TestModelEnum customMappedProperty;
@property (nonatomic, assign) TestModelEnum snakeCaseEnumProperty;
@property (nonatomic, copy) NSString *ignoreProperty;
@property (nonatomic, copy) NSString *customMappedIgnoreProperty;
@property (nonatomic, copy) NSString *snakeCaseIgnoreProperty;

+ (TestModel*) testModel;

+ (JAGPropertyConverter *) testConverter;

- (id) initWithPropertiesFromDictionary: (NSDictionary*) values;

- (void) setPropertiesFromDictionary: (NSDictionary*) values;

- (NSDictionary*) propertiesAsDictionary;

///Populate model with data for each property.
- (void) populate;

//This method can look like a property; make sure it doesn't mess things up.
- (CLLocationCoordinate2D) coordinate;

@end

@interface TestModelSubclass : TestModel

@property (copy)    NSString        *subclassStringProperty;

@end
