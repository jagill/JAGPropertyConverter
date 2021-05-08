//
//  OptInNullValues.swift
//  JAGPropertyConverter
//
//  Created by Yen-Chia Lin on 27.04.16.
//
//

import XCTest

@objc(OptInNullValueTestModel)
class OptInNullValueTestModel: NSObject, JAGPropertyMapping {
    var intProperty: Int = 0
    var stringProperty: String?
    var numberProperty: NSNumber?
    var arrayProperty: [String]?
    
    static func nilPropertiesNotToIgnore() -> [String] {
        return ["stringProperty", "arrayProperty"]
    }
    
    static func customPropertyNamesMapping() -> [String : String] {
        return ["stringProperty" : "strProperty"]
    }
}

/// This tests the new feature to opt-in sending null values if a property is nil when `converter.shouldIgnoreNullValues == true`
class OptInNullValues: XCTestCase {
    private var model: OptInNullValueTestModel!
    private var converter: JAGPropertyConverter!
    
    override func setUp() {
        super.setUp()
        
        model = OptInNullValueTestModel()
        
        converter = JAGPropertyConverter()
        converter.outputType = .jagjsonOutput
        converter.classesToConvert = NSSet(array: [OptInNullValueTestModel.self]) as Set<NSObject>
        converter.shouldIgnoreNullValues = true
        converter.enableSnakeCaseSupport = true
        
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en")
        converter.numberFormatter = formatter
    }
    
    // json --> model
    func testOptInJsonToModel() {
        model.intProperty = 1337
        model.stringProperty = "Unicorns! 🦄🦄🦄"
        model.numberProperty = 7777
        model.arrayProperty = ["🌰🌰🌰"] // nuts! ;)
        
        XCTAssertEqual(model.intProperty, 1337)
        XCTAssertEqual(model.stringProperty, "Unicorns! 🦄🦄🦄")
        XCTAssertEqual(model.numberProperty, 7777)
        XCTAssertEqual(model.arrayProperty!, ["🌰🌰🌰"])
        
        let dict = [ "intProperty" : NSNull(), "strProperty" : NSNull(), "arrayProperty" : NSNull() ]    // leave out numberProperty; we don't want to touch it
        
        converter.setPropertiesOf(model, from: dict)
        
        XCTAssertEqual(model.intProperty, 1337, "NSNull values should be ignored")
        XCTAssertNil(model.stringProperty, "stringProperty should be nil, because it was optIn for deletion")
        XCTAssertEqual(model.numberProperty, 7777, "as this property was not in the dictionary, it should be untouched")
        XCTAssertNil(model.arrayProperty)
    }
    
    // model --> json
    func testOptInModelToJson() {
        model.intProperty = 42
        model.stringProperty = nil
        model.numberProperty = nil
        model.arrayProperty = nil
        
        XCTAssertNil(model.stringProperty)
        XCTAssertNil(model.numberProperty)
        XCTAssertNil(model.arrayProperty)
        
        let dict = converter.decomposeObject(model) as! NSDictionary
        let expectedDict = [ "int_property" : 42, "str_property" : NSNull(), "array_property" : NSNull() ] as NSDictionary // only stringProperty is optIn; so numberProperty will be ignored (= not in dict)
        
        XCTAssertEqual(dict, expectedDict)
    }
}
