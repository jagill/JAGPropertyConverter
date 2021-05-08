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

@implementation CustomAddress

+ (NSDictionary *)customPropertyNamesMapping {
    return @{ @"street" : @"newCustomProperty" };
}

@end

@implementation Tenant
@end

@implementation LivingAddress

+ (NSDictionary *)customPropertyNamesMapping {
    return @{ @"tenant.firstName" : @"tenantName",
              @"tenant.permanentAddress.street" : @"tenantPermanentAddressStreet"};
}

@end

/**
 * Some code examples in test form.
 *
 * We're intentionally violating DRY so that each test reads as naturally as possible.
 * We are also using the literals introduced in Xcode 4.4 for clarity.  If your version
 * of Xcode is <4.4, this test won't compile (although the library will still work).
 */
@implementation ExampleTest

JAGPropertyConverter *converter;

- (void) setUp {
    converter = [JAGPropertyConverter converterWithOutputType:kJAGJSONOutput];
    converter.classesToConvert = [NSSet setWithObject:[User class]];
}

- (void) testToJSONDict {
    User *user = [[User alloc] init];
    user.firstName = @"John";
    user.lastName = @"Jacobs";
    user.age = 55;
    
    NSDictionary *targetDict = @{ @"age" : @55, @"firstName" : @"John", @"lastName" : @"Jacobs" };
    NSDictionary *userJsonDict = [converter decomposeObject:user];
    XCTAssertEqualObjects(userJsonDict, targetDict, @"Converter decomposes model objects to JSON-compliant dictionaries.");
}

- (void) testFromJSONDict {
    NSDictionary *sourceDict = @{ @"age" : @55, @"firstName" : @"John", @"lastName" : @"Jacobs" };
    User *user = [[User alloc] init];
    [converter setPropertiesOf:user fromDictionary:sourceDict];
    
    XCTAssertEqualObjects(user.firstName, @"John", @"firstName should be John.");
    XCTAssertEqualObjects(user.lastName, @"Jacobs", @"lastName should be Jacobs.");
    XCTAssertEqual(user.age, 55, @"age should be 55");
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
    user.addressInformation = address;
    
    NSDictionary *targetDictWithoutAddress = @{ @"firstName" : @"John", @"lastName" : @"Jacobs", @"age" : @55 };
    NSDictionary *userDictWithoutAddress = [converter decomposeObject:user];
    XCTAssertEqualObjects(userDictWithoutAddress, targetDictWithoutAddress, @"Without [Address class] in converter.classesToConvert, the converter ignores user.addressInformation.");
    
    converter.classesToConvert = [NSSet setWithObjects:[User class], [Address class], nil];
    NSDictionary *addressDict = @{ @"street":@"123 Main St", @"city":@"Springfield", @"country":@"USA" };
    NSDictionary *targetDictWithAddress = @{ @"firstName" : @"John", @"lastName" : @"Jacobs", @"age" : @55, @"addressInformation" : addressDict };
    
    NSDictionary *userDictWithAddress = [converter decomposeObject:user];
    XCTAssertEqualObjects(userDictWithAddress, targetDictWithAddress, @"With [Address class] in converter.classesToConvert, the converter converts user.addressInformation.");
}

