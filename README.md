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
        }
    }

to/from Objective-C "model" classes such as:

    @interface User : NSObject
        @property (assign)  int         userID;
        @property (copy)    NSString    *name;
        @property (strong)  NSArray     *likes;
        @property (strong)  User        *invitedBy;
    @end

It does this by using the objc runtime library to discover which properties are defined on an object, and then using Key-Value coding to set/retrieve the values.

It will convert recursively, so a model's dictionary of models with array properties of further models will be handled correctly.

There are three "outputTypes" that the converter supports when converting from a model to an NSDictionary: Full, PropertyList, and JSON.

* Full output "converts" any unrecognized NSObject subclass to itself.  Thus the NSDictionary would have a value of that object.
* PropertyList output drops any unrecognized NSObject subclass, so that the resultant NSDictionary is PropertyList-compliant. (But see the section on NSURL below)
* JSON output drops any unrecognized NSObject subclass, so that the resultant NSDictionary is JSON-compliant.  (But see the sections on NSURL and NSDate below).

### Models

Converterting from a Model to an NSDictionary is relatively straightforward, using the property name as a key and the property value as a value.  Converting from an NSDictionary to a model requires an important first step of recognizing what Model class the NSDictionary represents.  JAGPropertyConverter has an "identifyDict" block property that checks any NSDictionary value, and if it returns a Class, the converter attempts to convert the NSDictionary into that class.  If identifyDict returns nil, the converter leaves the NSDictionary unchanged.

To determine which NSObject subclasses are considered "Models" (i.e., which it should convert), JAGPropertyConverter relies on its shouldConvert: and shouldConvertClass: block properties.  Unfortunately we currently need both properties -- hopefully in the future we can just use one block which can handle either classes or NSObjects.

### NSURL

NSURL properties are not technically valid for JSON or ProperyLists, so JAGPropertyConverter serializes/deserializes them using the string of the absolute path.

### NSDate

NSDate properties are not valid for JSON, and different use cases will call for different serialization methods.  We allow for this by the convertToDate and convertFromDate block properties.  They are called when converting to/from NSDate properties with JSON output type.

### NSObject properties

NSObject itself has some properties.  JAGPropertyFinder ignores these.  If there is need in the future, JAGPropertyFinder could take a setting determining whether it ignores or finds those properties.

### NSSet

JAGPropertyConverter converts arrays to sets and vice-versa, as needed.

## Example Usage

    //Serialization
    MyModel *model = [MyModel populatedModel];
    JAGPropertyConverter *converter = [[JAGPropertyConverter alloc] initWithOutputType:kJAGJSONOutput];
    converter.shouldConvert = ^(id obj) {
        return [obj isKindOfClass:[MyModel class]];
    }
    converter.shouldConvertClass = ^(Class aClass) {
        return [aClass isSubclassOfClass:[MyModel class]];
    }
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
    MyModel *model = [converter convertPropertyToObject:jsonDictionary];
    
The converter can also handle arrays and dictionaries as inputs as well.

## Things to do

Since JAGPropertyConverter uses Key-Value coding to get/set values, it doesn't respect custom getters and setters.  JAGProperty has this ability, so we could in theory support this.  Two things have dissuaded us so far.  The first is that ARC produces warnings, since you are invoking an unknown (to it) selector to get/set properties, so it can't ensure memory management is handled correctly.  The second is that Key-Value coding handles scalars decently well, which would take a little more work to do when directly using the properties getters and setters.

While Key-Value coding handles scalars decently well, we have not yet enabled JAGPropertyConverter to parse them into a JSON-value format.

## Requirements

JAGPropertyConverter requires iOS 4.0 or higher, and uses ARC.  In theory it should also work with OS X 10.6 or higher, but so far it has only been tested for iOS development.

## Credits

JAGPropertyConverter was created by [James Gill](https://github.com/jagill/) in the development of [SpotNote](http://www.spotnote.com).  The intial code for JAGProperty came from Mike Ash's RTProperty class, in his excellent [runtime libraries](http://github.com/mikeash/MAObjCRuntime).

## License

JAGPropertyConverter is available under the MIT license. See the LICENSE file for more info.

