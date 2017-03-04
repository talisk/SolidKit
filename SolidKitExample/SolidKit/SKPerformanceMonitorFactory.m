//
//  SKPerformanceMonitorFactory.m
//  SolidKitExample
//
//  Created by 孙恺 on 2017/3/4.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import "SKPerformanceMonitorFactory.h"

@interface SKPerformanceMonitorFactory ()

@property (nonatomic, strong) NSMutableDictionary *warehouse;

@end

@implementation SKPerformanceMonitorFactory

static SKPerformanceMonitorFactory * _factory;

#pragma mark - Singleton

+ (instancetype)sharedFactory {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _factory = [[self alloc] init];
    });
    return _factory;
}

#pragma mark - Factory

- (id)getSingletonForClass:(Class)cls {
    NSString *className = NSStringFromClass(cls);
    @synchronized (className) {
        id sharedData = [self sharedObjectForKey:className];
        if (!sharedData) {
            sharedData = [[NSClassFromString(className) alloc] init];
            [self setSharedObject:sharedData forKey:className];
        }
    }
    return [self.warehouse objectForKey:className];
}

- (void)setSharedObject:(id)sharedData forKey:(NSString *)key {
    if (sharedData) {
        [self.warehouse setObject:sharedData forKey:key];
    }
}

- (id)sharedObjectForKey:(NSString *)key {
    return [self.warehouse objectForKey:key];
}

#pragma mark - Init

+ (void)load {
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _warehouse = [[NSMutableDictionary alloc] init];
    }
    return self;
}


@end
