//
//  NSDictionary+JsonString.h
//  JAGPropertyConverter
//
//  Created by Yen-Chia Lin on 03.05.16.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (JsonString)

/** Converts the contents of the dictionary as string in pretty printed JSON format. The return value can easily be used to save as .json file on disk.

 @return NSString in pretty printed JSON format. Returns "(empty)" if dictionary doesn't contain any elements. Returns "<null>" if dictionary contains objects not compatible for NSJSONSerializer.
 */
- (nonnull NSString *)jsonDescription;

@end
