//
//  JAGPropertyFinder.m
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

#import "JAGPropertyFinder.h"
#import "JAGProperty.h"
#import <objc/runtime.h>


@implementation JAGPropertyFinder


+ (NSArray *)propertiesForSubclass: (Class) subclass;
{
    unsigned int count;
    objc_property_t *list = class_copyPropertyList(subclass, &count);
    
    NSMutableArray* propertyArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        [propertyArray addObject: [JAGProperty propertyWithObjCProperty: list[i]]];
    }
    free(list);
    return propertyArray;
}

+ (NSArray *)propertiesForClass:(Class)aClass
{
    NSMutableArray *propertyArray = [NSMutableArray array];
    while (aClass && (aClass != [NSObject class]) ) {
        [propertyArray addObjectsFromArray: [self propertiesForSubclass: aClass]];
        aClass = [aClass superclass];
    }
    return propertyArray; 
}

+ (JAGProperty *)propertyForName: (NSString *)name inClass:(__unsafe_unretained Class)aClass
{
    objc_property_t property = class_getProperty(aClass, [name UTF8String]);
    if(!property) return nil;
    return [JAGProperty propertyWithObjCProperty: property];
}

+ (NSArray*) propertyNamesForClass: (Class) aClass {
    NSArray *propertyArray = [self propertiesForClass: aClass];
    NSMutableArray *propertyNames = [NSMutableArray arrayWithCapacity:[propertyArray count]];
    for (JAGProperty *property in propertyArray) {
        [propertyNames addObject:property.name];
    }
    return propertyNames;
}

@end
