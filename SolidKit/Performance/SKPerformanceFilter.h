//
//  SKPerformanceLastStatus.h
//  SolidKitExample
//
//  Created by Sun,Kai(BBTD) on 2017/4/18.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "SKPerformanceConfig.h"

typedef NS_ENUM(NSUInteger, SKPerformanceCPUThreshold) {
    // * 0.01
    SKPerformanceCPUThreshold70percent = 70,     // 70
    SKPerformanceCPUThreshold80percent = 80,     // 80
    SKPerformanceCPUThreshold90percent = 90,     // 90
    SKPerformanceCPUThreshold95percent = 95,     // 90
    SKPerformanceCPUThreshold100percent = 100,   // 100
};

typedef NS_ENUM(NSUInteger, SKPerformanceMemoryGrowthThreshold) {
    // * 1 MB
    SKPerformanceMemoryGrowthThreshold1MByte = 1,
    SKPerformanceMemoryGrowthThreshold5MByte = 5,
    SKPerformanceMemoryGrowthThreshold10MByte = 10,
    SKPerformanceMemoryGrowthThreshold15MByte = 15,
    SKPerformanceMemoryGrowthThreshold20MByte = 20,
    SKPerformanceMemoryGrowthThreshold30MByte = 30,
    SKPerformanceMemoryGrowthThreshold40MByte = 40,
    SKPerformanceMemoryGrowthThreshold50MByte = 50,
    SKPerformanceMemoryGrowthThreshold70MByte = 70,
    SKPerformanceMemoryGrowthThreshold90MByte = 90,
    SKPerformanceMemoryGrowthThreshold120MByte = 120,
};

typedef NS_ENUM(NSUInteger, SKPerformanceSmoothThreshold) {
    // * 1
    SKPerformanceSmoothThreshold20fps = 20,
    SKPerformanceSmoothThreshold30fps = 30,
    SKPerformanceSmoothThreshold40fps = 40,
    SKPerformanceSmoothThreshold50fps = 50,
    SKPerformanceSmoothThreshold55fps = 55,
    SKPerformanceSmoothThresholdStrict = 59,
};

@interface SKPerformanceFilter : NSObject

+ (void)setupPerformanceThresholdCPU:(SKPerformanceCPUThreshold)cpuThreshold memory:(SKPerformanceMemoryGrowthThreshold)memoryGrowthThreshold smooth:(SKPerformanceSmoothThreshold)smoothThreshold;

+ (void)updateMemoryStatus:(float)memory;

+ (BOOL)needLogPerformanceItemType:(SKPerformanceMonitorItemType)itemType newValue:(float)newValue;

@end
