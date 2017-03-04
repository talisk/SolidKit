//
//  SKPerformanceConfig.m
//  SolidKitExample
//
//  Created by 孙恺 on 2017/3/4.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import "SKPerformanceConfig.h"

@implementation SKPerformanceConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        _refreshInterval = 1;
        _performanceItems = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                              @"SKPerformanceCPUMonitor": @1,
                                                                              @"SKPerformanceMemoryMonitor": @1,
                                                                              @"SKPerformanceSmoothMonitor": @0,
                                                                              @"SKPerformanceBatteryMonitor": @0,
                                                                              }];
    }
    return self;
}

@end
