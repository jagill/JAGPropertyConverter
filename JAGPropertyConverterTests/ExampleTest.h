//
//  ExampleTest.h
//  JAGPropertyConverter
//
//  Created by James Gill on 9/20/12.
//
//

#import <SenTestingKit/SenTestingKit.h>

#import "JAGPropertyMappingProtocol.h"

@interface Address : NSObject
@property (copy)    NSString        *street;
@property (copy)    NSString        *city;
@property (copy)    NSString        *country;
@end

@interface User : NSObject
@property (copy)    NSString        *firstName;
@property (copy)    NSString        *lastName;
@property (assign)  int             age;
@property (strong)  Address         *addressInformation;
@property (strong)  NSDate          *dob;
@property (strong)  NSArray         *favorites;
@property (strong)  NSDictionary    *information;
@property (strong)  NSData          *encodedInformation;
@end

@interface CustomAddress : Address <JAGPropertyMappingProtocol>

@end

/**
 * ExampleTest is a class providing code samples.
 *
 * Examples of serialization and deserialization are given in the implementation file, 
 * that can be examined with breakpoints/etc.
 */
@interface ExampleTest : SenTestCase

@end
