//
//  JAGPropertyConverter+Subclass.h
//  JAGPropertyConverter
//
//  Created by Yen-Chia Lin on 14.07.15.
//
//

#import "JAGPropertyConverter.h"
#import "JAGProperty.h"

@interface JAGPropertyConverter (Subclass)

/** Tries to find the correct property of given object in a specific order:
 
 1. is in ignorePropertiesFromJSON array? --> ignore
 2. custom property mapping
 3. convert camel/snake case (when enabled)
 4. custom property mapping (again with converted key)
 5. check if its keyPath?
 
 @param object           object to find the property for
 @param dictKey          property name
 
 @return JAGProperty object when found, otherwise nil.
 */
- (JAGProperty *)findPropertyOfObject:(id)object forKey:(NSString *)dictKey;

/** Tries to find the correct property of given object in a specific order:
 
 1. is in ignorePropertiesFromJSON array? --> ignore
 2. custom property mapping
 3. convert camel/snake case (when enabled)
 4. custom property mapping (again with converted key)
 5. check if its keyPath?
 
 @param object           object to find the property for
 @param dictKey          property name
 @param isKeyPath        Output parameter. Indicates if dictKey was a keyPath
 @param remainingKeyPath Output parameter. Returns the remaining keyPath if it was
 
 @return JAGProperty object when found, otherwise nil.
 */
- (JAGProperty *)findPropertyOfObject:(id)object forKey:(NSString *)dictKey isKeyPath:(BOOL *)isKeyPath remainingKeyPath:(NSString **)remainingKeyPath;

@end
