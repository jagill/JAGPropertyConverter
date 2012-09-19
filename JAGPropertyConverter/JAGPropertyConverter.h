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

/**
   JAGPropertyConverter handles the decomposition of a Model object into an NSDictionary of basic types, and
   the (re)composition of NSDictionaries into model objects.
 
   We use the term _Model_ for a subclass of NSObject with defined @properties.  Although the definition
   is broad, intuitively we mean objects with data that we would like to persist or serialize, corresponding to
   Model in Model-View-Controller.  We use the term _basic type_ for the common objects of Objective-C, including
   NSString, NSNumber, NSArray, etc.  The exact definition of basic depends on the outputType, a JSON-compliant
   NSDictionary has a more restrictive set of allowed types than does a PropertyList dictionary.
 
   JAGPropertyConverter converts a given Model into an NSDictionary, with
   keys equal to the property names and values equal to the property values converted into a basic type.
   A non-collection basic type, such as NSString, is unchanged.  For a basic collection, such as NSArray, NSSet,
   or NSDictionary, the converter goes through each entry and converts it.  For a Model value, the converter
   converties it to an NSDictionary.  If the converter does not know how to handle a value, it drops it.
 
   At the end of the recursive decomposition process, a Model is converted into an NSDictionary whose values
   are all basic types and contain only basic types.  Depending on the outputType, this NSDictionary is
   JSON- or PropertyList- compliant.  The method decomposeObject: can handle an NSArray,
   NSSet, or NSDictionary of Models (or basic types, really).  The method convertToDictionary: is the primitive function
   that converts a Model into a dictionary; decomposeObject: calls that Models that
   it recognizes as candidates for conversion.
 
   The converse of decomposition is composition, which takes an NSDictionary of basic types and converts it
   to a Model.  For whichever properties the Model has which have corresponding keys in the NSDictionary,
   their value is set to the corresponding value in the NSDictionary.  If a value of the NSDictionary is itself
   an NSDictionary, the converter tries to convert it to an appropriate Model object.  Similarly, entries of
   NSArray or NSSet objects are converted as necessary.  Thus composing an NSDictionary to a Model recursively
   handles nested collections/etc.  The method composeModelFromObject: will take an arbitrary object and compose
   it into a Model (or collection thereof), while the method setPropertiesOf:fromDictionary: will set the properties
   of the supplied Model from the supplied NSDictionary.
 
   Different conversion needs are handled by the various properties of JAGPropertyConverter, which specify how
   to handle non-obvious cases.  The most important of these are outputType, identifyDict, and classesToConvert.
 
   - *outputType* specifies what basic types are acceptable, allowing PropertyList or JSON outputs to be targetted.
   - *identifyDict* is how the converter knows what Model class (if any) an NSDictionary should be composed into.
   - *classesToConvert* tells the converter which Model classes it should decompose.
 
   @warning **NB:** JAGPropertyConverter can't currently handle properties whose types are `struct`s, `union`s, blocks,
   function pointers, or `char*`.  As (or if) the need arises, we'll implement support for these.
 
 */
@interface JAGPropertyConverter : NSObject

/**
 * The outputType property determines how an object is
 * converted to an NSDictionary.  
 * 
 * kJAGFullOutput means any object which can't be converted
 * (@see classesToConvert) will be left as is.
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
@property (nonatomic, copy) IdentifyBlock identifyDict;

/**
 * A set of classes which should be converted.
 *
 * Subclasses of these classes are decomposed into NSDictionaries.
 * Also when setting a Model's properties, if the property class is a subclass
 * of these classes, the converter will coerce an unidentified NSDictionary
 * into the property.
 */
@property (nonatomic, strong) NSSet *classesToConvert;

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
@property (nonatomic, copy) ConvertBlock convertToDate;

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
@property (nonatomic, copy) ConvertBlock convertFromDate;

/**
 * A NumberFormatter to convert NSStrings to number of NSNumber properties.
 *
 * Called when composing an NSDictionary into an object, or
 * setting the properties of a model.  If not null, when the converter
 * encounters an NSString for a target property of
 * either a primitive numeric type or NSNumber, it will use
 * the [NSNumberFormatter numberFromString:] method to convert the
 * NSString into the appropriate numeric type.
 */
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;

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

#pragma mark - Decompose Model

/**
 * Convert an object (or collection of objects) into
 * an NSDictionary (or collection thereof) based on the outputType.
 * 
 * - Model objects (as designated by classesToConvert) 
 *      are converted to NSDictionaries
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
- (id) decomposeObject: (id) object;

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
 * regardless of the classesToConvert property.
 *
 * @param model The model object to convert.
 * @return An NSDictionary of 
 * propertyName : propertyValue key-value pairs.
 */
- (NSDictionary*) convertToDictionary: (id) model;

#pragma mark - Compose Model

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
 * @param object An object (or collection thereof) to be converted.
 * @return A model object (or collection thereof) with properties 
 */
- (id) composeModelFromObject: (id) object;

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
