//
//  SKPerformanceManager.m
//  SolidKitExample
//
//  Created by 孙恺 on 2017/3/4.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import "SKPerformanceManager.h"
#import "SKPerformanceMonitorFactory.h"

@implementation SKPerformanceManager

static SKPerformanceManager * _manager;

#pragma mark - Public


#pragma mark - Singleton

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc] init];
    });
    return _manager;
}

#pragma mark - Init

+ (void)load {
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _config = [[SKPerformanceConfig alloc] init];
    }
    return self;
}

#pragma mark - Process

- (void)threadProcess:(id)obj
{
    while (true) {
        
        @autoreleasepool {
            if ([[NSThread currentThread] isCancelled]) {
                [NSThread exit];
            }
            
            [self handleTick];
            [NSThread sleepForTimeInterval:self.config.refreshInterval];
        }
        
    }
}

- (void)handleTick
{
    NSArray<NSString *> *array = nil;
    @synchronized (self) {
        array = [[_config.performanceItems allKeys] copy];
    }
    
    //采集所有需要监控的指标
    
    for (NSString *key in array) {
        BOOL enable = ((NSNumber *)[_config.performanceItems objectForKey:key]).boolValue;
        if (enable) {
            id itemClass = NSClassFromString(key);
            [[[SKPerformanceMonitorFactory sharedFactory] getSingletonForClass:itemClass] performSelector:@selector(handleTick)];
        }
    }
}

@end
