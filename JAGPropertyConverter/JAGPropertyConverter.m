//
//  JAGPropertyConverter.m
//  JAGPropertyConverter
//
//  Created by James Gill on 2/13/12.
//
// Copyright (c) 2012 James A. Gill
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "JAGPropertyConverter.h"
#import "JAGPropertyConverter+Subclass.h"
#import "JAGPropertyFinder.h"
#import "JAGProperty.h"
#import "NSString+JAGSnakeCaseSupport.h"

@interface JAGPropertyConverter ()

- (id) composeCollection: (id) collection withTargetClass: (Class) targetClass;

/*
 * This converts a property to a PropertyModel-friendly form.
 * Dictionaries that can be detected as a PropertyModel subclass
 * are converted to that subclass and returned.
 * Other collections of objects are turned as those same collections,
 * but with their elements/values converted recursively.
 * Other objects, if they match the target class, are returned
 * unmodified, while "Base" PropertyList objects 
 * (NSNull, NSString, NSNumber, NSDate, NSData, and NSValue) are
 * returned either unmodified, or if there is a 'convertable'
 * targetClass, converted to that.
 */
- (id) composeModelFromObject: (id) object withTargetClass: (Class) targetClass propertyName: (NSString *) propertyName;

- (BOOL) shouldConvertClass: (Class) aClass;

@end

@implementation JAGPropertyConverter

#pragma mark - Lifecycle

+ (JAGPropertyConverter *) converterWithOutputType: (JAGOutputType) outputType {
    return [[JAGPropertyConverter alloc] initWithOutputType:outputType];
}

- (id) initWithOutputType: (JAGOutputType) outputType {
    self = [super init];
    if (self) {
        self.outputType = outputType;
        self.identifyDict = nil;
        self.convertToDate = nil;
        self.convertToData = nil;
        self.convertFromDate = nil;
        self.convertFromData = nil;
        self.classesToConvert = [NSMutableSet set];
        self.shouldConvertWeakProperties = NO;
        self.shouldIgnoreNullValues = YES;
        self.enableSnakeCaseSupport = NO;
    }
    return self;
}

- (id) init {
    return [self initWithOutputType:kJAGFullOutput];
}

#pragma mark - Convert To Dictionary

- (BOOL) shouldConvertClass: (Class) aClass {
    for (Class class in self.classesToConvert) {
        if ([aClass isSubclassOfClass:class]) {
            return YES;
        }
    }
    return NO;
}

- (id) decomposeObject: (id) object {
    return [self recursiveDecomposeObject:object];
}

