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

@interface JAGPropertyFinder : NSObject

/**
 * The properties defined in the subclass, but not
 * defined in its superclasses.
 * @param subclass Class to look for property in.
 * @return an NSArray of JAGProperties
 */
+ (NSArray *)propertiesForSubclass: (Class) subclass;

/**
 * The properties defined for this class, including
 * those defined in its superclasses.  It skips
 * properties defined in NSObject.
 * @param aClass Class to look for the property in.
 * @return an NSArray of JAGProperties
 */
+ (NSArray *)propertiesForClass: (Class) aClass;

/**
 * Find a property with the name in the defined
 * class.
 * @param name Name of property to return
 * @param subclass Class to look for property in.
 * @return named JAGProperty defined in this subclass, or nil if not found.
 */
+ (JAGProperty *)propertyForName: (NSString *)name inClass: (Class) subclass;

/**
 * Return an NSArray of NSStrings with the names of the properties
 * defined for the class (including its superclasses).
 * @param aClass the class containing the properties.
 */
+ (NSArray*) propertyNamesForClass: (Class) aClass;

@end
