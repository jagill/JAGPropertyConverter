//
//  NSDictionary+JsonString.m
//  JAGPropertyConverter
//
//  Created by Yen-Chia Lin on 03.05.16.
//
//

#import "NSDictionary+JsonString.h"

@implementation NSDictionary (JsonString)

- (nonnull NSString *)jsonDescription {
    if (self.count == 0) {
        return @"(empty)";
    }
    
    // not valid
    if (![NSJSONSerialization isValidJSONObject:self]) {
        return @"<null>";
    }
    
    NSString *bodyString = @"<null>";
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
    if (data) {
        bodyString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }

    return bodyString;
}

@end
