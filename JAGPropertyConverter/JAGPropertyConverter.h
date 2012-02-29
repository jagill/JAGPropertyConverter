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

/**
 * The type of output the objects will be converted to.
 * @see outputType for more detailed description.
 */
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

/**
 * TODO: Description and examples
 */
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
 * A block that determines whether and how to convert an NSDictionary
 * into a model object.
 *
 * 
 * When converting from a PropertyList/JSON dictionary/etc, it is not
 * obvious whether an NSDictionary should be left alone or converted to
 * a model object (and if so, to which one).  In the case of an NSDictionary
 * contained within an NSArray or NSDictionary, there is not even defined
 * property class to guide the conversion.
 *
 * This block is called if the converter needs to identify whether an
 * NSDictionary should be converted to a model object.  If the block returns
 * a Class, the NSDictionary is used to set a Class instance's properties.
 * If the block returns nil, then the NSDictionary is "converted"
 * by returning an NSDictionary with its values converted recursively.
 * 
 * Example:  If the converter is trying to convert a dictionary
 * `dict = {key1:value1, key2:value2}`, and
 * `identifyDict(dict)==[MyClass class]`, dict will be converted to
 * an instance myClass with `myClass.key1==value1`, `myClass.key2==value2`.
 * If `identifyDict(dict)==nil`, dict will be "converted"
 * to an NSDictionary with each value converted.
 */
@property (nonatomic, assign) IdentifyBlock identifyDict;

/**
 * This block determines if an object should be converted
 * to an NSDictionary.
 *
 * Valid PropertyList values are automatically handled and
 * NSDate objects for JSON are handled via convertToDate and
 * convertFromDate; this is for other objects.
 *
 * Defaults to false for everything.
 *
 * TODO: Merge this with shouldConvertClass 
 */
@property (nonatomic, assign) CriterionBlock shouldConvert;

/**
 * This block determines if an object of the Class should be converted
 * to an NSDictionary, and if unidentified dictionaries (@see identifyDict)
 * should be forcibly converted to properties of the Class.
 * 
 * Valid PropertyList values are automatically handled and
 * NSDate objects for JSON are handled via convertToDate and
 * convertFromDate; this is for other objects.
 *
 * Defaults to false for everything.
 *
 * TODO: Merge this with shouldConvert
 */
@property (nonatomic, assign) CriterionBlock shouldConvertClass;

/**
 * A Block to convert a (JSON) property to an NSDate.
 * 
 * This block is called when trying to set an object's NSDate property
 * with a dictionary's non-NSDate value.  If this block is nil,
 * the NSDate property will be set to nil.
 *
 * The issue (see [JAGPropertyConverter convertFromDate]) is that there
 * are many ways to convert an NSDate into a JSON-compatible format
 * (seconds from epoch, UTC string, etc), and instead of guessing
 * JAGPropertyConverter relies on this block to handle the conversion.
 *
 * TODO: Generalize converters to other classes?
 */
@property (nonatomic, assign) ConvertBlock convertToDate;

/**
 * A Block to convert an NSDate property to JSON property.
 *
 * Called when trying to convert an object's NSDate property
 * to a JSON dictionary value.  If this block is nil, the 
 * value will not be set.
 *
 * The issue (see [JAGPropertyConverter convertToDate]) is that there
 * are many ways to convert an NSDate into a JSON-compatible format
 * (seconds from epoch, UTC string, etc), and instead of guessing
 * JAGPropertyConverter relies on this block to handle the conversion.
 *
 * TODO: Generalize converters to other classes?
 */
@property (nonatomic, assign) ConvertBlock convertFromDate;

/**
 * Whether an object's weak properties should be converted to dictionary values.
 *
 * Default is NO, since weak properties often denote
 * retain cycles and thus cyclical object graphs, which the converter
 * does not handle.
 */
@property (nonatomic, assign) BOOL shouldConvertWeakProperties;

#pragma mark - Lifecycle

+ (JAGPropertyConverter *) converterWithOutputType: (JAGOutputType) outputType;

- (id) initWithOutputType: (JAGOutputType) outputType;

#pragma mark - Convert To Dictionary

/**
 * Convert an object (or collection of objects) into
 * an NSDictionary (or collection thereof) based on the outputType.
 * 
 * - Model objects (as designated by shouldConvert:) 
 *      are converted to dictionaries
 * - Basic objects (eg NSString, NSNumber) are
 *      passed through unchanged, or dropped/converted
 *      if they are unsafe for the outputType.
 * - NSDictionaries, NSArrays, and NSSets are converted
 *      recursively.
 *
 * If the outputType is kJAGJSONOutput, the returned value
 * is JSON-compliant.  If the outputType is kJAGPropertyListOutput,
 * the returned value is PropertyList-compliant.  If necessary,
 * objects are dropped in conversion to ensure compliance.
 *
 * @param object The model object (or collection of model objects) to convert.
 * @return An NSDictionary (or collection thereof) of 
 * propertyName : propertyValue key-value pairs.
 */
- (id) convertObjectToProperties: (id) object;

/**
 * Convert a single model object (subclass of NSObject with
 * properties) into an NSDictionary with those properties as
 * key:value pairs.
 *
 * If the outputType is kJAGJSONOutput, the returned value
 * is JSON-compliant.  If the outputType is kJAGPropertyListOutput,
 * the returned value is PropertyList-compliant.  If necessary,
 * objects are dropped in conversion to ensure compliance.
 *
 * Note that this will convert any object with properties,
 * regardless of the shouldConvert or shouldConvertClass blocks.
 *
 * @param model The model object to convert.
 * @return An NSDictionary of 
 * propertyName : propertyValue key-value pairs.
 */
- (NSDictionary*) convertToDictionary: (id) model;

#pragma mark - Convert From Dictionary

/**
 * Recursively converts a property (PropertyList object,
 * NSArray, NSSet, or NSDictionary) to a model object
 * (or collection thereof).
 *
 * If an NSDictionary is encountered and identified via identifyDict:,
 * an object of the identified Class is instantiated and populated via 
 * setPropertiesOf:fromDictionary:.  Unidentified NSDictionaries, NSArrays, and NSSets
 * are recursively converted.
 *
 * @param property An object (or collection thereof) to be converted.
 * @return A model object (or collection thereof) with properties 
 */
- (id) convertPropertyToObject: (id) property;

/**
 * Sets the properties of model (subclass of NSObject with properties)
 * from the entries of the given dictionary.
 * 
 * The keys are used as property names, which are set to the corresponding values.
 * Properties whose names are not keys in the dictionary are unset and unaffected.
 *
 * @param model Model to set the properties of.
 * @param dictionary Dictionary of values for the model's properties.
 */
- (void) setPropertiesOf: (id) model fromDictionary: (NSDictionary*) dictionary;

@end
