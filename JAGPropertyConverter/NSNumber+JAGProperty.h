//
//  NSNumber+JAGProperty.h
//  JAGPropertyConverter
//
//  Created by James Gill on 3/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

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
