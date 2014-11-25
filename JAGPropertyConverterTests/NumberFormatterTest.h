//
//  NumberFormatterTest.h
//  JAGPropertyConverter
//
//  Created by James Gill on 9/19/12.
//
//

#import <SenTestingKit/SenTestingKit.h>

@interface NumberTestModel : NSObject

@property (nonatomic, assign) BOOL boolProperty;
@property (nonatomic, assign) int intProperty;
@property (nonatomic, assign) float floatProperty;
@property (nonatomic, assign) double doubleProperty;
@property (nonatomic, assign) long long longLongProperty;
@property (nonatomic, strong) NSString *stringProperty;
@property (nonatomic, strong) NSNumber *numberProperty;
@property (nonatomic, strong) NSNumber *boolNumberProperty;

@end


@interface NumberFormatterTest : SenTestCase

@end
