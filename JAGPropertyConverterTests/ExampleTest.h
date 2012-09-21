//
//  ExampleTest.h
//  JAGPropertyConverter
//
//  Created by James Gill on 9/20/12.
//
//

#import <SenTestingKit/SenTestingKit.h>

@interface Address : NSObject
@property (copy) NSString *street;
@property (copy) NSString *city;
@property (copy) NSString *country;
@end

@interface User : NSObject
@property (copy)    NSString    *firstName;
@property (copy)    NSString    *lastName;
@property (assign)  int         age;
@property (strong)  Address     *address;
@property (strong)  NSDate      *dob;
@end

/**
 * ExampleTest is a class providing code samples.
 *
 * Examples of serialization and deserialization are given in the implementation file, 
 * 
 
 
 that can be examined with breakpoints/etc.
 */
@interface ExampleTest : SenTestCase

@end
