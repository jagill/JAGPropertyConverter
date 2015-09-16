//
//  DictionarySwappingTest.m
//  JAGPropertyConverter
//
//  Created by Yen-Chia Lin on 17.07.15.
//
//

#import <XCTest/XCTest.h>
#import "NSDictionary+JAGKeyValueSwapping.h"

/** Tests the swapping of the keys and values of a dictionary.
 */
@interface DictionarySwappingTest : XCTestCase

@end

@implementation DictionarySwappingTest

- (void)testNil {
    NSDictionary *dict = nil;
    NSDictionary *swappedDict = [dict swapKeysWithValues];
    
    XCTAssertNil(swappedDict);
}

- (void)testSwapping {
    NSDictionary *dict = @{ @"key1" : @"value1",
                            @"key2" : @"value2",
                            @"key3" : @"value3",
                            };
    
    NSDictionary *swappedDict = [dict swapKeysWithValues];
    
    XCTAssertNotNil(swappedDict);
    XCTAssertNotEqual(dict, swappedDict);
    XCTAssertNotEqualObjects(dict, swappedDict);

    // original
    XCTAssertEqual(dict.count, 3u);
    XCTAssertEqualObjects(dict[@"key1"], @"value1");
    XCTAssertEqualObjects(dict[@"key2"], @"value2");
    XCTAssertEqualObjects(dict[@"key3"], @"value3");

    // keys becomes values and values becomes keys
    XCTAssertEqual(swappedDict.count, 3u);
    XCTAssertEqualObjects(swappedDict[@"value1"], @"key1");
    XCTAssertEqualObjects(swappedDict[@"value2"], @"key2");
    XCTAssertEqualObjects(swappedDict[@"value3"], @"key3");
}

- (void)testDuplicateValue {
    NSDictionary *dict = @{ @"key1" : @"value",
                            @"key2" : @"value",
                            @"key3" : @"value3",
                            };
    
    NSDictionary *swappedDict = [dict swapKeysWithValues];
    
    XCTAssertNotNil(swappedDict);
    XCTAssertNotEqual(dict, swappedDict);
    XCTAssertNotEqualObjects(dict, swappedDict);
    
    // keys becomes values and values becomes keys
    XCTAssertEqual(swappedDict.count, 2u);
    XCTAssert([swappedDict[@"value"] isEqualToString:@"key1"] || [swappedDict[@"value"] isEqualToString:@"key2"], @"because dictionary are unordered. it can be any of them");
    XCTAssertEqualObjects(swappedDict[@"value3"], @"key3");
}

- (void)testPerformance {
    int count = 1000;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (int i = 0; i < count; i++) {
        NSString *key = [NSString stringWithFormat:@"key%d", i];
        NSString *value = [NSString stringWithFormat:@"value%d", i];
        dict[key] = value;
    }

    [self measureBlock:^{
        NSDictionary *swappedDict = [dict swapKeysWithValues];

        XCTAssertEqual(swappedDict.count, (NSUInteger)count);
        for (int i = 0; i < count; i++) {
            NSString *key = [NSString stringWithFormat:@"key%d", i];
            NSString *value = [NSString stringWithFormat:@"value%d", i];
            
            XCTAssertEqualObjects(swappedDict[value], key);
        }
    }];
}

@end
