//
//  JAGProperty.h
//
//  Created by James Gill on 11/23/12.
//  Based off of Mike Ash's runtime
//  libraries: http://github.com/mikeash/MAObjCRuntime
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
#import <objc/runtime.h>


/**
 * The type of setter for a property.
 * @see setterSemantics for more explanation.
 */
typedef enum
{
    JAGPropertySetterSemanticsAssign,
    JAGPropertySetterSemanticsRetain,
    JAGPropertySetterSemanticsCopy
}
JAGPropertySetterSemantics;

/**
   JAGProperty is an Objective-C wrapper for a class's properties that
   allows dynamic access to information about the property.
   It is backed by an `objc_property_t` object, but provides more friendly
   methods for accessing the information.
  
   Suppose you have properties
  
        @property (nonatomic, readonly, copy) NSString* title;
        @property (assign, getter=getCount) int count;
  
   and synthesizers
  
        @synthesize title = _title;
        @synthesize count;
  
   The JAGProperty object for the first property has a variety of useful methods:
  
        property.name == @"title";
        property.isObject == YES;
        property.propertyClass == [NSString class];
        property.isNumber == NO;
        property.typeEncoding == @"@\"NSString\"";
        property.isNonAtomic == YES;
        property.isReadOnly == YES;
        property.ivarName == @"_title";
        property.customGetter == nil;
        property.getter == @selector(title);
        property.setterSemantics == JAGPropertySetterSemanticsCopy;
  
   The JAGProperty object for the second property also has a variety of useful methods:
  
        property.name == @"count";
        property.isObject == YES;
        property.propertyClass == nil;
        property.isNumber == YES;
        property.typeEncoding == @"i";
        property.isNonAtomic == NO;
        property.isReadOnly == NO;
        property.ivarName == @"count";
        property.customGetter == @selector(getCount);
        property.getter == @selector(getCount);
        property.setterSemantics == JAGPropertySetterSemanticsAssign;
  
   You can construct a JAGProperty with the appropriate `objc_property_t` object, but
   JAGPropertyFinder provides the suggested ways to find properties for a given class.
 */
@interface JAGProperty : NSObject

+ (id)propertyWithObjCProperty: (objc_property_t)property;

- (id)initWithObjCProperty: (objc_property_t)property;

/**
 * A comma-separated list of attributes.
 *
 * Possible attributes are:
 *
 * - `R`              The property is read-only (`readonly`).
 * - `C`              The property is a copy of the value last assigned (`copy`).
 * - `&`              The property is a reference to the value last assigned (`retain`).
 * - `N`              The property is non-atomic (`nonatomic`).
 * - `G<myGetter>`    The property defines a custom getter selector myGetter. The name follows the `G` (for example, `GmyGetter`).
 * - `S<mySetter:>`   The property defines a custom setter selector mySetter. The name follows the `S` (for example, `SmySetter:`).
 * - `D`              The property is dynamic (`@dynamic`).
 * - `W`              The property is a weak reference (`__weak`).
 * - `P`              The property is eligible for garbage collection.
 * - `t<encoding>`    Specifies the type using old-style encoding.
 *
 * @return An NSString of the comma-separated attributes.
 */
- (NSString *)attributeEncodings;

/**
 * An NSString denoting the scalar/object type of the property.
 *
 * Note that for properties for objects with a defined class, the return is the NSString `@"CLASS_NAME"`
 * (including the `@""`, so it's equivalent to `@"@\"CLASS_NAME\""`).
 *
 * - `c`                  A char (including `BOOL`)
 * - `i`                  An int
 * - `s`                  A short
 * - `l`                  A long
 *                        l is treated as a 32-bit quantity on 64-bit programs.
 * - `q`                  A long long
 * - `C`                  An unsigned char
 * - `I`                  An unsigned int
 * - `S`                  An unsigned short
 * - `L`                  An unsigned long
 * - `Q`                  An unsigned long long
 * - `f`                  A float
 * - `d`                  A double
 * - `B`                  A C++ bool or a C99 _Bool
 * - `v`                  A void
 * - `*`                  A character string (`char *`)
 * - `@`                  An object (whether statically typed or typed id).
 *                        For statically typed objects, it is of the form: `@"NSString"`
 *                        Blocks are encoded as `@?`
 * - `#`                  A class object (`Class`)
 * - `:`                  A method selector (`SEL`)
 * - `[array type]`       An array, eg `[12^f]`
 * - `{name=type...}`     A structure, eg `{example=@*i}`
 * - `(name=type...)`     A union
 * - `bNUM`               A bit field of num bits
 * - `^type`              A pointer to type, eg `^i`
 * - `?`                  An unknown type (among other things, this code is used for function pointers)
 *
 * @return An NSString of the type encoding.
 */
