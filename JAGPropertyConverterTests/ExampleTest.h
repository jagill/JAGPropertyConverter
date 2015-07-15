//
//  ExampleTest.h
//  JAGPropertyConverter
//
//  Created by James Gill on 9/20/12.
//
//

#import <XCTest/XCTest.h>

#import "JAGPropertyMapping.h"

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

@interface CustomAddress : Address <JAGPropertyMapping>
@end

@interface Tenant : User <JAGPropertyMapping>

@property (strong) Address *permanentAddress;

@end

@interface LivingAddress : CustomAddress

@property (strong) Tenant *tenant;

@end

/**
 * ExampleTest is a class providing code samples.
 *
 * Examples of serialization and deserialization are given in the implementation file, 
 * that can be examined with breakpoints/etc.
 */
@interface ExampleTest : XCTestCase

@end
