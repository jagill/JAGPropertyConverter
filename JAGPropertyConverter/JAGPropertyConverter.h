//
//  JAGPropertyConverter.h
//  JAGPropertyConverter
//
//  Created by James Gill on 1/22/12.
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

#import <Foundation/Foundation.h>


typedef enum {
    kJAGFullOutput,
    kJAGPropertyListOutput,
    kJAGJSONOutput
} JAGOutputType;

///A Block to identify what class a dictionary represents.
typedef Class (^IdentifyBlock)(NSDictionary *dictionary);

///A Block to convert one object to another, for converting to/from JSON
typedef id (^ConvertBlock)(id obj);

///A Block to test a given object against some criterion.
typedef BOOL (^CriterionBlock)(id obj);

///A Block to test a given class against some criterion.
typedef BOOL (^ClassCriterionBlock)(Class aClass);

@interface JAGPropertyConverter : NSObject

/**
 * The outputType property determines how an object is
 * converted to an NSDictionary.  
 * 
 * kJAGFullOutput means any object which can't be converted
 * (@see shouldConvert) will be left as is.
 *
 * kJAGPropertyListOutput means that any object can't be
 * converted and isn't a valid PropertyList value will
 * be dropped.
 *
 * kJAGJSONOutput means that any object that can't be converted
 * and isn't a valid JSON value will be dropped.  It also means
 * that non-NSString dictionary keys will be dropped.
 */
@property (nonatomic, assign) JAGOutputType outputType;

/**
 * A block that determines, when converting from a dictionary
 * to an object, what class the dictionary represents.
 * If the block returns nil, then "converting" the dictionary
 * means leaving the dictionary unchanged.
 * 
 * Example:  If the converter is trying to convert a dictionary
 * dict = {key1:value1, key2:value2}, and
 * identifyDict(dict)==[MyClass class], dict will be converted to
 * an instance myClass with myClass.key1==value1, myClass.key2==value2.
 * If identifyDict(dict)==nil, dict will be "converted"
 * to dict.
 */
@property (nonatomic, assign) IdentifyBlock identifyDict;

/**
 * A block used to determine if the converter should convert
 * this object to a dictionary of properties (and back).
 * PropertyList values are automatically handled; this is
 * for other objects.
 * Defaults to false for everything.
 */
@property (nonatomic, assign) CriterionBlock shouldConvert;

/**
 * A block used to determine if the converter should convert
 * dictionaries to this targetClass.
 * PropertyList values are automatically handled; this is
 * for other objects.
 * Defaults to false for everything.
 */
@property (nonatomic, assign) CriterionBlock shouldConvertClass;

/**
 * A Block to convert a (JSON) property to an NSDate.
 * Called when trying to set a Date property with a non-Date value.
 * TODO: Generalize converters to other classes?
 */
@property (nonatomic, assign) ConvertBlock convertToDate;

/**
 * A Block to convert an NSDate property to JSON property.
 * Called when trying to convert a Date property to JSON.
 */
@property (nonatomic, assign) ConvertBlock convertFromDate;

#pragma mark - Lifecycle

+ (JAGPropertyConverter *) converterWithOutputType: (JAGOutputType) outputType;

- (id) initWithOutputType: (JAGOutputType) outputType;

#pragma mark - Convert To Dictionary

/**
 * Convert an object (or collection of objects) into
 * an object suitable for the output.
 * -Model objects (as designated by shouldConvert:) 
 *      are converted to dictionaries
 * -Basic objects (eg NSString, NSNumber) are
 *      passed through unchanged, or dropped/converted
 *      if they are unsafe for the outputType.
 * -NSDictionaries, NSArrays, and NSSets are converted
 *      recursively.
 */
- (id) convertObjectToProperties: (id) object;

/**
 * Convert a single model object (subclass of NSObject with
 * properties) into an NSDictionary with those properties as
 * key:value pairs.
 */
- (NSDictionary*) convertToDictionary: (id) model;

#pragma mark - Convert From Dictionary

/**
 * Recursively converts a property (single object,
 * NSArray, NSSet, or NSDictionary) to a model object
 * (or collection thereof).  If a class is detected for
 * an NSDictionary via identifyDict:, an object of that
 * class is instantiated and populated via 
 * setPropertiesOf:fromDictionary:.
 * Unidentified NSDictionaries, NSArrays, and NSSets
 * are recursively converted.
 */
- (id) convertPropertyToObject: (id) property;

/**
 * Sets the properties of @param model (subclass of NSObject with properties)
 * from the entries of the given dictionary.  The keys are used as property names,
 * which are set to the corresponding values.
 * Properties whose names are not in the dictionary are unaffected.
 */
- (void) setPropertiesOf: (id) model fromDictionary: (NSDictionary*) dictionary;

@end
