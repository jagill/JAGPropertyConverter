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