- (NSString *)typeEncoding;

- (NSString *)oldTypeEncoding;

/// @return Name of ivar backing the property.
- (NSString *)ivarName;

/**
 * Whether property is assign, retain, or copy.
 *
 * Note that in ARC, `strong` is the same as `retain`, and
 * `weak` is the same as `assign`.
 *
 * @return JAGPropertySetterSemantics for assign, retain, or copy.
 */
- (JAGPropertySetterSemantics)setterSemantics;

/// @return Name of property
- (NSString *)name;

/**
 * Whether the property is readonly.
 *
 * @return YES if property has R attribute.
 */
- (BOOL)isReadOnly;

/**
 * Whether the property is nonatomic.
 *
 * @return YES if property has N attribute.
 */
- (BOOL)isNonAtomic;

/**
 * Whether the property is dynamic.
 *
 * @return YES if property has D attribute.
 */
- (BOOL)isDynamic;

/**
   Whether the property is a __weak reference, with respect to Garbage Collection.
  
   Note this has nothing to do with iOS ARC `weak` label.  An ARC property

        @property (weak) id delegate;

   will have isWeakReference == NO.  @see isWeak for how to handle that case.
  
   @return YES if property has W attribute.
 */
- (BOOL)isWeakReference;

/**
 * Whether the property is a weak pointer, in either OS X Garbage Collection or
 * iOS ARC.
 * 
 * The "W" attribute works for garbage-collected environments, but it does not
 * detect ARC `weak` references.  These are detected by an `assign`-pointer to an object.
 * This also means that an iOS 4 object property with `assign` semantics will also return YES.
 *
 * @return YES if property has W attribute, or is an Object and has setter semantics JAGPropertySetterSemanticsAssign
 */
- (BOOL)isWeak;

/**
 * Whether the object is elegible for Garbage Collection in OS X.
 *
 * @return YES if property has P attribute.
 */
- (BOOL)isEligibleForGarbageCollection;

/// @return YES if the property is any sort of integer, float, char, or BOOL
- (BOOL) isNumber;

/// @return YES if the property is for an NSObject subclass or `id`.
- (BOOL) isObject;

/// @return YES if the property is for a Block
- (BOOL) isBlock;

/// @return YES if the property is for an `id`
- (BOOL) isId;

/**
 * The class of the property, if it is a defined object.
 *
 * If it is an `id` or not an object, return nil.
 * @return The Class of the property, or nil if undefined.  
 */
- (Class) propertyClass;

/// @return YES if the property is for an NSArray or NSSet subclass
- (BOOL) isCollection;

/// @return Selector for custom getter.  Nil if no custom getter.
- (SEL) customGetter;

/**
 * @return Selector for getter.  
 * Defaults to @selector(propertyname) if no custom getter.
 */
- (SEL) getter;

/// @return Selector for custom setter.  Nil if no custom setter.
- (SEL) customSetter;

/**
 * @return Selector for setter.  
 * Defaults to @selector(setPropertyname:) if no custom getter.
 */
- (SEL) setter;

/**
 * Test whether you can `[model setValue:value forKey:[property name]]`
 * without receiving an `NSInvalidArgumentException`.
 *
 * @param value Value to check for acceptance.
 * @return YES if the property can be set with this value.
 *
 * @warning This method is still under development.  We are aiming for it
 * to catch some cases that would lead to an exception, but we are erring
 * on the side of letting bad things through rather than keeping good things out.
 */
- (BOOL) canAcceptValue: (id) value;

@end
