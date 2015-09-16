//
//  NSDictionary+JAGKeyValueSwapping.m
//  JAGPropertyConverter
//
//  Created by Yen-Chia Lin on 17.07.15.
//
//

#import "NSDictionary+JAGKeyValueSwapping.h"

@implementation NSDictionary (JAGKeyValueSwapping)

- (NSDictionary *)swapKeysWithValues {
    NSMutableDictionary *switchedDict = [NSMutableDictionary dictionary];
    for (id key in [self allKeys]) {
        id value = self[key];
        if (switchedDict[value]) {
            NSLog(@"JAG > Failed to swap dictionary. Duplicate values found! key = %@ / value = %@", key, value);
            continue;
        }
        switchedDict[value] = key;
    }
    
    return [switchedDict copy]; // return a immutable instance
}

@end
