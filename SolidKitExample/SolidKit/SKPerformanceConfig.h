//
//  SKPerformanceConfig.h
//  SolidKitExample
//
//  Created by 孙恺 on 2017/3/4.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKPerformanceConfig : NSObject

@property (nonatomic, assign) NSTimeInterval refreshInterval;

@property (nonatomic, copy, readonly) NSMutableDictionary *performanceItems;

@end