- (void) testFromJSONDictRecursive {
    converter.identifyDict = ^Class (NSString *dictName, NSDictionary *dict) {
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
    NSDictionary *sourceDict = @{ @"firstName" : @"John", @"lastName" : @"Jacobs", @"age" : @55, @"addressInformation" : addressDict };
    User *user = [converter composeModelFromObject:sourceDict];
    XCTAssertTrue([user.addressInformation isKindOfClass:[Address class]], @"The identify block identifies both User and Address.");
    XCTAssertEqualObjects(user.addressInformation.street, @"123 Main St", @"Converter finds nested properties.");
    XCTAssertEqualObjects(user.addressInformation.city, @"Springfield", @"Converter finds nested properties.");
    XCTAssertEqualObjects(user.addressInformation.country, @"USA", @"Converter finds nested properties.");
    
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
    User *user = [[User alloc] init];
    user.firstName = @"John";
    user.lastName = @"Jacobs";
    user.age = 55;
    NSArray *favorites = @[ @"cats", @"coffee", @"sorbet" ];
    user.favorites = favorites;
    
    NSDictionary *targetDict = @{ @"age" : @55, @"firstName" : @"John", @"lastName" : @"Jacobs",
    @"favorites" : favorites };
    NSDictionary *userDict = [converter decomposeObject:user];
    XCTAssertEqualObjects(userDict, targetDict, @"The converter decomposes objects with arrays.");
}

- (void) testFromJSONDictWithArray {
    NSArray *favorites = @[ @"cats", @"coffee", @"sorbet" ];
    NSDictionary *sourceDict = @{ @"age" : @55, @"firstName" : @"John", @"lastName" : @"Jacobs",
    @"favorites" : favorites };

    converter.identifyDict = ^Class (NSString *dictName, NSDictionary *dict) {
        if ([dict objectForKey:@"firstName"] || [dict objectForKey:@"lastName"]) {
            return [User class];
        }
        return nil;
    };
    User *user = [converter composeModelFromObject:sourceDict];
    XCTAssertEqualObjects(user.favorites, favorites, @"The converter composes objects with arrays.");
}

- (void) testToJSONDictWithArrayRecursive {
    User *user = [[User alloc] init];
    user.firstName = @"John";
    user.lastName = @"Jacobs";
    user.age = 55;

    User *jack = [[User alloc] init];
    jack.firstName = @"Jack";
    jack.age = 12;
    
    NSArray *fruits = @[ @"raspberries", @"mangosteens" ];
    NSArray *favorites = @[ @"cats", @"coffee", fruits, jack ];
    user.favorites = favorites;
    
    NSDictionary *jackDict = @{ @"firstName" : @"Jack", @"age" : @12 };
    NSArray *favoritesDecomposed = @[ @"cats", @"coffee", fruits, jackDict ];
    NSDictionary *targetDict = @{ @"age" : @55, @"firstName" : @"John", @"lastName" : @"Jacobs",
    @"favorites" : favoritesDecomposed };
    NSDictionary *userDict = [converter decomposeObject:user];
    XCTAssertEqualObjects(userDict, targetDict, @"The converter decomposes objects with arrays recursively.");
}

- (void) testFromJSONDictWithArrayRecursive {
    NSDictionary *jackDict = @{ @"firstName" : @"Jack", @"age" : @12 };
    NSArray *fruits = @[ @"raspberries", @"mangosteens" ];
    NSArray *favorites = @[ @"cats", fruits, jackDict ];
    NSDictionary *sourceDict = @{ @"age" : @55, @"firstName" : @"John", @"lastName" : @"Jacobs",
    @"favorites" : favorites };
    
    converter.identifyDict = ^Class (NSString *dictName, NSDictionary *dict) {
        if ([dict objectForKey:@"firstName"] || [dict objectForKey:@"lastName"]) {
            return [User class];
        }
        return nil;
    };
    User *user = [converter composeModelFromObject:sourceDict];
    
    //The converter has converted jackDict into a user (jack).
    XCTAssertTrue([user.favorites count] == 3, @"The converter composes objects with arrays recursively.");
    XCTAssertTrue([user.favorites containsObject:@"cats"], @"Not surprisingly, that includes strings.");
    XCTAssertEqualObjects([user.favorites objectAtIndex:1], fruits, @"It also includes NSArrays.");
    id jack = [user.favorites objectAtIndex:2];
    XCTAssertTrue([jack isKindOfClass:[User class]], @"The converter composes models recursively too.");
    XCTAssertEqualObjects([jack firstName], @"Jack", @"It gets the properties right as well.");
    XCTAssertEqual([jack age], 12, @"Including numeric ones.");
}

- (void) testToJSONDictWithDict {
    User *user = [[User alloc] init];
    user.firstName = @"John";
    user.lastName = @"Jacobs";
    user.age = 55;
    NSDictionary *info = @{ @"cat" : @"mittens", @"coffe" : @"stumptown" };
    user.information = info;
    
    NSDictionary *targetDict = @{ @"age" : @55, @"firstName" : @"John", @"lastName" : @"Jacobs",
    @"information" : info };
    NSDictionary *userDict = [converter decomposeObject:user];
    XCTAssertEqualObjects(userDict, targetDict, @"The converter decomposes objects with dictionaries.");
}

- (void) testFromJSONDictWithDict {
    NSDictionary *info = @{ @"cat" : @"mittens", @"coffee" : @"stumptown" };
    NSDictionary *sourceDict = @{ @"age" : @55, @"firstName" : @"John", @"lastName" : @"Jacobs",
    @"information" : info };
    
    converter.identifyDict = ^Class (NSString *dictName, NSDictionary *dict) {
        if ([dict objectForKey:@"firstName"] || [dict objectForKey:@"lastName"]) {
            return [User class];
        }
        return nil;
    };
    User *user = [converter composeModelFromObject:sourceDict];
    XCTAssertEqualObjects(user.information, info, @"The converter composes objects with dictionaries.");
}

- (void) testToJSONDictWithDictRecursive {
    User *user = [[User alloc] init];
    user.firstName = @"John";
    user.lastName = @"Jacobs";
    user.age = 55;

    User *jack = [[User alloc] init];
    jack.firstName = @"Jack";
    jack.age = 12;

    Address *oldHome = [[Address alloc] init];
    oldHome.street = @"44 Old Lane";
    oldHome.city = @"Smith City";
    
    Address *reallyOldHome = [[Address alloc] init];
    reallyOldHome.street = @"6 Ancient Way";
    reallyOldHome.city = @"Farmtown";
    
    NSArray *formerAddresses = @[ oldHome, reallyOldHome ];
    
    NSDictionary *info = @{ @"cat" : @"mittens", @"son" : jack, @"formerAddresses" : formerAddresses };
    user.information = info;
    
    NSDictionary *jackDict = @{ @"firstName" : @"Jack", @"age" : @12 };
    NSDictionary *oldHomeDict = @{ @"street" : @"44 Old Lane", @"city" : @"Smith City" };
    NSDictionary *reallyOldHomeDict = @{ @"street" : @"6 Ancient Way", @"city" : @"Farmtown" };
    NSArray *formerAddressesDecomposed = @[ oldHomeDict, reallyOldHomeDict ];
    NSDictionary *infoDict = @{ @"cat" : @"mittens", @"son" : jackDict, @"formerAddresses" : formerAddressesDecomposed };

    NSDictionary *targetDict = @{ @"age" : @55, @"firstName" : @"John", @"lastName" : @"Jacobs",
    @"information" : infoDict };
    converter.classesToConvert = [NSSet setWithObjects:[User class], [Address class], nil];
    NSDictionary *userDict = [converter decomposeObject:user];
    XCTAssertEqualObjects(userDict, targetDict, @"The converter decomposes objects with dictionaries recursively.");
}

- (void) testFromJSONDictWithDictRecursive {
    NSDictionary *jackDict = @{ @"firstName" : @"Jack", @"age" : @12 };
    NSDictionary *oldHomeDict = @{ @"street" : @"44 Old Lane", @"city" : @"Smith City" };
    NSDictionary *reallyOldHomeDict = @{ @"street" : @"6 Ancient Way", @"city" : @"Farmtown" };
    NSArray *formerAddressesDecomposed = @[ oldHomeDict, reallyOldHomeDict ];
    NSDictionary *infoDict = @{ @"cat" : @"mittens", @"son" : jackDict, @"formerAddresses" : formerAddressesDecomposed };
    
    NSDictionary *sourceDict = @{ @"age" : @55, @"firstName" : @"John", @"lastName" : @"Jacobs",
    @"information" : infoDict };
    
    converter.identifyDict = ^Class (NSString *dictName, NSDictionary *dict) {
        //Need both User and Address, because the converter will need to sniff out both.
        if ([dict objectForKey:@"firstName"] || [dict objectForKey:@"lastName"]) {
            return [User class];
        }
        if ([dict objectForKey:@"street"] || [dict objectForKey:@"city"]) {
            return [Address class];
        }
        return nil;
    };
    User *user = [converter composeModelFromObject:sourceDict];
    id jack = [user.information objectForKey:@"son"];
    XCTAssertTrue([jack isKindOfClass:[User class]], @"The converter composes objects recursively, and sniffs out buried Models.");
    XCTAssertEqualObjects([jack firstName], @"Jack", @"It finds their properties too!");
    XCTAssertEqual([jack age], 12, @"Numeric properties are converted, many levels deep.");
    
    NSArray *formerAddresses = [user.information objectForKey:@"formerAddresses"];
    Address *oldHome = [formerAddresses objectAtIndex:0];
    XCTAssertEqual(oldHome.street, @"44 Old Lane", @"The converter finds models in arrays in dictionaries...");
    XCTAssertEqual(oldHome.city, @"Smith City", @"The converter finds their properties, no problem.");
    Address *reallyOldHome = [formerAddresses objectAtIndex:1];
    XCTAssertEqual(reallyOldHome.street, @"6 Ancient Way", @"The converter finds models in arrays in dictionaries...");
    XCTAssertEqual(reallyOldHome.city, @"Farmtown", @"The converter finds their properties, no problem.");
    
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
    XCTAssertEqualObjects(jsonUserDict, jsonTargetDict, @"NSDate is not a valid JSON value type.");

    converter.outputType = kJAGPropertyListOutput;
    NSDictionary *proplistTargetDict = @{ @"age" : @55, @"firstName" : @"John", @"lastName" : @"Jacobs", @"dob" : dob };
    NSDictionary *proplistUserDict = [converter decomposeObject:user];
    XCTAssertEqualObjects(proplistUserDict, proplistTargetDict, @"NSDate is a valid PropertyList value type.");

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
    XCTAssertEqual(user.age, 0, @"The converter doesn't want to set the int property age to the NSString value @\"55\".");
    
    user = [[User alloc] init];
    converter.numberFormatter = [[NSNumberFormatter alloc] init];
    [converter setPropertiesOf:user fromDictionary:sourceDict];
    XCTAssertEqual(user.age, 55, @"Setting numberFormatter lets the converter know it should convert strings to numeric types, and how it should do so.");
    
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
    XCTAssertEqualObjects(userDict, targetDict, @"NSDate objects are converted with convertFromDate block for kJAGJSONOutputType.");
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
    XCTAssertEqualObjects(user.dob, dob, @"Objects set to NSDate properties are converted with convertToDate block.");
}

- (void) testConvertFromData {
    User *user = [[User alloc] init];
    user.firstName = @"John";
    user.lastName = @"Jacobs";
    user.age = 55;
    NSData *eInformation = [[NSData alloc] initWithBase64EncodedString:@"bWFycmllZA==" options:NSDataBase64DecodingIgnoreUnknownCharacters];
    user.encodedInformation = eInformation;
    
    converter.outputType = kJAGJSONOutput;
    converter.convertFromData = ^id (id data) {
        if ([data isKindOfClass:[NSData class]]) {
            return [data base64EncodedStringWithOptions:NSDataBase64Encoding76CharacterLineLength | NSDataBase64EncodingEndLineWithLineFeed];
        }
        return nil;
    };
    
    NSDictionary *targetDict = @{ @"age" : @55, @"firstName" : @"John", @"lastName" : @"Jacobs", @"encodedInformation" : [eInformation base64EncodedStringWithOptions:NSDataBase64Encoding76CharacterLineLength
                                                                                                                          | NSDataBase64EncodingEndLineWithLineFeed] };
    NSDictionary *userDict = [converter decomposeObject:user];
    XCTAssertEqualObjects(userDict, targetDict, @"NSData objects are converted with convertFromData block for kJAGJSONOutputType.");
}

- (void) testConvertToData {
    NSData *eInformation = [[NSData alloc] initWithBase64EncodedString:@"bWFycmllZA==" options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSDictionary *sourceDict = @{ @"age" : @55, @"firstName" : @"John", @"lastName" : @"Jacobs", @"encodedInformation" : [eInformation base64EncodedStringWithOptions:NSDataBase64Encoding76CharacterLineLength
                                                                                                                          | NSDataBase64EncodingEndLineWithLineFeed] };
    converter.outputType = kJAGJSONOutput;
    converter.convertToData = ^id (id dataValue) {
        if ([dataValue isKindOfClass: [NSData class]]) {
            return dataValue;
        } else if ([dataValue isKindOfClass: [NSString class]]) {
            //We assume it's an base64 encoded string
            return [[NSData alloc] initWithBase64EncodedString:dataValue options:NSDataBase64DecodingIgnoreUnknownCharacters];
        }
        return nil;
    };
    User *user = [[User alloc] init];
    [converter setPropertiesOf:user fromDictionary:sourceDict];
    XCTAssertEqualObjects(user.encodedInformation, eInformation, @"Objects set to NSDate properties are converted with convertToDate block.");
}

- (void) testToArrayOfObjects {
    NSDictionary *user1Dict = @{ @"firstName":@"Jack", @"lastName":@"Johnson" };
    NSDictionary *user2Dict = @{ @"firstName":@"Joe", @"lastName":@"Smith" };
    NSArray *userArray = [NSArray arrayWithObjects:user1Dict, user2Dict, nil];
    
    converter.identifyDict = ^Class (NSString *dictName, NSDictionary *dict) {
        if ([dict objectForKey:@"firstName"] || [dict objectForKey:@"lastName"]) {
            return [User class];
        }
        return nil;
    };
    NSArray *users = [converter composeModelFromObject:userArray];
    
    User *user1 = [users objectAtIndex:0];
    User *user2 = [users objectAtIndex:1];
    XCTAssertEqual(user1.firstName, @"Jack", @"user1 should firstName Jack");
    XCTAssertEqual(user1.lastName, @"Johnson", @"user1 should lastName Johnson");
    XCTAssertEqual(user2.firstName, @"Joe", @"user2 should firstName Joe");
    XCTAssertEqual(user2.lastName, @"Smith", @"user2 should lastName Smith");
}

#pragma mark - Identify Dict

- (void) testFromJSONDictWithIdentifyBlock {
    NSDictionary *sourceDict = @{ @"age" : @55, @"firstName" : @"John", @"lastName" : @"Jacobs" };
    id output = [converter composeModelFromObject:sourceDict];
    XCTAssertTrue([output isKindOfClass:[NSDictionary class]], @"Without identify block, converter thinks sourceDict is just a dictionary.");
    
    converter.identifyDict = ^Class (NSString *dictName, NSDictionary *dict) {
        if ([dict objectForKey:@"firstName"] || [dict objectForKey:@"lastName"]) {
            return [User class];
        }
        return nil;
    };
    output = [converter composeModelFromObject:sourceDict];
    XCTAssertTrue([output isKindOfClass:[User class]], @"With identifyDict block, the converter can sniff out the target class.");
    XCTAssertEqualObjects([output firstName], @"John", @"firstName should be John.");
    XCTAssertEqualObjects([output lastName], @"Jacobs", @"lastName should be Jacobs.");
    XCTAssertEqual([output age], 55, @"age should be 55");
    
    NSDictionary *notUserDict = @{ @"age":@55 };
    output = [converter composeModelFromObject:notUserDict];
    XCTAssertTrue([output isKindOfClass:[NSDictionary class]], @"When the identify block returns nil, converter thinks the dictionary is just a dictionary.");
    
    /*
     * Note that [JAGPropertyConverter setPropertiesOf:fromDictionary:] will set the properties
     * of the model from the dictionary regardless of whether the model is in classesToConvert.
     * [JAGProperyConverter composeModelFromObject:] requires the classesToConvert property.
     */
    
}

- (void)testFromJSONWithIdentifyDictName {
    NSDictionary *addressDict = @{ @"street":@"123 Main St", @"city":@"Springfield", @"country":@"USA" };
    NSDictionary *sourceDict = @{ @"firstName" : @"John", @"lastName" : @"Jacobs", @"age" : @55, @"addressInformation" : addressDict };
    
    converter.identifyDict = ^Class (NSString *dictName, NSDictionary *dict) {
        //Need both User and Address, because the converter will need to sniff out both.
        if (dictName == nil) { // 1st level object --> user (you can also check on the content of the dict if you have more objects on first level)
            return [User class];
        }
        
        if ([dictName isEqualToString:@"addressInformation"]) {
            return [Address class];
        }
        
        return nil;
    };
    
    User *user = [converter composeModelFromObject:sourceDict];
    XCTAssertTrue([user.addressInformation isKindOfClass:[Address class]], @"The identify block identifies both User and Address.");
    XCTAssertEqualObjects(user.addressInformation.street, @"123 Main St", @"Converter finds nested properties.");
    XCTAssertEqualObjects(user.addressInformation.city, @"Springfield", @"Converter finds nested properties.");
    XCTAssertEqualObjects(user.addressInformation.country, @"USA", @"Converter finds nested properties.");
}

- (void)testFromJSONWithIdentifyDictNameWithSnakeCase {
    converter.enableSnakeCaseSupport = YES;
    
    NSDictionary *addressDict = @{ @"street":@"123 Main St", @"city":@"Springfield", @"country":@"USA" };
    NSDictionary *sourceDict = @{ @"first_name" : @"John", @"last_name" : @"Jacobs", @"age" : @55, @"address_information" : addressDict };
    
    converter.identifyDict = ^Class (NSString *dictName, NSDictionary *dict) {
        //Need both User and Address, because the converter will need to sniff out both.
        if (dictName == nil) { // 1st level object --> user (you can also check on the content of the dict if you have more objects on first level)
            return [User class];
        }
        
        if ([dictName isEqualToString:@"addressInformation"]) {
            return [Address class];
        }
        
        return nil;
    };
    
    User *user = [converter composeModelFromObject:sourceDict];
    XCTAssertTrue([user.addressInformation isKindOfClass:[Address class]], @"The identify block identifies both User and Address.");
    XCTAssertEqualObjects(user.addressInformation.street, @"123 Main St", @"Converter finds nested properties.");
    XCTAssertEqualObjects(user.addressInformation.city, @"Springfield", @"Converter finds nested properties.");
    XCTAssertEqualObjects(user.addressInformation.country, @"USA", @"Converter finds nested properties.");
}

- (void)testToJSONDictWithIdentifyDictNameWithSnakeCase {
    converter.enableSnakeCaseSupport = YES;
    
    Address *address = [[Address alloc] init];
    address.street = @"123 Main St";
    address.city = @"Springfield";
    address.country = @"USA";
    
    User *user = [[User alloc] init];
    user.firstName = @"John";
    user.lastName = @"Jacobs";
    user.age = 55;
    user.addressInformation = address;
    
    NSDictionary *targetDictWithoutAddress = @{ @"first_name" : @"John", @"last_name" : @"Jacobs", @"age" : @55 };
    NSDictionary *userDictWithoutAddress = [converter decomposeObject:user];
    XCTAssertEqualObjects(userDictWithoutAddress, targetDictWithoutAddress, @"Without [Address class] in converter.classesToConvert, the converter ignores user.addressInformation.");
    
    converter.classesToConvert = [NSSet setWithObjects:[User class], [Address class], nil];
    NSDictionary *addressDict = @{ @"street":@"123 Main St", @"city":@"Springfield", @"country":@"USA" };
    NSDictionary *targetDictWithAddress = @{ @"first_name" : @"John", @"last_name" : @"Jacobs", @"age" : @55, @"address_information" : addressDict };
    
    NSDictionary *userDictWithAddress = [converter decomposeObject:user];
    XCTAssertEqualObjects(userDictWithAddress, targetDictWithAddress, @"With [Address class] in converter.classesToConvert, the converter converts user.addressInformation.");
}

#pragma mark - Snake Case Support

- (void)testToJSONWithSnakeCase {
    converter.enableSnakeCaseSupport = YES;
    
    User *user = [[User alloc] init];
    user.firstName = @"John";
    user.lastName = @"Jacobs";
    user.age = 55;
    
    NSDictionary *targetDict = @{ @"age" : @55, @"first_name" : @"John", @"last_name" : @"Jacobs" };
    NSDictionary *userJsonDict = [converter decomposeObject:user];
    XCTAssertEqualObjects(userJsonDict, targetDict, @"Converter decomposes model objects to JSON-compliant dictionaries.");

}

- (void)testFromJSONDictWithSnakeCase {
    converter.enableSnakeCaseSupport = YES;
    
    NSDictionary *sourceDict = @{ @"age" : @55, @"first_name" : @"John", @"last_name" : @"Jacobs" };
    User *user = [[User alloc] init];
    [converter setPropertiesOf:user fromDictionary:sourceDict];
    
    XCTAssertEqualObjects(user.firstName, @"John", @"firstName should be John.");
    XCTAssertEqualObjects(user.lastName, @"Jacobs", @"lastName should be Jacobs.");
    XCTAssertEqual(user.age, 55, @"age should be 55");
}

#pragma mark - Ignore NSNull values

- (void)testFromJSONDictIgnoringNSNull {
    // simulating a null value from JSON
    NSData *data = [@"{\"age\":55,\"firstName\":\"John\",\"lastName\":null}" dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    XCTAssertEqual([dict[@"lastName"] class], [NSNull class], @"lastName should be converted to NSNull");
    
    converter.shouldIgnoreNullValues = YES;
    
    User *user = [[User alloc] init];
    user.firstName = nil;
    user.lastName = nil;
    [converter setPropertiesOf:user fromDictionary:dict];
    
    XCTAssertEqualObjects(user.firstName, @"John", @"firstName should be John.");
    XCTAssertEqual(user.age, 55, @"age should be 55");
    
    XCTAssertNil(user.lastName, @"lastName should be nil but not NSNull");
    XCTAssertFalse([user.lastName isKindOfClass:[NSNull class]], @"not NSNull");
}

- (void)testFromJSONDictIgnoringNSNullUntouchedProperty {
    // simulating a null value from JSON
    NSData *data = [@"{\"age\":55,\"firstName\":\"John\",\"lastName\":null}" dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    XCTAssertEqual([dict[@"lastName"] class], [NSNull class], @"lastName should be converted to NSNull");
    
    converter.shouldIgnoreNullValues = YES;
    
    User *user = [[User alloc] init];
    user.firstName = @"Bob";
    user.lastName = @"Wick";
    [converter setPropertiesOf:user fromDictionary:dict];
    
    XCTAssertEqualObjects(user.firstName, @"John", @"firstName should be John.");
    XCTAssertEqual(user.age, 55, @"age should be 55");
    
    XCTAssertNotNil(user.lastName, @"lastName should still be 'Wick'");
    XCTAssertEqualObjects(user.lastName, @"Wick", @"should be untouched");
}

- (void)testFromJSONDictClearPropertyUsingNSNull {
    // simulating a null value from JSON
    NSData *data = [@"{\"age\":55,\"firstName\":\"John\",\"lastName\":null}" dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    XCTAssertEqual([dict[@"lastName"] class], [NSNull class], @"lastName should be converted to NSNull");
    
    converter.shouldIgnoreNullValues = NO; // NSNull values should clear the property
    
    User *user = [[User alloc] init];
    user.firstName = nil;
    user.lastName = nil;
    [converter setPropertiesOf:user fromDictionary:dict];
    
    XCTAssertEqualObjects(user.firstName, @"John", @"firstName should be John.");
    XCTAssertEqual(user.age, 55, @"age should be 55");
    
    XCTAssertNil(user.lastName, @"lastName should be nil but not NSNull");
    XCTAssertFalse([user.lastName isKindOfClass:[NSNull class]], @"not NSNull");
}

- (void)testFromJSONDictClearPropertyUsingNSNull2 {
    // simulating a null value from JSON
    NSData *data = [@"{\"age\":55,\"firstName\":\"John\",\"lastName\":null}" dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    XCTAssertEqual([dict[@"lastName"] class], [NSNull class], @"lastName should be converted to NSNull");
    
    converter.shouldIgnoreNullValues = NO; // NSNull values should clear the property
    
    User *user = [[User alloc] init];
    user.firstName = @"Bob";
    user.lastName = @"Wick";
    [converter setPropertiesOf:user fromDictionary:dict];
    
    XCTAssertEqualObjects(user.firstName, @"John", @"firstName should be John.");
    XCTAssertEqual(user.age, 55, @"age should be 55");
    
    XCTAssertNil(user.lastName, @"lastName should be nil but not NSNull");
    XCTAssertFalse([user.lastName isKindOfClass:[NSNull class]], @"not NSNull");
}

- (void)testFromJSONDictClearPropertyUsingNSNull3 {
    // simulating a null value from JSON
    NSData *data = [@"{\"age\":null,\"firstName\":\"John\",\"lastName\":\"Wick\"}" dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    XCTAssertEqual([dict[@"age"] class], [NSNull class], @"age should be converted to NSNull");
    
    converter.shouldIgnoreNullValues = NO; // NSNull values should clear the property
    
    User *user = [[User alloc] init];
    user.age = 60;
    user.firstName = @"Bob";
    user.lastName = @"Wick";
    [converter setPropertiesOf:user fromDictionary:dict];
    
    XCTAssertEqualObjects(user.firstName, @"John", @"firstName should be John.");
    XCTAssertEqual(user.age, 0, @"age should be cleared");
    
    XCTAssertNotNil(user.lastName, @"lastName should still be 'Wick'");
    XCTAssertEqualObjects(user.lastName, @"Wick", @"should be untouched");
}

#pragma mark - Custom Property Name Mapping

- (void)testToJSONWithCustomName {
    converter.classesToConvert = [NSSet setWithArray:@[[CustomAddress class]]];

    // street --> newCustomProperty
    CustomAddress *address = [[CustomAddress alloc] init];   // custom address has implemented JAGPropertyMapping
    address.street = @"Infinite Loop 1";
    address.city = @"Cuppertino";
    address.country = @"USA";
    
    NSDictionary *targetDict = @{ @"country" : @"USA", @"city" : @"Cuppertino", @"newCustomProperty" : @"Infinite Loop 1" };
    NSDictionary *userJsonDict = [converter decomposeObject:address];
    XCTAssertEqualObjects(userJsonDict, targetDict, @"Converter decomposes model objects to JSON-compliant dictionaries.");
    
}

- (void)testFromJSONDictWithCustomName {
    // newCustomProperty --> street
    NSDictionary *sourceDict = @{ @"country" : @"USA", @"city" : @"Cuppertino", @"newCustomProperty" : @"Infinite Loop 1" };
    CustomAddress *address = [[CustomAddress alloc] init];
    [converter setPropertiesOf:address fromDictionary:sourceDict];
    
    XCTAssertEqualObjects(address.street, @"Infinite Loop 1", @"firstName should be John.");
    XCTAssertEqualObjects(address.city, @"Cuppertino", @"lastName should be Jacobs.");
    XCTAssertEqual(address.country, @"USA", @"age should be 55");
}

- (void)testТоJSONDictWithKeypathCustomName {
    converter.classesToConvert = [NSSet setWithArray:@[[LivingAddress class]]];

    LivingAddress *address = [[LivingAddress alloc] init];   // custom address has implemented JAGPropertyMapping
    address.street = @"Infinite Loop 1";                     // 'street' will be converted to 'newCustomProperty'
    address.city = @"Cuppertino";
    address.country = @"USA";

    Tenant *tenant1 = [[Tenant alloc] init];
    tenant1.firstName = @"John";
    tenant1.addressInformation = address;

    Address *permanentAddress = [[Address alloc] init];
    permanentAddress.street = @"Nowhere Road 2";
    permanentAddress.city = @"Anywhere City";
    permanentAddress.country = @"USA";
    tenant1.permanentAddress = permanentAddress;

    address.tenant = tenant1;

    NSDictionary *targetDict = @{ @"country" : @"USA", @"city" : @"Cuppertino", @"newCustomProperty" : @"Infinite Loop 1", @"tenantName" : @"John", @"tenantPermanentAddressStreet": @"Nowhere Road 2" };
    NSDictionary *userJsonDict = [converter decomposeObject:address];
    XCTAssertEqualObjects(userJsonDict, targetDict, @"Converter decomposes model objects to JSON-compliant dictionaries.");
}

- (void)testFromJSONWIthKeypathCustomName {
    // newCustomProperty --> street
    NSDictionary *sourceDict = @{ @"country" : @"USA", @"city" : @"Cuppertino", @"street" : @"Infinite Loop 1", @"tenantName" : @"John", @"tenantPermanentAddressStreet": @"Nowhere Road 2" };

    LivingAddress *address = [[LivingAddress alloc] init];
    [converter setPropertiesOf:address fromDictionary:sourceDict];

    XCTAssertEqualObjects(address.street, @"Infinite Loop 1", @"firstName should be John.");
    XCTAssertEqualObjects(address.city, @"Cuppertino", @"lastName should be Jacobs.");
    XCTAssertEqual(address.country, @"USA", @"age should be 55");
    XCTAssertEqual(address.tenant.firstName, @"John", @"Tenant's firstName should be John.");
    XCTAssertEqual(address.tenant.permanentAddress.street, @"Nowhere Road 2", @"Tenant's permanent address' street should be 'Nowhere Road 2'.");
}

@end
