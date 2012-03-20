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

// Use this only for the experimental get/set methods.  This needs to be improved!
@interface NSNumber (JAGProperty)

+ (NSNumber*) numberWithValue: (NSValue*) value;

/**
 * Creates an NSNumber with `[value getValue:]` accounting for `value`'s `objCType`.
 */
- (id) initWithValue: (NSValue*) value;

/**
 Assigns the value appropiate to `encType` into `buffer`.
 
 This allows you to do the following:
 NSNumber *doubleNum = [NSNumber numberWithDouble:1.234];
 float aFloat;
 [doubleNum value:&aFloat forObjCType:@encode(float)];
 //aFloat == 1.234
 
 */
- (void) value: (void *)buffer forObjCType: (const char *)encType;

@end

@implementation NSNumber (JAGProperty)

//FIXME: Surely this isn't necessary, and I'm just missing something?
+ (NSNumber*) numberWithValue: (NSValue*) value {
    return [[NSNumber alloc] initWithValue:value];
}

- (id) initWithValue: (NSValue*) value {
    self = [super init];
    if (self) {
        const char *encType = [value objCType];
        char encChar = encType[0];
        switch (encChar)
        {
            case 'c': {
                char x;
                [value getValue:&x];
                return [self initWithChar:x];
            }
            case 'C': {
                unsigned char x;
                [value getValue:&x];
                return [self initWithUnsignedChar:x];
            }
            case 's': {
                short x;
                [value getValue:&x];
                return [self initWithShort:x];
            }
            case 'S': {
                unsigned short x;
                [value getValue:&x];
                return [self initWithUnsignedShort:x];
            }
            case 'i': {
                int x;
                [value getValue:&x];
                return [self initWithInt:x];
            }
            case 'I': {
                unsigned int x;
                [value getValue:&x];
                return [self initWithUnsignedInt:x];
            }
            case 'l': {
                long x;
                [value getValue:&x];
                return [self initWithLong:x];
            }
            case 'L': {
                unsigned long x;
                [value getValue:&x];
                return [self initWithUnsignedLong:x];
            }
            case 'q': {
                long long x;
                [value getValue:&x];
                return [self initWithLongLong:x];
            }
            case 'Q': {
                unsigned long long x;
                [value getValue:&x];
                return [self initWithUnsignedLongLong:x];
            }
            case 'f': {
                float x;
                [value getValue:&x];
                return [self initWithFloat:x];
            }
            case 'd': {
                double x;
                [value getValue:&x];
                return [self initWithDouble:x];
            }
            default:
                return nil;
        }
    }
    
    return self;
}

- (void) value:(void *)buffer forObjCType:(const char *)encType {
    char encChar = encType[0];
    switch (encChar)
    {
        case 'c': {
            *(char*)buffer = [self charValue];
            break;
        }
        case 'C': {
            *(unsigned char *)buffer = [self unsignedCharValue];
            break;
        }
        case 's': {
            *(short *)buffer = [self shortValue];
            break;
        }
        case 'S': {
            *(unsigned short *)buffer = [self unsignedShortValue];
            break;
        }
        case 'i': {
            *(int *)buffer = [self intValue];
            break;
        }
        case 'I': {
            *(unsigned int *)buffer = [self unsignedIntValue];
            break;
        }
        case 'l': {
            *(long *)buffer = [self longValue];
            break;
        }
        case 'L': {
            *(unsigned long *)buffer = [self unsignedLongValue];
            break;
        }
        case 'q': {
            *(long long *)buffer = [self longLongValue];
            break;
        }
        case 'Q': {
            *(unsigned long long *)buffer = [self unsignedLongLongValue];
            break;
        }
        case 'f': {
            *(float *)buffer = [self floatValue];
            break;
        }
        case 'd': {
            *(double *)buffer = [self doubleValue];
            break;
        }
        default:
            buffer = 0;
    }
    
}

@end



#pragma mark - JAGProperty

@interface JAGProperty () 
{
@private
    objc_property_t     _property;
    NSArray             *_attributes;
}

- (NSString *)contentOfAttribute: (NSString *)code;

- (NSString*) getterName;

- (NSString*) setterName;

@end

@implementation JAGProperty

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

- (NSString *)contentOfAttribute: (NSString *)code
{
    for(NSString *encoded in _attributes)
        if([encoded hasPrefix: code]) return [encoded substringFromIndex: 1];
    return nil;
}

#pragma mark - Property attributes

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


#pragma mark - Information on Property Class

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

- (BOOL) isCharacterType
{
    NSString *typeEncoding = [self typeEncoding];
    return ([typeEncoding isEqualToString: @"c"]
            || [typeEncoding isEqualToString: @"C"]
            || [typeEncoding isEqualToString: @"*"]
            );    
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

- (BOOL) isScalar
{
    return ([self isCharacterType]
            || [self isNumber] //isNumber includes Boolean
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

#pragma mark - Getting and Setting

- (SEL)customGetter
{
    return NSSelectorFromString([self contentOfAttribute: @"G"]);
}

- (NSString*) getterName {
    NSString *getterName = [self contentOfAttribute: @"G"];
    if (!getterName) {
        getterName = [self name];
    }
    return getterName;
}

- (SEL)getter
{
    return NSSelectorFromString([self getterName]);
}

- (id) getFrom:(id) object {
    NSMethodSignature *methodSig = [[object class] instanceMethodSignatureForSelector:[self getter]];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:methodSig];
    [inv setSelector:[self getter]];
    [inv setTarget:object];
    [inv invoke];
    
    if ([self isObject]) {
        id returnValue;
        [inv getReturnValue:&returnValue];
        return returnValue;
    } else {
        void *buffer;
        NSUInteger length = [methodSig methodReturnLength];
        buffer = (void *)malloc(length);
        [inv getReturnValue:buffer];
        NSValue *value = [NSValue valueWithBytes:buffer objCType:[methodSig methodReturnType]];
        free(buffer);
        if ([self isNumber]) {
            NSNumber *num = [NSNumber numberWithValue:value];
            return num;
        } else {
            return value;
        }
    }    
}

- (SEL)customSetter
{
    return NSSelectorFromString([self contentOfAttribute: @"S"]);
}

- (NSString*) setterName
{
    NSString *setterName = [self contentOfAttribute: @"S"];
    if (!setterName) {
        NSString *propName = [self name];
        setterName = [NSString stringWithFormat:
                      @"set%@%@:", 
                      [[propName substringToIndex:1] uppercaseString],
                      [propName substringFromIndex:1]
                      ];
    }
    return setterName;
}

- (SEL)setter
{
    return NSSelectorFromString([self setterName]);
}

- (void) set:(id) value on:(id) object {
    void * buffer;
    
    NSMethodSignature *methodSig = [[object class] instanceMethodSignatureForSelector:[self setter]];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:methodSig];
    [inv setSelector:[self setter]];
    [inv setTarget:object];
    
    if ([self isObject]) {
        [inv setArgument:&value atIndex:2];
    } else if ([value isKindOfClass:[NSValue class]]) {
        NSUInteger length;
        NSGetSizeAndAlignment([methodSig getArgumentTypeAtIndex:2], &length, NULL);
        buffer = (void *)malloc(length);
        if ([value isKindOfClass:[NSNumber class]]) {
            //Converts NSNumbers from doubles to floats, etc.
            [value value:buffer forObjCType:[methodSig getArgumentTypeAtIndex:2]];
        } else {
            [value getValue:buffer];
        }
        [inv setArgument:buffer atIndex:2];
        free(buffer);
    }
    [inv invoke];
    
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
