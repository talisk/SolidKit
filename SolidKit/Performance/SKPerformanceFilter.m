//
//  SKPerformanceLastStatus.m
//  SolidKitExample
//
//  Created by Sun,Kai(BBTD) on 2017/4/18.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import "SKPerformanceFilter.h"

@interface SKPerformanceFilter ()

@property (nonatomic, assign, class) float memory;

@property (nonatomic, assign, class) float cpuThreshold;
@property (nonatomic, assign, class) float memoryGrowthThreshold;
@property (nonatomic, assign, class) float smoothThreshold;

@end

@implementation SKPerformanceFilter

#pragma mark - Public

+ (void)setupPerformanceThresholdCPU:(SKPerformanceCPUThreshold)cpuThreshold memory:(SKPerformanceMemoryGrowthThreshold)memoryGrowthThreshold smooth:(SKPerformanceSmoothThreshold)smoothThreshold {
    [self setCpuThreshold:cpuThreshold * 0.01];
    [self setMemoryGrowthThreshold:memoryGrowthThreshold * 1.0];
    [self setSmoothThreshold:smoothThreshold * 1.0];
}

+ (void)updateMemoryStatus:(float)memory {
    [self setMemory:memory];
}

+ (BOOL)needLogPerformanceItemType:(SKPerformanceMonitorItemType)itemType newValue:(float)newValue {
    switch (itemType) {
        case SKPerformanceItemCPU:
            return (newValue > [self cpuThreshold]) ? YES : NO;
        case SKPerformanceItemMemory:
            return ([self memory] + [self memoryGrowthThreshold] < newValue) ? YES : NO;
        case SKPerformanceItemSmooth:
            return (newValue < [self smoothThreshold]) ? YES : NO;
        default:
            return NO;
    }
}

#pragma mark - Class Property

static float _memory = 0.0;

static float _cpuThreshold = 0.98;
static float _memoryGrowthThreshold = 30.0;
static float _smoothThreshold = 50.0;

+ (float)cpuThreshold {
    return _cpuThreshold;
}

+ (float)memoryGrowthThreshold {
    return _memoryGrowthThreshold;
}

+ (float)smoothThreshold {
    return _smoothThreshold;
}

+ (void)setCpuThreshold:(float)cpuThreshold {
    _cpuThreshold = cpuThreshold;
}

+ (void)setMemoryGrowthThreshold:(float)memoryGrowthThreshold {
    _memoryGrowthThreshold = memoryGrowthThreshold;
}

+ (void)setSmoothThreshold:(float)smoothThreshold {
    _smoothThreshold = smoothThreshold;
}

+ (float)memory {
    return _memory;
}

+ (void)setMemory:(float)memory {
    _memory = memory;
}

@end
