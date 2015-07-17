//
//  NSDictionary+JAGKeyValueSwapping.h
//  JAGPropertyConverter
//
//  Created by Yen-Chia Lin on 17.07.15.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (JAGKeyValueSwapping)

/** Swapps the keys with the values of this dictonary.
 
 Values will become the keys of the new dictionary and keys will become values.
 
 Dict<key, value> ==> Dict<value, key>
 
 @return A new dictionary where the keys are the values from this instance and values are keys from this instance.
 */
- (NSDictionary *)swapKeysWithValues;

@end
