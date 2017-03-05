//
//  SKPerformanceManager.m
//  SolidKitExample
//
//  Created by 孙恺 on 2017/3/4.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import "SKPerformanceManager.h"
#import "SKPerformanceMonitorFactory.h"

@interface SKPerformanceManager ()

@end

@implementation SKPerformanceManager {
    NSThread *_monitorThread;
}

static SKPerformanceManager * _manager;

#pragma mark - Public

+ (void)disable {
    [[SKPerformanceManager sharedManager] threadEnd];
    
    SKPerformanceConfig *config = [SKPerformanceManager sharedManager].config;
    
    for (SKPerformanceMonitorItemType i = 0;
         i < [config getPerformanceTypeCount];
         ++i) {
        
        [config removeMonitorItem:i];
    }
    [config setRefreshInterval:0];
}

+ (void)enableWithDefaultConfig {
    SKPerformanceConfig *config = [SKPerformanceManager sharedManager].config;
    
    for (SKPerformanceMonitorItemType i = 0;
         i < [config getPerformanceTypeCount];
         ++i) {
        
        [config addMonitorItem:i];
    }
    [config setRefreshInterval:1];
    
    [[SKPerformanceManager sharedManager] threadStart];
}

+ (void)enableWithConfig:(SKPerformanceConfig *)config {
    [SKPerformanceManager sharedManager].config = config;
    
    [[SKPerformanceManager sharedManager] threadStart];
}

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
        _monitorThread = nil;
    }
    return self;
}

- (void)dealloc {
    [self threadEnd];
}


#pragma mark - Thread

- (void)threadStart {
    if (!_monitorThread) {
        _monitorThread = [[NSThread alloc] initWithTarget:self selector:@selector(threadProcess:) object:nil];
        _monitorThread.name = @"com.talisk.solidkit.perfmonitor-thread";
        [_monitorThread start];
    }
}

- (void)threadEnd {
    if (_monitorThread) {
        [_monitorThread cancel];
        _monitorThread = nil;
    }
}

#pragma mark - Process

- (void)threadProcess:(id)obj {
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

- (void)handleTick {
    
    for (SKPerformanceMonitorItemType i = SKPerformanceItemCPU;
         i < SKPerformanceItemMemory;
         ++i) {
        
        BOOL enable = [_config getMonitorState:i];
        
        if (enable) {
            id itemClass = NSClassFromString([_config getMonitorKeyWithItem:i]);
            [[[SKPerformanceMonitorFactory sharedFactory] getSingletonForClass:itemClass] performSelector:@selector(handleTick)];
        }
    }
}

@end
