//
//  NSString+JAGSnakeCaseSupport.h
//  JAGPropertyConverter
//
//  Created by Yen-Chia Lin on 27.11.14.
//
//

#import <Foundation/Foundation.h>

// Source: http://stackoverflow.com/questions/1918972/camelcase-to-underscores-and-back-in-objective-c
// Source: https://github.com/peterdeweese/es_ios_utils/blob/master/es_ios_utils/universal/ESNSCategories.m
@interface NSString (JAGSnakeCaseSupport)

- (NSString *)asCamelCaseFromUnderscore;
- (NSString *)asUnderscoreFromCamelCase;

@end
