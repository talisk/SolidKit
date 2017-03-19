//
//  SolidKit.m
//  SolidKitExample
//
//  Created by 孙恺 on 2017/2/26.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import "SolidKit.h"
#import "SKURLProtocol.h"
#import <UIKit/UIKit.h>
#import "UIWindow+SKManager.h"
#import "SKASL.h"
#import "SKCrashHandler.h"

static SolidKit *sharedInstance;

@implementation SolidKit

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SolidKit alloc] init];
    });
}

+ (SolidKit *)sharedKit {
    return sharedInstance;
}

- (SolidKit *(^)(BOOL))enablePerformanceMonitor {
    return ^(BOOL enable) {
        if (enable) {
            [SKPerformanceManager enableWithDefaultConfig];
            // TODO: performance items optional select
        } else {
            [SKPerformanceManager disable];
        }
        return self;
    };
}

- (SolidKit *(^)(BOOL))enableNetworkLog {
    return ^(BOOL enable) {
        if (enable) {
            [NSURLProtocol registerClass:[SKURLProtocol class]];
        } else {
            [NSURLProtocol unregisterClass:[SKURLProtocol class]];
        }
        return self;
    };
}

- (SolidKit *(^)(SKManagerKey))setManagerKey {
    return ^(SKManagerKey key) {
        [UIWindow setManagerSwitcher:key];
        return self;
    };
}

- (SolidKit *(^)(SKLogLevel))setLevel {
    return ^(SKLogLevel loglevel) {
        LogFilter(loglevel);
        return self;
    };
}

- (SolidKit *(^)())registCrashHandler {
    return ^() {
        [SKCrashHandler sharedHandler];
        return self;
    };
}

@end
