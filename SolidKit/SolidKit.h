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
typedef SolidKit* (^strParamBlock)(NSString *);

+ (SolidKit *)enable;

- (SolidKit *(^)())networkLog;

- (SolidKit *(^)(SKManagerKey))manager;

- (SolidKit *(^)(SKLogLevel))setLevel;

@end
