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
    converter.identifyDict = ^Class (NSDictionary *dict) {
        //Need both User and Address, because the converter will need to sniff out both.
        if ([dict objectForKey:@"firstName"] || [dict objectForKey:@"lastName"]) {
            return [User class];
        }
        if ([dict objectForKey:@"street"] || [dict objectForKey:@"city"]) {
            return [Address class];
        }
        return nil;
    };
    NSDictionary *addressDict = @{ @"street":@"123 Main St", @"city":@"Springfield", @"country":@"USA" };
    NSDictionary *sourceDict = @{ @"firstName" : @"John", @"lastName" : @"Jacobs", @"age" : @55, @"address" : addressDict };
    User *user = [converter composeModelFromObject:sourceDict];
    STAssertTrue([user.address isKindOfClass:[Address class]], @"The identify block identifies both User and Address.");
    STAssertEqualObjects(user.address.street, @"123 Main St", @"Converter finds nested properties.");
    STAssertEqualObjects(user.address.city, @"Springfield", @"Converter finds nested properties.");
    STAssertEqualObjects(user.address.country, @"USA", @"Converter finds nested properties.");
    
    /* 
     * Note: If identifyDict block doesn't identify a class, you'll get a log message like:
     *   Unable to set value of class __NSCFDictionary into property address of typeEncoding @"Address"
     * This is because the dictionary isn't identified as a class, so it left as an NSDictionary,
     * which can't be (safely) set as a property of a different class.  JAGPropertyConverter chooses
     * to leave the property null rather than set a dangerous value.  Future versions might
     * check classesToConvert and try to coerce a dictionary into a property of a known Model class.
     */
}

- (void) testToJSONDictWithArray {
    //TODO: Write test
}

- (void) testFromJSONDictWithArray {
    //TODO: Write test
}

- (void) testToJSONDictWithDict {
    //TODO: Write test
}

- (void) testFromJSONDictWithDict {
    //TODO: Write test
}

- (void) testDifferentOutputTypes {
    User *user = [[User alloc] init];
    user.firstName = @"John";
    user.lastName = @"Jacobs";
    user.age = 55;
    NSDate *dob = [NSDate dateWithTimeIntervalSince1970:0];
    user.dob = dob;
    
    converter.outputType = kJAGJSONOutput;
    NSDictionary *jsonTargetDict = @{ @"age" : @55, @"firstName" : @"John", @"lastName" : @"Jacobs" };
    NSDictionary *jsonUserDict = [converter decomposeObject:user];
    STAssertEqualObjects(jsonUserDict, jsonTargetDict, @"NSDate is not a valid JSON value type.");

    converter.outputType = kJAGPropertyListOutput;
    NSDictionary *proplistTargetDict = @{ @"age" : @55, @"firstName" : @"John", @"lastName" : @"Jacobs", @"dob" : dob };
    NSDictionary *proplistUserDict = [converter decomposeObject:user];
    STAssertEqualObjects(proplistUserDict, proplistTargetDict, @"NSDate is a valid PropertyList value type.");

    //TODO: Finish writing test.  Finish FullOutput type.
//    converter.outputType = kJAGFullOutput;
//    NSDictionary *fullTargetDict = @{ @"age" : @55, @"firstName" : @"John", @"lastName" : @"Jacobs", @"dob" : dob };
//    NSDictionary *fullUserDict = [converter decomposeObject:user];
//    STAssertEqualObjects(fullUserDict, fullTargetDict, @"NSDate is a valid Full value type.");
    
    


}

- (void) testNumberFormatter {
    NSDictionary *sourceDict = @{ @"age" : @"55", @"firstName" : @"John", @"lastName" : @"Jacobs" };
    User *user = [[User alloc] init];
    [converter setPropertiesOf:user fromDictionary:sourceDict];
    STAssertEquals(user.age, 0, @"The converter doesn't want to set the int property age to the NSString value @\"55\".");
    
    user = [[User alloc] init];
    converter.numberFormatter = [[NSNumberFormatter alloc] init];
    [converter setPropertiesOf:user fromDictionary:sourceDict];
    STAssertEquals(user.age, 55, @"Setting numberFormatter lets the converter know it should convert strings to numeric types, and how it should do so.");
    
    /*
     * Note that numberFormatter is NOT used decomposing a model into a dictionary.
     * Numeric types are always decomposed to NSNumber.
     */
}

- (void) testConvertFromDate {
    
    User *user = [[User alloc] init];
    user.firstName = @"John";
    user.lastName = @"Jacobs";
    user.age = 55;
    NSDate *dob = [NSDate dateWithTimeIntervalSince1970:0];
    user.dob = dob;
    
    converter.outputType = kJAGJSONOutput;
    converter.convertFromDate = ^id (id date) {
        if ([date isKindOfClass:[NSDate class]]) {
            return @( [date timeIntervalSince1970] );
        }
        return nil;
    };
    NSDictionary *targetDict = @{ @"age" : @55, @"firstName" : @"John", @"lastName" : @"Jacobs", @"dob" : @( [dob timeIntervalSince1970] ) };
    NSDictionary *userDict = [converter decomposeObject:user];
    STAssertEqualObjects(userDict, targetDict, @"NSDate objects are converted with convertFromDate block for kJAGJSONOutputType.");
}

- (void) testConvertToDate {
    
    NSDate *dob = [NSDate dateWithTimeIntervalSince1970:0];
    NSDictionary *sourceDict = @{ @"age" : @55, @"firstName" : @"John", @"lastName" : @"Jacobs", @"dob" : @( [dob timeIntervalSince1970] ) };
    
    converter.outputType = kJAGJSONOutput;
    converter.convertToDate = ^id (id dateValue) {
        if ([dateValue isKindOfClass: [NSDate class]]) {
            return dateValue;
        } else if ([dateValue isKindOfClass: [NSNumber class]]) {
            //We assume it's an epoc integer
            return [NSDate dateWithTimeIntervalSince1970:[dateValue integerValue]];
        }
        return nil;
    };
    User *user = [[User alloc] init];
    [converter setPropertiesOf:user fromDictionary:sourceDict];
    STAssertEqualObjects(user.dob, dob, @"Objects set to NSDate properties are converted with convertToDate block.");
}






@end
