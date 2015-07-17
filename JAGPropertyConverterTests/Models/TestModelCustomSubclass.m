//
//  TestModelCustomSubclass.m
//  JAGPropertyConverter
//
//  Created by Yen-Chia Lin on 17.07.15.
//
//

#import "TestModelCustomSubclass.h"

// This class intentionally returns nil in every mapping to test if the chain of inheritance is not broken.
@implementation TestModelCustomNilSubclass

#pragma mark - JAGPropertyMapping

+ (NSDictionary *)customPropertyNamesMapping {
    return nil;
}

+ (NSArray *)enumPropertiesToConvertFromJSON {
    return nil;
}

+ (NSArray *)enumPropertiesToConvertToJSON {
    return nil;
}

+ (NSArray *)ignorePropertiesFromJSON {
    return nil;
}

+ (NSArray *)ignorePropertiesToJSON {
    return nil;
}

@end

@implementation TestModelCustomSubclass

#pragma mark - JAGPropertyMapping

+ (NSDictionary *)customPropertyNamesMapping {
    return @{@"subclassCustomMapped" : @"differentSubclassCustomMapped"};
}

+ (NSArray *)enumPropertiesToConvertFromJSON {
    return @[@"subclassEnumProperty"];
}

+ (NSArray *)enumPropertiesToConvertToJSON {
    return @[@"subclassEnumProperty"];
}

+ (NSArray *)ignorePropertiesFromJSON {
    return @[@"subclassIgnoreProperty"];
}

+ (NSArray *)ignorePropertiesToJSON {
    return @[@"subclassIgnoreProperty"];
}

@end
