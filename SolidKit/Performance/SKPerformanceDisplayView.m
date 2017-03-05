//
//  SKPerformanceDisplayView.m
//  SolidKitExample
//
//  Created by 孙恺 on 2017/3/4.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import "SKPerformanceDisplayView.h"

@implementation SKPerformanceDisplayView


- (instancetype)init
{
    self = [super init];
    if (self) {
        _cpuUsage = 0;
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)setCpuUsage:(float)cpuUsage {
    _cpuUsage = cpuUsage;
    [self refresh];
}

- (void)setMemoryUsage:(float)memoryUsage {
    _memoryUsage = memoryUsage;
    [self refresh];
}

- (void)setSmooth:(float)smooth {
    _smooth = smooth;
    [self refresh];
}

- (void)setBattery:(float)battery {
    _battery = battery;
    [self refresh];
}

- (void)refresh {
    
}

@end