// created a private recursive method so subclasses of JAGPropertyConverter can simply override the public method (decomposeObject:) to do additional pre- and/or post-processing.
- (id) recursiveDecomposeObject: (id) object {
    if (!object) {
        return nil;
    } else if ([object isKindOfClass: [NSNull class]]
               || [object isKindOfClass: [NSString class]]) {
        //These objects are fine for all output types
        return object;    
    } else if ([object isKindOfClass: [NSNumber class]]) {
        if ( self.outputType == kJAGJSONOutput ) {
            if ( isfinite([object doubleValue]) ) {
                return object;
            } else {
                //JSON cannot handle +-infinity or NaN
                return nil;
            }
        } else {
            return object;
        }
    } else if ([object isKindOfClass: [NSDate class]]) {
        if ( self.outputType == kJAGFullOutput
            || self.outputType == kJAGPropertyListOutput ) {
            return object;
        } else if (self.convertFromDate) {
            return self.convertFromDate(object);
        } else {
            //Object is not safe for JSON.  Removing.
            return nil;
        }
        
    } else if ([object isKindOfClass: [NSData class]]) {
        //These objects are fine for PropertyLists, but not JSON
        if ( self.outputType == kJAGFullOutput
            || self.outputType == kJAGPropertyListOutput ) {
            return object;
        } else if (self.convertFromData) {
            return self.convertFromData(object);
        } else {
            //Object is not safe for JSON.  Removing.
            return nil;
        }
    } else if ( [object isKindOfClass: [NSValue class]] ) {
        //These objects are only ok for FullOutput
        if ( self.outputType == kJAGFullOutput ) {
            return object;
        } else {
            //Object is not safe for JSON or PropertyLists.  Removing.
            return nil;
        }
    } else if ( [object isKindOfClass: [NSURL class]] ) {
        //These objects are only ok for FullOutput
        if ( self.outputType == kJAGFullOutput ) {
            return object;
        } else {
            //Convert them to strings.
            return [object absoluteString];
        }
        
    } else if ([object isKindOfClass: [NSArray class]]) {
        NSMutableArray *array = [NSMutableArray array];
        for (id obj in object) {
            id value = [self recursiveDecomposeObject:obj];
            if (value) {
                [array addObject: value];
            } else {
                NSLog(@"Object %@ can't be converted to properties.", obj);
            }
        }
        return array;
    } else if ([object isKindOfClass: [NSSet class]]) {
        id collection;
        if (self.outputType == kJAGJSONOutput || self.outputType == kJAGPropertyListOutput) {
            //JSON and PropertyLists only support arrays.
            collection = [NSMutableArray array];
        } else {
            collection = [NSMutableSet set];
        }
        for (id obj in object) {
            id value = [self recursiveDecomposeObject:obj];
            if (value) {
                [collection addObject: value];
            } else {
                NSLog(@"Object %@ can't be converted to properties.", obj);
            }
        }
        return collection;
    } else if ([object isKindOfClass: [NSDictionary class]]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        for (id key in object) {
            if ( self.outputType == kJAGJSONOutput && ![key isKindOfClass:[NSString class]] ) {
                NSLog(@"JSON dictionaries must have string keys, skipping key %@", key);
                continue;
            }
            id value = [self recursiveDecomposeObject:[object objectForKey: key]];
            if (value) {
                [dict setObject: [self recursiveDecomposeObject: value] forKey: key];
            } else {
                NSLog(@"Unable to convert %@ to properties.", [object objectForKey: key]);
            }
        }
        return dict;
    } else if ([self shouldConvertClass:[object class]]) {
        return [self convertToDictionary:object];
    } else {
        if ( self.outputType == kJAGFullOutput ) {
            return object;
        } else {
            NSLog(@"Object %@ is not safe for JSON or PropertyLists.  Removing.", [object class]);
            return nil;
        }
    }
    
}

- (NSDictionary*) convertToDictionary: (id) model {
    if (!model) return nil;

    // see if target object has defined custom mappings
    NSDictionary *customMapping = [self getCombinedDictionaryFromAllInheritanceForObject:model classSelector:@selector(customPropertyNamesMapping)];
    
    // see if we have to convert enums to strings
    NSDictionary *enumMapping = [self getCombinedDictionaryFromAllInheritanceForObject:model classSelector:@selector(enumPropertiesToConvert)];
    
    // get all properties which should be ignored
    NSArray *ignoreProperties = [self getCombinedArrayFromAllInheritanceForObject:model classSelector:@selector(ignorePropertiesToJSON)];

    NSMutableDictionary *values = [NSMutableDictionary dictionary];
    NSArray* properties = [JAGPropertyFinder propertiesForClass:[model class]];
    NSString* propertyName;
    for (JAGProperty *property in properties) {
        // ignore weak properties
        if (!self.shouldConvertWeakProperties && [property isWeak]) {
            continue;
        }
        
        SEL getter = [property getter];
        if (![model respondsToSelector:getter]) {
            //Found property without a valid getter. Skipping.
            continue;
        }
        propertyName = [property name];
        
        //TODO: Should use the getter for this?  Harder to handle non-objects.
        id object = [model valueForKey:propertyName];

        // custom property mapping
        if (customMapping[propertyName]) {
            propertyName = [customMapping[propertyName] copy]; // copy the new name, will crash otherwise
        }
        
        // check if we should ignore this property
        BOOL shouldIgnoreValue = NO;
        for (NSString *propertyToIgnore in ignoreProperties) {
            if ([property.name isEqualToString:propertyToIgnore]) {
                shouldIgnoreValue = YES;
                break;
            }
        }
        
        if (shouldIgnoreValue) {
            continue;
        }

        // check if this property must be converted from enum
        if (enumMapping && self.convertFromEnum && [property isNumber]) {
            if (enumMapping[property.name]) {
                object = self.convertFromEnum(property.name, object, [model class]);    // eg. converts enum (NSInteger) into string
            }
        }
        
        // convert to snake case?
        if (self.enableSnakeCaseSupport) {
            propertyName = [propertyName asUnderscoreFromCamelCase];
        }
        
        // set value in dictionary
        [values setValue:[self recursiveDecomposeObject: object] forKey:propertyName];
    }

    // Add all custom keypaths defined for the model.
    if (customMapping) {
        for (NSString *customKey in customMapping) {
            BOOL isKeyPath = [self _isKeyPathKey:customKey];
            if (isKeyPath) {
                [values setValue:[self recursiveDecomposeObject:[model valueForKeyPath:customKey]] forKey:customMapping[customKey]];
            }
        }
    }

    return values;
}


