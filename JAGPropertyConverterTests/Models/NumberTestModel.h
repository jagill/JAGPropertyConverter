//
//  NumberTestModel.h
//  JAGPropertyConverter
//
//  Created by Yen-Chia Lin on 29.01.15.
//
//

#import <Foundation/Foundation.h>

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
