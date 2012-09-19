//
//  NumberFormatterTest.h
//  JAGPropertyConverter
//
//  Created by James Gill on 9/19/12.
//
//

#import <SenTestingKit/SenTestingKit.h>

@interface NumberTestModel : NSObject

@property (nonatomic, assign) int intProperty;
@property (nonatomic, assign) float floatProperty;
@property (nonatomic, strong) NSNumber *numberProperty;
@property (nonatomic, strong) NSString *stringProperty;

@end


@interface NumberFormatterTest : SenTestCase

@end
