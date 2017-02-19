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

typedef NS_ENUM(NSInteger, __SKLogLevel) {
    __SK_LOG_LEVEL_DEBUG = 7,
    __SK_LOG_LEVEL_INFO = 6,
    __SK_LOG_LEVEL_WARNING = 4,
    __SK_LOG_LEVEL_ERROR = 3,
};

extern void __SKLog(__SKLogLevel log_level,
                            const char *file_full_name,
                            int line,
                            const char *method_full_name,
                            int error_no,
                            NSString *format, ...) NS_FORMAT_FUNCTION(6, 7);
