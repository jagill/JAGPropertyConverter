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


#import <objc/runtime.h>


typedef enum
{
    JAGPropertySetterSemanticsAssign,
    JAGPropertySetterSemanticsRetain,
    JAGPropertySetterSemanticsCopy
}
JAGPropertySetterSemantics;

@interface JAGProperty : NSObject

+ (id)propertyWithObjCProperty: (objc_property_t)property;

- (id)initWithObjCProperty: (objc_property_t)property;

/**
 * A comma-separated list of attributes.  Possible attributes are:
 R              The property is read-only (readonly).
 C              The property is a copy of the value last assigned (copy).
 &              The property is a reference to the value last assigned (retain).
 N              The property is non-atomic (nonatomic).
 G<name>        The property defines a custom getter selector name. The name follows the G (for example, GcustomGetter,).
 S<name>        The property defines a custom setter selector name. The name follows the S (for example, ScustomSetter:,).
 D              The property is dynamic (@dynamic).
 W              The property is a weak reference (__weak).
 P              The property is eligible for garbage collection.
 t<encoding>    Specifies the type using old-style encoding.
 */
- (NSString *)attributeEncodings;

/**
 * A String denoting the scalar/object type of the property.
 * Note that for objects, the return is @"CLASS_NAME".
 c                  A char (including BOOL)
 i                  An int
 s                  A short
 l                  A long
                    l is treated as a 32-bit quantity on 64-bit programs.
 q                  A long long
 C                  An unsigned char
 I                  An unsigned int
 S                  An unsigned short
 L                  An unsigned long
 Q                  An unsigned long long
 f                  A float
 d                  A double
 B                  A C++ bool or a C99 _Bool
 v                  A void
 *                  A character string (char *)
 @                  An object (whether statically typed or typed id).
                    For statically typed objects, it is of the form: @"NSString"
 #                  A class object (Class)
 :                  A method selector (SEL)
 [array type]       An array, eg [12^f]
 {name=type...}     A structure, eg {example=@*i}
 (name=type...)     A union
 bNUM               A bit field of num bits
 ^type              A pointer to type, eg ^i
 ?                  An unknown type (among other things, this code is used for function pointers)
 */
- (NSString *)typeEncoding;

- (NSString *)oldTypeEncoding;

///@return name of backing ivar
- (NSString *)ivarName;

/**
 * @return whether property is assign, retain, or copy.
 */
- (JAGPropertySetterSemantics)setterSemantics;

///@return name of property
- (NSString *)name;

///@return true if property has R attribute.
- (BOOL)isReadOnly;

///@return true if property has N attribute.
- (BOOL)isNonAtomic;

///@return true if property has D attribute.
- (BOOL)isDynamic;

///@return true if property has W attribute.
- (BOOL)isWeakReference;

/**
 * The "W" attribute works for garbage-collected environments, but it does not
 * detect ARC weak references.  These are detected by an assign-pointer to an object.
 *
 * @return true if property has W attribute, or is an Object and has setter semantics JAGPropertySetterSemanticsAssign
 */
- (BOOL)isWeak;

///@return true if property has P attribute.
- (BOOL)isEligibleForGarbageCollection;

///@return true if the property is char (signed or unsigned) or char array
- (BOOL) isCharacterType;

///@return true if the property is any sort of integer, float, char, or BOOL
- (BOOL) isNumber;

///@return true if the property is for a Number, Bool, or CharacterType
- (BOOL) isScalar;

///@return true if the property is for an NSObject subclass
- (BOOL) isObject;

/**
 * The class of the property, if it is a defined object.
 * If it is an id or not an object, return nil.
 * @return the Class of the property, or nil if undefined.  
 */
- (Class) propertyClass;

///@return true if the property is for an NSArray or NSSet subclass
- (BOOL) isCollection;

///@return selector for custom getter.  Nil if no custom getter.
- (SEL)customGetter;

/**
 * @return selector for getter.  
 * Defaults to @selector(propertyname) if no custom getter.
 */
- (SEL)getter;

///@return selector for custom setter.  Nil if no custom setter.
- (SEL)customSetter;

/**
 * @return selector for setter.  
 * Defaults to @selector(setPropertyname:) if no custom getter.
 */
- (SEL)setter;


@end
