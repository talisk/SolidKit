//
//  SKPerformanceConfig.m
//  SolidKitExample
//
//  Created by 孙恺 on 2017/3/4.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import "SKPerformanceConfig.h"
#import "SKPerformanceMonitorFactory.h"

@interface SKPerformanceConfig ()

@property (nonatomic, copy, readonly) NSMutableDictionary *performanceItems;

@end

@implementation SKPerformanceConfig

static NSString *switcherKeypath;
static NSArray<NSString *> *performanceItemKeys;

- (NSInteger)getPerformanceTypeCount {
    return performanceItemKeys.count;
}

- (NSString *)getMonitorKeyWithItem:(SKPerformanceMonitorItemType)item {
    return performanceItemKeys[item];
}

- (void)addMonitorItem:(SKPerformanceMonitorItemType)item {
    [self.performanceItems setValue:@1 forKey:performanceItemKeys[item]];
}

- (void)removeMonitorItem:(SKPerformanceMonitorItemType)item {
    [self.performanceItems setValue:@0 forKey:performanceItemKeys[item]];
}

- (BOOL)getMonitorState:(SKPerformanceMonitorItemType)item {
    return ((NSNumber *)[self.performanceItems objectForKey:performanceItemKeys[item]]).boolValue;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _refreshInterval = 1;
        _performanceItems = [[NSMutableDictionary alloc] init];
        for (NSString *itemKey in performanceItemKeys) {
            [_performanceItems setValue:@0 forKey:itemKey];
        }
        [self
         addObserver:[[SKPerformanceMonitorFactory sharedFactory]
                      getSingletonForClass:NSClassFromString(@"SKPerformanceSmoothMonitor")]
         forKeyPath:switcherKeypath
         options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
         context:NULL];
    }
    return self;
}

+ (void)initialize {
    performanceItemKeys = @[@"SKPerformanceCPUMonitor",
                            @"SKPerformanceMemoryMonitor",
                            @"SKPerformanceSmoothMonitor",];
    switcherKeypath = @"performanceItems.SKPerformanceSmoothMonitor";
}

- (void)dealloc {
    [self
     removeObserver:[[SKPerformanceMonitorFactory sharedFactory]
                     getSingletonForClass:NSClassFromString(@"SKPerformanceSmoothMonitor")]
     forKeyPath:switcherKeypath];
}

@end
