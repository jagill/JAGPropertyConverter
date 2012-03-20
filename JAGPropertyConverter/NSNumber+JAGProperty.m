//
//  NSNumber+JAGProperty.m
//  JAGPropertyConverter
//
//  Created by James Gill on 3/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSNumber+JAGProperty.h"

@implementation NSNumber (JAGProperty)

//FIXME: Surely this isn't necessary, and I'm just missing something?
+ (NSNumber*) numberWithValue: (NSValue*) value {
    const char *encType = [value objCType];
    char encChar = encType[0];
    switch (encChar)
    {
        case 'c': {
            char x;
            [value getValue:&x];
            return [NSNumber numberWithChar:x];
            break;
        }
        case 'C': {
            unsigned char x;
            [value getValue:&x];
            return [NSNumber numberWithUnsignedChar:x];
            break;
        }
        case 's': {
            short x;
            [value getValue:&x];
            return [NSNumber numberWithShort:x];
            break;
        }
        case 'S': {
            unsigned short x;
            [value getValue:&x];
            return [NSNumber numberWithUnsignedShort:x];
            break;
        }
        case 'i': {
            int x;
            [value getValue:&x];
            return [NSNumber numberWithInt:x];
            break;
        }
        case 'I': {
            unsigned int x;
            [value getValue:&x];
            return [NSNumber numberWithUnsignedInt:x];
            break;
        }
        case 'l': {
            long x;
            [value getValue:&x];
            return [NSNumber numberWithLong:x];
            break;
        }
        case 'L': {
            unsigned long x;
            [value getValue:&x];
            return [NSNumber numberWithUnsignedLong:x];
            break;
        }
        case 'q': {
            long long x;
            [value getValue:&x];
            return [NSNumber numberWithLongLong:x];
            break;
        }
        case 'Q': {
            unsigned long long x;
            [value getValue:&x];
            return [NSNumber numberWithUnsignedLongLong:x];
            break;
        }
        case 'f': {
            float x;
            [value getValue:&x];
            return [NSNumber numberWithFloat:x];
            break;
        }
        case 'd': {
            double x;
            [value getValue:&x];
            return [NSNumber numberWithDouble:x];
            break;
        }
        default:
            return nil;
    }
}

@end
