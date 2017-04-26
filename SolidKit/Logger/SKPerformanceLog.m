//
//  SKPerformanceLog.m
//  SolidKitExample
//
//  Created by 孙恺 on 2017/3/4.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import "SKPerformanceLog.h"
#import <sys/time.h>
#import "SKLog.h"
#import "SKASL.h"
#import "SKExceptionHandler.h"
#import "SKDatabaseManager.h"
#import "SKLogQueueGetter.h"
#import "SKCrashHandler.h"
#import "SKPerformanceFilter.h"

@interface SKPerformanceLog : NSObject

@end

@implementation SKPerformanceLog

@end

void __SKPerformanceLog(SKPerformanceMonitorItemType performance_type,
                        NSString *format, ...) {
    @autoreleasepool {
        va_list args;
        va_start(args, format);
        NSString *user_msg = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        
        if ([SKPerformanceFilter needLogPerformanceItemType:performance_type newValue:user_msg.floatValue]) {
            
            [SKCrashHandler saveData:[SKCrashHandler backtrace].description toDir:@"SolidKitPerformance"];
            
            dispatch_async(log_queue(), ^{
                
                struct timeval tv;
                gettimeofday(&tv , NULL);
                
                [SKDatabaseManager insertDictionary:@{
                                                      @"timestamp": [[NSString alloc] initWithFormat:@"%ld.%d", tv.tv_sec, tv.tv_usec],
                                                      @"type": [[NSString alloc] initWithFormat:@"%ld", performance_type],
                                                      @"value": [[NSString alloc] initWithFormat:@"%@", user_msg]
                                                      } type:SKDataTypePerformance completionHandler:^{
                                                          
                                                      }];
                
            });
            
        }
    }
}
