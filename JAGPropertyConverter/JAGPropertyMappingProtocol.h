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

/** Asks the receiver if there are any enum values which should be converted.
 *
 * @important The property name must always match the property name where it came from. (eg. fromJSON = the json name, toJSON = the model property name)
 *            if the name is custom-name mapped.
 *
 * @return A array with NSString property names which are indicating the properties for the model which are enums and should be converted to something else.
 *         Implement convertToEnum and convertFromEnum to handle this.
 */
- (NSArray *)enumPropertiesToConvertFromJSON;

/** Asks the receiver if there are any enum values which should be converted.
 *
 * @important The property name must always match the property name where it came from. (eg. fromJSON = the json name, toJSON = the model property name)
 *            if the name is custom-name mapped.
 *
 * @return A array with NSString property names which are indicating the properties for the model which are enums and should be converted to something else.
 *         Implement convertToEnum and convertFromEnum to handle this.
 */
- (NSArray *)enumPropertiesToConvertToJSON;

/** Asks the receiver if there are properties to ignore when converting from JSON. */
- (NSArray *)ignorePropertiesFromJSON;

/** Asks the receiver if there are properties to ignore when converting to JSON. */
- (NSArray *)ignorePropertiesToJSON;

@end
