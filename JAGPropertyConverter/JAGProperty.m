//
//  JAGProperty.m
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

#import "JAGProperty.h"

@implementation JAGProperty
{
@private
    objc_property_t     _property;
    NSArray             *_attributes;
}

+ (id)propertyWithObjCProperty: (objc_property_t)property
{
    return [[self alloc] initWithObjCProperty: property];
}

- (id)initWithObjCProperty: (objc_property_t)property
{
    if((self = [self init]))
    {
        _property = property;
        _attributes = [[[NSString stringWithUTF8String: property_getAttributes(property)] componentsSeparatedByString: @","] copy];
    }
    return self;
}


- (NSString *)description
{
    return [NSString stringWithFormat: @"<%@ %p: %@ %@ %@ %@>", [self class], self, [self name], [self attributeEncodings], [self typeEncoding], [self ivarName]];
}

- (BOOL)isEqual: (id)other
{
    return [other isKindOfClass: [JAGProperty class]] &&
    [[self name] isEqual: [other name]] &&
    ([self attributeEncodings] ? [[self attributeEncodings] isEqual: [other attributeEncodings]] : ![other attributeEncodings]) &&
    [[self typeEncoding] isEqual: [other typeEncoding]] &&
    ([self ivarName] ? [[self ivarName] isEqual: [other ivarName]] : ![other ivarName]);
}

- (NSUInteger)hash
{
    return [[self name] hash] ^ [[self typeEncoding] hash];
}

- (NSString *)name
{
    return [NSString stringWithUTF8String: property_getName(_property)];
}

- (NSString *)attributeEncodings
{
    NSPredicate *filter = [NSPredicate predicateWithFormat: @"NOT (self BEGINSWITH 'T') AND NOT (self BEGINSWITH 'V')"];
    return [[_attributes filteredArrayUsingPredicate: filter] componentsJoinedByString: @","];
}

- (BOOL)hasAttribute: (NSString *)code
{
    for(NSString *encoded in _attributes)
        if([encoded hasPrefix: code]) return YES;
    return NO;
}

- (BOOL)isReadOnly
{
    return [self hasAttribute: @"R"];
}

- (JAGPropertySetterSemantics)setterSemantics
{
    if([self hasAttribute: @"C"]) return JAGPropertySetterSemanticsCopy;
    if([self hasAttribute: @"&"]) return JAGPropertySetterSemanticsRetain;
    return JAGPropertySetterSemanticsAssign;
}

- (BOOL)isNonAtomic
{
    return [self hasAttribute: @"N"];
}

- (BOOL)isDynamic
{
    return [self hasAttribute: @"D"];
}

- (BOOL)isWeakReference
{
    return [self hasAttribute: @"W"];
}

- (BOOL)isWeak {
    return [self isWeakReference] || ([self isObject] && [self setterSemantics] == JAGPropertySetterSemanticsAssign);
}

- (BOOL)isEligibleForGarbageCollection
{
    return [self hasAttribute: @"P"];
}

- (NSString *)contentOfAttribute: (NSString *)code
{
    for(NSString *encoded in _attributes)
        if([encoded hasPrefix: code]) return [encoded substringFromIndex: 1];
    return nil;
}

- (SEL)customGetter
{
    return NSSelectorFromString([self contentOfAttribute: @"G"]);
}

- (SEL)getter
{
    SEL getter = [self customGetter];
    if (!getter) {
        getter = NSSelectorFromString([self name]);
    }
    return getter;
}

- (SEL)customSetter
{
    return NSSelectorFromString([self contentOfAttribute: @"S"]);
}

- (SEL)setter
{
    SEL setter = [self customSetter];
    if (!setter) {
        NSString *propName = [self name];
        NSString *setterName = [NSString stringWithFormat:
                               @"set%@%@:", 
                                [[propName substringToIndex:1] uppercaseString],
                                [propName substringFromIndex:1]
                                ];
        setter = NSSelectorFromString(setterName);
    }
    return setter;
}

- (NSString *)typeEncoding
{
    return [self contentOfAttribute: @"T"];
}

- (NSString *)oldTypeEncoding
{
    return [self contentOfAttribute: @"t"];
}

- (NSString *)ivarName
{
    return [self contentOfAttribute: @"V"];
}



- (Class) propertyClass {
    if (! [self isObject]) return nil;
    NSArray *encodingComponents = [[self typeEncoding] componentsSeparatedByString:@"\""];
    if ([encodingComponents count] < 2) {
        //id looks like '@', blocks like '@?'
        return nil;
    }
    //typeEncoding looks like '@"AModel"'.  This is with the @ and "s.
    NSString *className = [encodingComponents objectAtIndex:1];
    Class class = NSClassFromString(className);
    return class;
}

- (BOOL) isNumber
{
    NSString *typeEncoding = [self typeEncoding];
    return ([typeEncoding isEqualToString: @"i"]
            || [typeEncoding isEqualToString: @"I"]
            || [typeEncoding isEqualToString: @"s"]
            || [typeEncoding isEqualToString: @"S"]
            || [typeEncoding isEqualToString: @"l"]
            || [typeEncoding isEqualToString: @"L"]
            || [typeEncoding isEqualToString: @"q"]
            || [typeEncoding isEqualToString: @"Q"]
            || [typeEncoding isEqualToString: @"f"]
            || [typeEncoding isEqualToString: @"d"]
            || [typeEncoding isEqualToString: @"B"]
            || [typeEncoding isEqualToString: @"c"]
            || [typeEncoding isEqualToString: @"C"]
            );
}

- (BOOL) isObject
{
    return [[self typeEncoding] hasPrefix: @"@"] && ![self isBlock];
}

- (BOOL) isBlock {
    return [[self typeEncoding] isEqualToString:@"@?"];
}

- (BOOL) isId {
    return [[self typeEncoding] isEqualToString:@"@"];
}

- (BOOL) isCollection {
    Class propClass = [self propertyClass];
    return (propClass && 
        (
         [propClass isSubclassOfClass:[NSArray class]]
         || [propClass isSubclassOfClass:[NSSet class]]
        )
    );
        
}

- (BOOL) canAcceptValue: (id) value {
    if ([self isId]) {
        return YES;
    } else if ([self isObject]) {
        return [value isKindOfClass:[self propertyClass]];
    } else if ([self isNumber]) {
        //Includes chars and BOOLs
        return [value isKindOfClass:[NSNumber class]];
    }
    
    //We don't handle structs, char*, etc yet.  KVC does, tho.
    return YES;
}

@end