#pragma mark - Convert From Dictionary

- (id) composeCollection: (id) collection withTargetClass: (Class) targetClass {
    return [self composeCollection: collection withTargetClass: targetClass propertyName: nil];
}

- (id) composeCollection: (id) collection withTargetClass: (Class) targetClass propertyName:(NSString *)propertyName {
    if (!targetClass) {
        targetClass = [collection class];
    }
    id mutableCollection;
    //FIXME: If targetClass is a proper subclass, the property may not be settable to mutableCollection.
    if ([targetClass isSubclassOfClass:[NSArray class]]) {
        mutableCollection = [[NSMutableArray alloc] init];
    } else if ([targetClass isSubclassOfClass:[NSSet class]]) {
        mutableCollection = [[NSMutableSet alloc] init];
    } else {
        //TODO: Catch mutisets and the like.
        NSLog(@"Unable to convert %@ to collection type %@", [collection class], targetClass);
        return nil;
    }
    for (id elt in collection) {
        id value = [self composeModelFromObject:elt propertyName:propertyName];
        if (value) {
            [mutableCollection addObject: value];
        } else {
            NSLog(@"Object %@ can't be converted to properties.", [elt class]);
        }
    }
    return mutableCollection;
}

- (id) composeModelFromObject:(id)object {
    return [self composeModelFromObject:object propertyName: nil];
}

- (id) composeModelFromObject: (id) object propertyName: (NSString *)properyName {
    return [self composeModelFromObject: object withTargetClass: nil propertyName: properyName];
}

- (id) composeModelFromObject: (id) object withTargetClass: (Class) targetClass propertyName: (NSString *) propertyName {
    if (!object) {
        return nil;
    } else if ([object isKindOfClass: [NSArray class]]
               || [object isKindOfClass: [NSSet class]]) {
        return [self composeCollection:object withTargetClass:targetClass propertyName:propertyName];
    } else if ([object isKindOfClass: [NSDictionary class]]) {
        //Is this a PropertyModel in disguise?
        Class modelClass = nil;
        if (self.identifyDict) {
            modelClass = self.identifyDict(propertyName, object);
        }
        if (modelClass) {
            id model = [[modelClass alloc] init];
            [self setPropertiesOf:model fromDictionary:object];
            return model;
        } else if (targetClass && [self shouldConvertClass:targetClass]) {
            //Try to coerce it into targetClass.
            id model = [[targetClass alloc] init];
            [self setPropertiesOf:model fromDictionary:object];
            return model;
        } else {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            for (id key in object) {
                [dict setValue: [self composeModelFromObject: [object valueForKey: key] propertyName:key]
                        forKey: key];
            }
            return dict;
        }
    } else if (targetClass && [object isKindOfClass: targetClass]) {
        //TODO: If there are other collections that aren't subclasses of NSSet, NSArray, or NSDictionary,
        //this won't convert their elements/values.
        return object;
    } else if (targetClass 
               && [targetClass isSubclassOfClass:[NSDate class]] 
               && self.convertToDate) {
        //        NSLog(@"Found prop %@ for NSDate targetClass.  Converting.", prop);
        return self.convertToDate(object);
    } else if (targetClass
               && [targetClass isSubclassOfClass:[NSData class]]
               && self.convertToData) {
        //        NSLog(@"Found prop %@ for NSData targetClass.  Converting.", prop);
        return self.convertToData(object);
    } else if ( targetClass
               && [targetClass isSubclassOfClass:[NSURL class]]
               && [object isKindOfClass:[NSString class]]
               )
    {        
        return [NSURL URLWithString:object];
    } else if ( self.numberFormatter
               && targetClass
               && [targetClass isSubclassOfClass:[NSNumber class]]
               && [object isKindOfClass:[NSString class]])
    {
        return [self _numberFromString:object];
    } else if ([object  isKindOfClass: [NSNull class]]
               || [object isKindOfClass: [NSString class]]
               || [object isKindOfClass: [NSNumber class]]
               || [object isKindOfClass: [NSDate class]]
               || [object isKindOfClass: [NSData class]]
               || [object isKindOfClass: [NSValue class]]
               ) {
        return object;
    }
    
    //TODO: Don't know what to do with this!  If we are using fullOutputType, we might be
    //getting other NSObject types, which we should be able to handle.
    NSLog(@"Unable to convert value %@ to an object property, returning nil.", [object class]);
    return nil;
    
}

