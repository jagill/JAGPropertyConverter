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

/** Mapping from JSON to Model (JSON --> Model).
 *
 * @return A dictionary with JSON name as key and property name as value: Dict <JSON name, property name>
 */
- (NSDictionary *)customPropertyMappingConvertingFromJSON;

/** Mapping from Model to JSON (Model --> JSON).
 *
 * @return A dictionary with property name as key and JSON name as value: Dict <property name, JSON name>
 */
- (NSDictionary *)customPropertyMappingConvertingToJSON;

@end
