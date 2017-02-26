//
//  SKLog.m
//  SolidKitExample
//
//  Created by 孙恺 on 2017/2/19.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import <string.h>
#import <libgen.h>
#import <os/log.h>
#import <sys/time.h>
#import "SKLog.h"
#import "SKASL.h"
#import "SKFailureHandler.h"
#import "SKDatabaseManager.h"
#import "NSString+SKCompression.h"

static dispatch_queue_t log_queue() {
    static dispatch_queue_t solidkit_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        solidkit_queue = dispatch_queue_create("com.talisk.solidkit.logqueue", DISPATCH_QUEUE_SERIAL);
    });
    
    return solidkit_queue;
}

@interface SKLog : NSObject

@end

@implementation SKLog

+ (void)load {

    dispatch_set_target_queue(log_queue(), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0));
    
    uint32_t client_opts, send_level;
    const char *identity, *facility;
    
    // ASL client options
    client_opts = 0;
    send_level = ASL_LEVEL_DEBUG;
    identity = NULL;
    facility = "com.talisk.solidkit.asl";
    client_opts |= ASL_OPT_STDERR;
    
    log_asl_client = asl_open(identity, facility, client_opts);
    
    asl_add_output_file(log_asl_client, STDERR_FILENO,
                        "$Time - $((Level)(str))\n$Message",
                        ASL_TIME_FMT_LCL ".6",
                        ASL_FILTER_MASK_UPTO(send_level), ASL_ENCODE_SAFE);
    
    if (log_asl_client == NULL) {
        perror("asl_open");
        [SKFailureHandler handleException:2];
        // todo: handle exception
    }
}

@end

void __SKLogHandleWF_Debug(SKLogLevel log_level,
                            const char *file_full_name,
                            int line,
                            const char *method_full_name,
                            int error_no,
                            NSString *user_msg) {
    // TODO: 可配置是否抛异常
    BOOL raise_exception_on_fatal = YES;
    BOOL raise_exception_on_warning = NO;
    
    if ((log_level == SKLogLevelError && raise_exception_on_fatal) ||
        (log_level == SKLogLevelWarning && raise_exception_on_warning)) {
        NSDictionary *user_info = @{
                                    @"file": [NSString stringWithUTF8String:file_full_name],
                                    @"line": [NSNumber numberWithInt:line],
                                    @"method":[NSString stringWithUTF8String:method_full_name],
                                    @"error_no": [NSNumber numberWithInt:error_no],
                                    @"user_msg": user_msg
                                    };
        NSException* exception = [NSException
                                  exceptionWithName:@"SK_WF"
                                  reason:user_msg
                                  userInfo:user_info];
        [exception raise];
    }
}

void __SKLogHandleWF_Release(SKLogLevel log_level,
                              const char *file_full_name,
                              int line,
                              const char *method_full_name,
                              int error_no,
                              NSString *user_msg) {
    // TODO: WARNING自动回传消息和堆栈、FATAL抛异常并自动回传消息和堆栈
}

void __SKLog(SKLogLevel log_level,
                    const char *file_full_name,
                    int line,
                    const char *method_full_name,
                    int error_no,
                    NSString *format, ...) {
    @autoreleasepool {
    va_list args;
    va_start(args, format);
    NSString *user_msg = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    dispatch_async(log_queue(), ^{
        const char *file_name;
        if((file_name = strrchr(file_full_name, '/'))) {
            ++file_name;
        } else {
            file_name = file_full_name;
        }
        
        if (log_level > SKLogLevelWarning) {
            struct timeval tv;
            gettimeofday(&tv , NULL);
            
            log(log_level, "%ld%d | %s | %d | %s\n%s", tv.tv_sec, tv.tv_usec/1000, file_name, line, method_full_name, [user_msg UTF8String]);
            
            [SKDatabaseManager insertDictionary:@{
                                                  @"timestamp": [[NSString alloc] initWithFormat:@"%ld.%d", tv.tv_sec, tv.tv_usec],
                                                  @"level": [[NSString alloc] initWithFormat:@"%ld", log_level],
                                                  @"file_name": [[NSString alloc] initWithFormat:@"%s", file_name],
                                                  @"line": [[NSString alloc] initWithFormat:@"%d", line],
                                                  @"method": [[NSString alloc] initWithFormat:@"%s", method_full_name],
                                                  @"error_no": @"0",
                                                  @"msg": [[NSString alloc] initWithFormat:@"%@", [NSString stringWithoutSpaceAndNewline:user_msg]],
                                                  } type:SKDataTypeLog completionHandler:^{
                                                      
            }];
        } else {
            struct timeval tv;
            gettimeofday(&tv , NULL);
            
            log(log_level, "%ld%d | %s | %d | %s | !err%d!\n%s", tv.tv_sec, tv.tv_usec/1000, file_name, line, method_full_name, error_no, [user_msg UTF8String]);
            
            [SKDatabaseManager insertDictionary:@{
                                                  @"timestamp": [[NSString alloc] initWithFormat:@"%ld.%d", tv.tv_sec, tv.tv_usec],
                                                  @"level": [[NSString alloc] initWithFormat:@"%ld", log_level],
                                                  @"file_name": [[NSString alloc] initWithFormat:@"%s", file_name],
                                                  @"line": [[NSString alloc] initWithFormat:@"%d", line],
                                                  @"method": [[NSString alloc] initWithFormat:@"%s", method_full_name],
                                                  @"error_no": [[NSString alloc] initWithFormat:@"%d", error_no],
                                                  @"msg": [[NSString alloc] initWithFormat:@"%@", [NSString stringWithoutSpaceAndNewline:user_msg]],
                                                  } type:SKDataTypeLog completionHandler:^{
                
            }];
        }
        
        if (log_level <= SKLogLevelWarning) {
//            dispatch_async(dispatch_get_main_queue(), ^{
#ifdef DEBUG
                __SKLogHandleWF_Debug(log_level, file_full_name, line, method_full_name, error_no, user_msg);
#else
                __SKLogHandleWF_Release(log_level, file_full_name, line, method_full_name, error_no, user_msg);
#endif
//            });
        }
    });
    }
    
}

