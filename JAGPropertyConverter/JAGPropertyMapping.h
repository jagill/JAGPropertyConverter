//
//  JAGPropertyMapping.h
//  JAGPropertyConverter
//
//  Created by Yen-Chia Lin on 28.11.14.
//
//

#import <Foundation/Foundation.h>

@protocol JAGPropertyMapping <NSObject>

@optional

/** Custom property names mapping for converting Model <> JSON.
 *
 * This dictionary will automatically be swapped and used when decomposing (JSON --> Model). Key and value will be swapped: Dict <JSON name, property name>
 *
 * @return A dictionary with property name as key and JSON name as value: Dict <property name, JSON name>
 */
+ (NSDictionary *)customPropertyNamesMapping;

/** Asks the receiver if there are any enum values which should be converted.
 *
 * @important The property name must always match the property name where it came from. (eg. fromJSON = the json name, toJSON = the model property name)
 *            if the name is custom-name mapped.
 *
 * @return A array with NSString property names which are indicating the properties for the model which are enums and should be converted to something else.
 *         Implement convertToEnum and convertFromEnum to handle this.
 */
+ (NSArray *)enumPropertiesToConvertFromJSON;

/** Asks the receiver if there are any enum values which should be converted.
 *
 * @important The property name must always match the property name where it came from. (eg. fromJSON = the json name, toJSON = the model property name)
 *            if the name is custom-name mapped.
 *
 * @return A array with NSString property names which are indicating the properties for the model which are enums and should be converted to something else.
 *         Implement convertToEnum and convertFromEnum to handle this.
 */
+ (NSArray *)enumPropertiesToConvertToJSON;

/** Asks the receiver if there are properties to ignore when converting from JSON. */
+ (NSArray *)ignorePropertiesFromJSON;

/** Asks the receiver if there are properties to ignore when converting to JSON. */
+ (NSArray *)ignorePropertiesToJSON;

@end
