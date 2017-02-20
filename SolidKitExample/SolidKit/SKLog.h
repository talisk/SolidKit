//
//  SKLog.h
//  SolidKitExample
//
//  Created by 孙恺 on 2017/2/19.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG

#define Debug(...) \
__SKLog(__SK_LOG_LEVEL_DEBUG, __FILE__, __LINE__, __func__, 0, __VA_ARGS__)
#define Info(...) \
__SKLog(__SK_LOG_LEVEL_INFO, __FILE__, __LINE__, __func__, 0, __VA_ARGS__)

#else

#define Debug(...)  ((void)0)
#define Info(...)   ((void)0)

#endif

#define Warning(error_no, ...) \
__SKLog(__SK_LOG_LEVEL_WARNING, __FILE__, __LINE__, __func__, error_no, __VA_ARGS__)
#define Error(error_no, ...) \
__SKLog(__SK_LOG_LEVEL_ERROR, __FILE__, __LINE__, __func__, error_no, __VA_ARGS__)

typedef NS_ENUM(NSInteger, SKLogLevel) {
    SKLogLevelDebug = 7,
    SKLogLevelInfo = 6,
    SKLogLevelWarning = 4,
    SKLogLevelError = 3,
};

extern void __SKLog(SKLogLevel log_level,
                            const char *file_full_name,
                            int line,
                            const char *method_full_name,
                            int error_no,
                            NSString *format, ...) NS_FORMAT_FUNCTION(6, 7);
