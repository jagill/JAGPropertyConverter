//
//  JAGPropertyMapping.h
//  JAGPropertyConverter
//
//  Created by Yen-Chia Lin on 28.11.14.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JAGPropertyMapping <NSObject>

@optional

/** Custom property names mapping for converting Model <> JSON.
 *
 * This dictionary will automatically be swapped and used when decomposing (JSON --> Model). Key and value will be swapped: Dict <JSON name, property name>
 *
 * @return A dictionary with property name as key and JSON name as value: Dict <property name, JSON name>
 */
+ (NSDictionary<NSString *, NSString *> *)customPropertyNamesMapping;

/** Asks the receiver if there are any enum values which should be converted (Model <> JSON). Implement convertToEnum and convertFromEnum to handle this.
 *
 * This dictionary will automatically be swapped and used when decomposing (JSON --> Model). Key and value will be swapped: Dict <JSON name, property name>
 *
 * @note The property name must always match the property name where it came from before it is custom-name mapped.
 *
 * @return A dictionary with property name as key and JSON name as value: Dict <property name, JSON name>
 */
+ (NSDictionary<NSString *, NSString *> *)enumPropertiesToConvert;

/** Asks the receiver if there are properties to ignore when converting from JSON. */
+ (NSArray<NSString *> *)ignorePropertiesFromJSON;

/** Asks the receiver if there are properties to ignore when converting to JSON. */
+ (NSArray<NSString *> *)ignorePropertiesToJSON;

/** Tells the property converter to not ignore specified properties when property value is nil (= opt-In to not be ignored).
 
 It will either convert the property to NSNull (model ➡️ json) or set property to nil (json ➡️ model).
 
 @note This method is only used if `converter.shouldIgnoreNullValues == YES`
 
 @return Array of original model property names to not be ignored when serializing nil values.
 */
+ (NSArray<NSString *> *)nilPropertiesNotToIgnore;

@end

NS_ASSUME_NONNULL_END
