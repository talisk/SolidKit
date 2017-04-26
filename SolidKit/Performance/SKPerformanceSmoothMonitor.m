//
//  SKPerformanceSmoothMonitor.m
//  SolidKitExample
//
//  Created by 孙恺 on 2017/3/4.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import "SKPerformanceSmoothMonitor.h"
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface SKPerformanceSmoothMonitor () {
    CADisplayLink          *_displayLink;
    CFTimeInterval          _lastTime;
    NSTimeInterval          _updateInterval;
    NSUInteger              _historyCount;
    CFTimeInterval          _historySum;
}

@end

@implementation SKPerformanceSmoothMonitor

- (instancetype)init
{
    self = [super init];
    if (self) {
        _updateInterval = 0.25f;
        _historyCount = 0;
        _historySum = 0;
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(applicationWillResignActiveNotification)
                                                     name: UIApplicationWillResignActiveNotification
                                                   object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(applicationDidBecomeActiveNotification)
                                                     name: UIApplicationDidBecomeActiveNotification
                                                   object: nil];
        
        
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkProc)];
        [_displayLink setPaused:YES];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    return self;
}

- (void)displayLinkProc {
    _historyCount += _displayLink.frameInterval;
    
    CFTimeInterval interval = _displayLink.timestamp - _lastTime;
    if( interval >= _updateInterval ) {
        _lastTime = _displayLink.timestamp;
        
        Performance(SKPerformanceItemSmooth, @"%.0f", _historyCount/interval);
        
        _historyCount = 0;
    }
}

- (void)applicationDidBecomeActiveNotification {
    [_displayLink setPaused:NO];
}

- (void)applicationWillResignActiveNotification {
    [_displayLink setPaused:YES];
}

- (void)dealloc {
    [_displayLink setPaused:YES];
    [_displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"performanceItems.SKPerformanceSmoothMonitor"]) {
        
        NSNumber *new = (NSNumber *)change[@"new"];
        [_displayLink setPaused:!new.boolValue];
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