- (void) setPropertiesOf: (id) object fromDictionary: (NSDictionary*) dictionary {    
    // see if target object has some enums to convert (JSON --> Model, swap dict)
    NSDictionary *enumMapping = [self getCombinedDictionaryFromAllInheritanceForObject:object classSelector:@selector(enumPropertiesToConvert)];
    enumMapping = [enumMapping swapKeysWithValues];
    
    for (NSString *dictKey in dictionary) {
        BOOL isKeyPath = NO;
        NSString *remainingKeyPath = nil;
        
        // find correct property for given key
        JAGProperty *property = [self findPropertyOfObject:object forKey:dictKey isKeyPath:&isKeyPath remainingKeyPath:&remainingKeyPath];
        
        if (!property || [property isReadOnly]) {
            continue;
        }
        
        id value = [dictionary valueForKey:dictKey];
        
        // NSNull handling
        if ([value isKindOfClass:[NSNull class]]) {
            if (self.shouldIgnoreNullValues) {
                // ignore NSNull values (leave property value as is)
                continue;
            } else {
                // clear property value (set property to nil)
                if ([property isNumber]) {
                    [object setValue:@(0) forKey:property.name]; // for primitive data types we still need an object
                } else {
                    [object setValue:nil forKey:property.name];
                }
                continue;
            }
        }
        
        // check if the property should be converted to an enum
        if (enumMapping && self.convertToEnum && [property isNumber]) {
            if (enumMapping[dictKey] || enumMapping[[dictKey asUnderscoreFromCamelCase]]) {
                [object setValue:@(self.convertToEnum(dictKey, value, [object class])) forKey:property.name];
                continue;                
            }
        }
        
        //See if we should convert an NSString to an NSNumber
        if (self.numberFormatter && [value isKindOfClass:[NSString class]]) {
            //Handle NSNumber propertyClasses in the compose function
            if (property.isBoolean) {
                value = @([dictionary[dictKey] boolValue]);
            } else if (property.isNumber) {
                value = [self _numberFromString:value];
            }
        }
        if ([property isObject]) {
            Class propertyClass = [property propertyClass];
            
            NSString *propertyName = self.enableSnakeCaseSupport ? [dictKey asCamelCaseFromUnderscore] : dictKey;
            value = [self composeModelFromObject: value withTargetClass:propertyClass propertyName:propertyName];
        }

        // If the key is a keypath set the value of the property by recursively going through the keypath segments
        if (isKeyPath && remainingKeyPath != nil) {
            id ownedObject;

            if (![object valueForKey:property.name]) {
                [object setValue:[[property.propertyClass alloc] init] forKey:property.name];
            }

            ownedObject = [object valueForKey:property.name];

            // Continue recursively
            [self setPropertiesOf:ownedObject fromDictionary:@{remainingKeyPath: value}];
        } else if ([property canAcceptValue:value]) {
            [object setValue:value forKey:property.name];
        } else {
            NSLog(@"Unable to set value of class %@ into property %@ of typeEncoding %@",
                  [value class], [property name], [property typeEncoding]);
        }
    }
}

#pragma mark - Subclass Methods

- (JAGProperty *)findPropertyOfObject:(id)object forKey:(NSString *)dictKey {
    return [self findPropertyOfObject:object forKey:dictKey isKeyPath:nil remainingKeyPath:nil];
}

