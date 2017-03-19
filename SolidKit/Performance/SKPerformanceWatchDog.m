//
//  SKPerformanceWatchDog.m
//  SolidKit
//
//  Created by Sun,Kai(BBTD) on 17/3/19.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import "SKPerformanceWatchDog.h"

@interface SKPerformanceWatchDog ()

@property (nonatomic, copy) BarkingBehavior barking;
@property (nonatomic, assign) NSTimeInterval threshold;

@end

@implementation SKPerformanceWatchDog {
    NSThread *_dogThread;
    BOOL _pingTaskIsRunning;
    dispatch_semaphore_t _semaphore;
}

static SKPerformanceWatchDog * _doggy;

+ (void)sitBack {
    SKPerformanceWatchDog *dog = [SKPerformanceWatchDog hello];
    [dog sitBack];
}

+ (void)watchWithThreshold:(NSTimeInterval)threshold barkingBehavior:(BarkingBehavior)barkingBehavior {
    SKPerformanceWatchDog *dog = [SKPerformanceWatchDog hello];
    dog.barking = barkingBehavior;
    dog.threshold = threshold;
    [dog watch];
}

#pragma mark - Singleton

+ (instancetype)hello {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _doggy = [[self alloc] init];
    });
    return _doggy;
}

#pragma mark - Init

+ (void)load {
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dogThread = nil;
        _pingTaskIsRunning = YES;
        _threshold = 0.01;
        _semaphore = dispatch_semaphore_create(0);
    }
    return self;
}

- (void)dealloc {
    [self sitBack];
}


#pragma mark - Thread

- (void)watch {
    if (!_dogThread) {
        _dogThread = [[NSThread alloc] initWithTarget:self selector:@selector(threadProcess:) object:nil];
        _dogThread.name = @"com.talisk.solidkit.watchdog-thread";
        [_dogThread start];
    }
}

- (void)sitBack {
    if (_dogThread) {
        [_dogThread cancel];
        _dogThread = nil;
    }
}

- (void)threadProcess:(id)obj {
    while (true) {
        
        @autoreleasepool {
            if ([[NSThread currentThread] isCancelled]) {
                [NSThread exit];
            }
            
            _pingTaskIsRunning = YES;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                _pingTaskIsRunning = NO;
                dispatch_semaphore_signal(_semaphore);
            });
            
            [NSThread sleepForTimeInterval:self.threshold];
            
            if (_pingTaskIsRunning) {
                self.barking();
            }
            
            dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
        }
        
    }
}

@end
