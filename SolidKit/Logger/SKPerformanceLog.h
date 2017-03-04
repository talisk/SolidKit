//
//  SKPerformanceLog.h
//  SolidKitExample
//
//  Created by 孙恺 on 2017/3/4.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SKPerformanceLogType) {
    SKPerformanceLogPerformanceTypeMemoryUsage = 1,
    SKPerformanceLogPerformanceTypeCPUUsage = 2,
    SKPerformanceLogPerformanceTypeSmooth = 3,
    SKPerformanceLogPerformanceTypeBattery = 4,
};

extern void __SKPerformanceLog(SKPerformanceLogType performance_type,
                               NSString *format, ...) NS_FORMAT_FUNCTION(2, 3);
