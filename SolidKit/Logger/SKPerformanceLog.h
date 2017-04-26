//
//  SKPerformanceLog.h
//  SolidKitExample
//
//  Created by 孙恺 on 2017/3/4.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKPerformanceConfig.h"

#define Performance(performance_type, ...) \
__SKPerformanceLog(performance_type, __VA_ARGS__)

extern void __SKPerformanceLog(SKPerformanceMonitorItemType performance_type,
                               NSString *format, ...) NS_FORMAT_FUNCTION(2, 3);