- (JAGProperty *)findPropertyOfObject:(id)object forKey:(NSString *)dictKey isKeyPath:(BOOL *)isKeyPath remainingKeyPath:(NSString **)remainingKeyPath {
    // get all properties which should be ignored
    NSArray *ignoreProperties = [self getCombinedArrayFromAllInheritanceForObject:object classSelector:@selector(ignorePropertiesFromJSON)];

    // check if we should ignore this property
    for (NSString *propertyToIgnore in ignoreProperties) {
        if ([dictKey isEqualToString:propertyToIgnore]) {
            // ignoring property
            return nil;
        }
    }

    // see if target object has defined custom mappings. (JSON --> Model, swap dict)
    NSDictionary *customMapping = [self getCombinedDictionaryFromAllInheritanceForObject:object classSelector:@selector(customPropertyNamesMapping)];
    customMapping = [customMapping swapKeysWithValues];
    
    JAGProperty *property = nil;
    NSString *key = dictKey;
    
    // first try custom mapping
    if (customMapping[key]) {
        key = customMapping[key];
    }
    
    property = [JAGPropertyFinder propertyForName: key inClass:[object class]];
    
    if (!property) {
        // when enabled, convert to camelCase and try again fetching property
        if (self.enableSnakeCaseSupport) {
            key = [key asCamelCaseFromUnderscore];
            property = [JAGPropertyFinder propertyForName: key inClass:[object class]];
        }
        // try custom mapping after snake case converting (again)
        if (!property) {
            if (customMapping[key]) {
                key = customMapping[key];
                
                property = [JAGPropertyFinder propertyForName: key inClass:[object class] ];
            }
            
            // Check if the key is a keypath (e.g. "someProperty.somePropertyOfSomeProperty") and get the first segment (e.g. "someProperty")
            if (!property) {
                *isKeyPath = [self _isKeyPathKey:key];
                
                if (*isKeyPath) {
                    NSRange rangeOfFirstDot = [key rangeOfString:@"."];
                    *remainingKeyPath = [key substringFromIndex:rangeOfFirstDot.location + 1];
                    key = [key substringToIndex:rangeOfFirstDot.location];
                    
                    property = [JAGPropertyFinder propertyForName: key inClass:[object class]];
                }
            }
        }
        
        // after many tries, still couldn't find the property
        if (!property) {
            return nil;
        }
    }
    
    return property;
}

- (NSArray *)getCombinedArrayFromAllInheritanceForObject:(id<NSObject>)object classSelector:(SEL)classSelector {
    if (!object) {
        return nil;
    }
    
    NSMutableArray *array = [NSMutableArray array];
    Class class = object.class;
    while (class) {
        if ([class respondsToSelector:classSelector]) {
            // the following produces warning: "performSelector may cause a leak because its selector is unknown"
            // [array addObjectsFromArray:[class performSelector:classSelector]];
            
            // Workaround how-to suppress this warning: http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
            // IMP imp = class_getMethodImplementation(class, classSelector);    // this only works for instance methods. for class methods (which JAGPropertyMapping are) we need to use method_getImplementation(method)
            Method method = class_getClassMethod(class, classSelector);
            IMP imp = method_getImplementation(method);
            NSArray *(*func)(id, SEL) = (void *)imp;
            
            NSArray *superclassArray = func(class, classSelector);
            [array addObjectsFromArray:superclassArray];
        }
        
        // go up the inheritance hierarchy
        class = class_getSuperclass(class);
    }
    
    return array.count == 0 ? nil : array;
}

- (NSDictionary *)getCombinedDictionaryFromAllInheritanceForObject:(id<NSObject>)object classSelector:(SEL)classSelector {
    if (!object) {
        return nil;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    Class class = object.class;
    while (class) {
        if ([class respondsToSelector:classSelector]) {
            // The following produces warning: "performSelector may cause a leak because its selector is unknown"
            // [dict addEntriesFromDictionary:[class performSelector:classSelector]];
            
            // How-to suppress this warning: http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
            // IMP imp = class_getMethodImplementation(class, classSelector);         // this only works for instance methods. for class methods (which JAGPropertyMapping are) we need to use method_getImplementation(method)
            Method method = class_getClassMethod(class, classSelector);
            IMP imp = method_getImplementation(method);
            NSDictionary *(*func)(id, SEL) = (void *)imp;
            
            NSDictionary *superclassDictionary = func(class, classSelector);
            [dict addEntriesFromDictionary:superclassDictionary];
        }
        
        // go up the inheritance hierarchy
        class = class_getSuperclass(class);
    }
    
    return dict.count == 0 ? nil : dict;
}

#pragma mark - Private Methods

- (NSNumber *)_numberFromString:(NSString *)value {
    NSNumber *number = [self.numberFormatter numberFromString:value];
    
    // when this method is invoked, it is garanteed that target value is of primitive or NSNumber data type:
    // but because "true" can't be converted by -[NSNumberFormatter numberFromString:] we are converting BOOL ourselfs again
    if (!number) {
        number = @([value boolValue]);
    }
    return number;
}

- (BOOL)_isKeyPathKey:(NSString *)key {
    return [key rangeOfString:@"."].location != NSNotFound;
}

@end
