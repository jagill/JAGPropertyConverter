//
//  ExampleTest.m
//  JAGPropertyConverter
//
//  Created by James Gill on 9/20/12.
//
//

#import "ExampleTest.h"
#import "JAGPropertyConverter.h"

@implementation Address
@end

@implementation User
@end

/**
 * Some code examples in test form.
 *
 * We're intentionally violating DRY so that each test reads as naturally as possible.
 */
@implementation ExampleTest

JAGPropertyConverter *converter;

- (void) setUp {
    converter = [JAGPropertyConverter converterWithOutputType:kJAGJSONOutput];
    converter.classesToConvert = [NSSet setWithObject:[User class]];
}

- (void) testToJSONDict {
    User *user = [[User alloc] init];
    NSString *firstName = @"John";
    NSString *lastName = @"Jacobs";
    int age = 55;
    user.firstName = firstName;
    user.lastName = lastName;
    user.age = age;
    
    NSDictionary *targetDict = @{ @"age" : @55, @"firstName" : @"John", @"lastName" : @"Jacobs" };
    NSDictionary *userJsonDict = [converter decomposeObject:user];
    STAssertEqualObjects(userJsonDict, targetDict, @"JSON Dictionary should decompose correctly.");
}

- (void) testFromJSONDict {
    NSDictionary *sourceDict = @{ @"age" : @55, @"firstName" : @"John", @"lastName" : @"Jacobs" };
    User *user = [[User alloc] init];
    [converter setPropertiesOf:user fromDictionary:sourceDict];
    
    STAssertEqualObjects(user.firstName, @"John", @"firstName should be John.");
    STAssertEqualObjects(user.lastName, @"Jacobs", @"lastName should be Jacobs.");
    STAssertEquals(user.age, 55, @"age should be 55");
}

- (void) testFromJSONDictWithIdentifyBlock {
    NSDictionary *sourceDict = @{ @"age" : @55, @"firstName" : @"John", @"lastName" : @"Jacobs" };
    id output = [converter composeModelFromObject:sourceDict];
    STAssertTrue([output isKindOfClass:[NSDictionary class]], @"Without identify block, converter thinks sourceDict is just a dictionary.");
    
    converter.identifyDict = ^Class (NSDictionary *dict) {
        if ([dict objectForKey:@"firstName"] || [dict objectForKey:@"lastName"]) {
            return [User class];
        }
        return nil;
    };
    output = [converter composeModelFromObject:sourceDict];
    STAssertTrue([output isKindOfClass:[User class]], @"With identifyDict block, the converter can sniff out the target class.");
    STAssertEqualObjects([output firstName], @"John", @"firstName should be John.");
    STAssertEqualObjects([output lastName], @"Jacobs", @"lastName should be Jacobs.");
    STAssertEquals([output age], 55, @"age should be 55");
    
    NSDictionary *notUserDict = @{ @"age":@55 };
    output = [converter composeModelFromObject:notUserDict];
    STAssertTrue([output isKindOfClass:[NSDictionary class]], @"When the identify block returns nil, converter thinks the dictionary is just a dictionary.");
    
    /*
     * Note that [JAGPropertyConverter setPropertiesOf:fromDictionary:] will set the properties
     * of the model from the dictionary regardless of whether the model is in classesToConvert.
     * [JAGProperyConverter composeModelFromObject:] requires the classesToConvert property.
     */
    
}

- (void) testToJSONDictRecursive {
    Address *address = [[Address alloc] init];
    address.street = @"123 Main St";
    address.city = @"Springfield";
    address.country = @"USA";
    
    User *user = [[User alloc] init];
    user.firstName = @"John";
    user.lastName = @"Jacobs";
    user.age = 55;
    user.address = address;
    
    NSDictionary *targetDictWithoutAddress = @{ @"firstName" : @"John", @"lastName" : @"Jacobs", @"age" : @55 };
    NSDictionary *userDictWithoutAddress = [converter decomposeObject:user];
    STAssertEqualObjects(userDictWithoutAddress, targetDictWithoutAddress, @"Without [Address class] in converter.classesToConvert, the converter ignores user.address.");
    
    converter.classesToConvert = [NSSet setWithObjects:[User class], [Address class], nil];
    NSDictionary *addressDict = @{ @"street":@"123 Main St", @"city":@"Springfield", @"country":@"USA" };
    NSDictionary *targetDictWithAddress = @{ @"firstName" : @"John", @"lastName" : @"Jacobs", @"age" : @55, @"address" : addressDict };
    NSDictionary *userDictWithAddress = [converter decomposeObject:user];
    STAssertEqualObjects(userDictWithAddress, targetDictWithAddress, @"With [Address class] in converter.classesToConvert, the converter converts user.address.");
}

- (void) testFromJSONDictRecursive {
    //TODO: Not yet implemented
}

- (void) testToJSONDictWithArray {
    //TODO: Not yet implemented
}

- (void) testFromJSONDictWithArray {
    //TODO: Not yet implemented
}

- (void) testToJSONDictWithDict {
    //TODO: Not yet implemented
}

- (void) testFromJSONDictWithDict {
    //TODO: Not yet implemented
}

- (void) testDifferentOutputTypes {
    //TODO: Not yet implemented
}

- (void) testNumberFormatter {
    //TODO: Not yet implemented
}

- (void) testConvertToFromDate {
    //TODO: Not yet implemented
}





@end
