//
//  JAGPropertyFinder.h
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

#import <Foundation/Foundation.h>

@class JAGProperty;

/**
 * TODO: Description and examples.
 */
@interface JAGPropertyFinder : NSObject

/**
 * The properties defined explicitly in the subclass.
 * 
 * This does not return those properties defined in
 * any superclasses.
 * 
 * @param subclass Class that defines the properties.
 * @return NSArray of JAGProperty objects defined in this subclass.
 */
+ (NSArray *)propertiesForSubclass: (Class) subclass;

/**
 * The properties defined for this class, including
 * those defined in its superclasses.
 * 
 * It skips properties defined in NSObject.
 * 
 * @param aClass Class with the properties.
 * @return NSArray of JAGProperty objects defined for this class.
 */
+ (NSArray *)propertiesForClass: (Class) aClass;

/**
 * The property for the class with the given name.
 *
 * This will also return properties defined in the
 * superclasses, NSObject included.
 * 
 * @param name Name of property to return.
 * @param aClass Class with the property.
 * @return JAGProperty defined in this subclass with the given name, or nil if not found.
 */
+ (JAGProperty *)propertyForName: (NSString *)name inClass: (Class) aClass;

/**
 * The names of the properties defined for this class.
 * 
 * This includes those defined for its superclasses,
 * excluding NSObject.
 *
 * @param aClass the class containing the properties.
 * @return NSArray of NSString objects with the property names.
 */
+ (NSArray*) propertyNamesForClass: (Class) aClass;

@end
