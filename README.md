# JAGPropertyConverter

JAGPropertyConverter is a library to allow easy serialization/deserialization to/from JSON or PropertyList formats.  

## Overview

JAGPropertyConverter allows you to convert a JSON dictionary such as

    { 
        "userID" : 1234,
        "name" : "Jane Smith",
        "likes" : ["swimming", "movies", "tennis"],
        "invitedBy" : { 
            "userID" : 9876,
            "name" : "Bob Willis"
        },
        "friends" : [
            { "userID" : 8873, "name" : "Jodi Fischer" },
            { "userID" : 9876, "name" : "Bob Willis" }
        ]

    }

to/from Objective-C "model" classes such as:

    @interface User : NSObject
        @property (assign)  int         userID;
        @property (copy)    NSString    *name;
        @property (strong)  NSArray     *likes;
        @property (strong)  User        *invitedBy;
        @property (strong)  NSSet       *friends;
    @end

It does this by using the objc runtime library to discover which properties are defined on an object, and then using Key-Value coding to set/retrieve the values.

It will convert recursively, so a model's dictionary of models with array properties of further models will be handled correctly.

There are three "outputTypes" that the converter supports when converting from a model to an NSDictionary: Full, PropertyList, and JSON.

* Full output "converts" any unrecognized NSObject subclass to itself.  Thus the NSDictionary would have a value of that object.
* PropertyList output drops any unrecognized NSObject subclass, so that the resultant NSDictionary is PropertyList-compliant. (But see the section on NSURL below)
* JSON output drops any unrecognized NSObject subclass, so that the resultant NSDictionary is JSON-compliant.  (But see the sections on NSURL and NSDate below).

### Models

Converterting from a Model to an NSDictionary is relatively straightforward, using the property name as a key and the property value as a value.  Converting from an NSDictionary to a model requires an important first step of recognizing what Model class the NSDictionary represents.  JAGPropertyConverter has an "identifyDict" block property that checks any NSDictionary value, and if it returns a Class, the converter attempts to convert the NSDictionary into that class.  If identifyDict returns nil, the converter leaves the NSDictionary unchanged.

To determine which NSObject subclasses are considered "Models" (i.e., which it should convert), JAGPropertyConverter relies on its classesToConvert property.  Objects which are subclasses of a Class in classesToConvert are converted.

By default, weak/assign object pointers are not converted (but assign properties for scalars are).  This is because weak references often indicate a retain loop (eg, between an object and its delegate), which would lead to cycle in the object graph and thence an infinite loop in the conversion.  This property can be controlled by the "shouldConvertWeakProperties" in JAGPropertyConverter.
 
### NSURL

NSURL properties are not technically valid for JSON or ProperyLists, so JAGPropertyConverter serializes/deserializes them using the string of the absolute path.

### NSDate

NSDate properties are not valid for JSON, and different use cases will call for different serialization methods.  We allow for this by the convertToDate and convertFromDate block properties.  They are called when converting to/from NSDate properties with JSON output type.

### NSData

JAGPropertyConverter converts NSData into for example Base 64 string and vice-versa as needed.

### NSObject properties

NSObject itself has some properties.  JAGPropertyFinder ignores these.  If there is need in the future, JAGPropertyFinder could take a setting determining whether it ignores or finds those properties.

### NSSet

JAGPropertyConverter converts arrays to sets and vice-versa, as needed.

### Enums

JAGPropertyConverter also supports conversion of NS_ENUMs to strings and vice-versa.

## New Features Since 0.2.0

* Custom property name mapping: `JAGPropertyMapping`
* Support converting `NSData` (eg. into Base64 strings): `convertToData` and `convertFromData`
* Support converting enums: `convertToEnum` and `convertFromEnum`
* Support for auto converting to/from **snake_case**: `enableSnakeCaseSupport`
* Support for ingoring `nil`/`null` vales: `shouldIngoreNullValues`
* Support to ignore `weak` properties for serialization: `shouldConvertWeakProperties`
* Extracted and restructured some methods so JAGPropertyConverter can be subclassed: `JAGPropertyConverter+Subclass.h`
* Enhanced `identifyDict`: it will now pass in the dictionary name (breaking change!)

## Example Usage

    //Serialization
    MyModel *model = [MyModel populatedModel];
    JAGPropertyConverter *converter = [[JAGPropertyConverter alloc] initWithOutputType:kJAGJSONOutput];
    converter.classesToConvert = [NSSet setWithObject:[MyModel class]];
    NSDictionary *jsonDictionary = [converter convertToDictionary:model];

    //Deserialization
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithContentsOfFile:@"/path/to/model.json"];
    JAGPropertyConverter *converter = [[JAGPropertyConverter alloc] init];
    converter.identifyDict = ^(NSDictionary *dict) {
        if ([dict valueForKey:@"userID"]) {
            return [User class];
        } else if ([dict valueForKey:@"primaryKey"]) {
            return [MyModel class];
        }
        return nil;    
    }
    MyModel *model = [converter composeModelFromObject:jsonDictionary];
    
The converter can also handle NSArray, NSSet, and NSDictionary inputs as well.  To see an extensive set of code samples, look at JAGPropertyConverterTests/ExampleTest.m .

## Things to do

Since JAGPropertyConverter uses Key-Value coding to get/set values, it doesn't respect custom getters and setters with non-standard names.  JAGProperty has this ability, so we could in theory support this.  Two things have dissuaded us so far.  The first is that ARC produces warnings, since you are invoking an unknown (to it) selector to get/set properties, so it can't ensure memory management is handled correctly.  The second is that Key-Value coding handles scalars decently well, which would take a little more work to do when directly using the properties getters and setters.

While Key-Value coding handles struct (and similar) scalars decently well, we have not yet enabled JAGPropertyConverter to parse them into a JSON-value format.

## Known Bugs

JAGPropertyConverter doesn't handle `NSOrderedSet`, `NSCountedSet` or custom subclasses of `NSArray`/`NSDictionary` very well.  You may find them composed into a vanilla `NSSet`/`NSArray`/`NSDictionary`.  Support for the less-common Apple-supplied classes can be implemented when it's needed, but custom subclasses would require a bit more work.

Decomposed `BOOL` properies will serialize under JSONKit to 0s and 1s.  This is actually due to a bug in Apple's Key-Value coding.  The documentation claims that it converts `aBool` into `[NSNumber numberWithBool:aBool]`, but in fact it looks like it uses `[NSNumber numberWithInt:aBool]` or similar.  JSONKit (correctly) views this as an integer, not a boolean.

## Requirements

JAGPropertyConverter requires iOS 4.0 or higher, and uses ARC.  In theory it should also work with OS X 10.6 or higher, but so far it has only been tested for iOS development.

ExampleTest.m uses the literal expressions introduced in Xcode 4.4.  Building that particular test requires Xcode 4.4, but all other files (including all files in the library proper) should work for any version of Xcode >4.0.

## Credits

JAGPropertyConverter was created by [James Gill](https://github.com/jagill/) in the development of [SpotNote](http://www.spotnote.com).  The intial code for JAGProperty came from Mike Ash's RTProperty class, in his excellent [runtime libraries](http://github.com/mikeash/MAObjCRuntime).  The documentation was generated by [appledoc](http://gentlebytes.com/appledoc/), and the tag versioning follows [Semantic Versioning](http://semver.org/).

## License

JAGPropertyConverter is available under the MIT license. See the LICENSE file for more info.

