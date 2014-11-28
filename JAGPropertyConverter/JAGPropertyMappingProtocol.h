//
//  JAGPropertyMappingProtocol.h
//  JAGPropertyConverter
//
//  Created by Yen-Chia Lin on 28.11.14.
//
//

#import <Foundation/Foundation.h>

@protocol JAGPropertyMappingProtocol <NSObject>

@optional

/** Mapping for JSON --> Object */
- (NSDictionary *)composingCustomPropertyMapping;

/** Mapping for Object --> JSON */
- (NSDictionary *)decomposingCustomPropertyMapping;

@end
