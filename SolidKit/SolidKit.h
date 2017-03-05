//
//  SolidKit.h
//  SolidKitExample
//
//  Created by 孙恺 on 2017/2/26.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import "SKLog.h"
#import "UIWindow+SKManager.h"
#import "SKPerformanceManager.h"

@interface SolidKit : NSObject

typedef SolidKit* (^nonParamBlock)();
typedef SolidKit* (^logLevelBlock)(SKLogLevel);
typedef SolidKit* (^managerKeyBlock)(SKManagerKey);
typedef SolidKit* (^switcherBlock)(BOOL);
typedef SolidKit* (^strParamBlock)(NSString *);

+ (SolidKit *)sharedKit;

- (SolidKit *(^)(BOOL))enablePerformanceMonitor;

- (SolidKit *(^)(BOOL))enableNetworkLog;

- (SolidKit *(^)(SKManagerKey))setManagerKey;

- (SolidKit *(^)(SKLogLevel))setLevel;

@end
