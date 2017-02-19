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
#import "SKLog.h"
#import "SKASL.h"
#import "SKFailureHandler.h"

@interface SKLog : NSObject

@end

@implementation SKLog

+ (void)load {
    uint32_t client_opts, send_level;
    const char *identity, *facility;
    
    // ASL client options
    client_opts = 0;
    send_level = ASL_LEVEL_DEBUG;
    identity = NULL;
    facility = "com.talisk.solidkit.asl";
    client_opts |= ASL_OPT_STDERR;
    
    log_asl_client = asl_open(identity, facility, client_opts);
    
    if (log_asl_client == NULL) {
        perror("asl_open");
        [SKFailureHandler handleException:2];
        // todo: handle exception
    }
    log_set_send_filter(send_level);
}

+ (void)setLogLevel:(__SKLogLevel)logLevel {
    log_set_send_filter(logLevel);
}

@end

void __SKLogHandleWF_Debug(__SKLogLevel log_level,
                            const char *file_full_name,
                            int line,
                            const char *method_full_name,
                            int error_no,
                            NSString *user_msg) {
    // TODO: 可配置是否抛异常
    BOOL raise_exception_on_fatal = YES;
    BOOL raise_exception_on_warning = NO;
    
    if ((log_level == __SK_LOG_LEVEL_ERROR && raise_exception_on_fatal) ||
        (log_level == __SK_LOG_LEVEL_WARNING && raise_exception_on_warning)) {
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

void __SKLogHandleWF_Release(__SKLogLevel log_level,
                              const char *file_full_name,
                              int line,
                              const char *method_full_name,
                              int error_no,
                              NSString *user_msg) {
    // TODO: WARNING自动回传消息和堆栈、FATAL抛异常并自动回传消息和堆栈
}

void __SKLog(__SKLogLevel log_level,
                    const char *file_full_name,
                    int line,
                    const char *method_full_name,
                    int error_no,
                    NSString *format, ...) {
    
    const char *file_name;
    if((file_name = strrchr(file_full_name, '/'))) {
        ++file_name;
    } else {
        file_name = file_full_name;
    }
    
    va_list args;
    va_start(args, format);
    NSString *user_msg = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    if (log_level > __SK_LOG_LEVEL_WARNING) {
        log(log_level, "%s | %d | %s\n%s",file_name, line, method_full_name, [user_msg UTF8String]);
    } else {
        log(log_level, "%s | %d | %s | !err%d!\n%s",file_name, line, method_full_name, error_no, [user_msg UTF8String]);
    }
    
    if (log_level <= __SK_LOG_LEVEL_WARNING) {
#ifdef DEBUG
        __SKLogHandleWF_Debug(log_level, file_full_name, line, method_full_name, error_no, user_msg);
#else
        __SKLogHandleWF_Release(log_level, file_full_name, line, method_full_name, error_no, user_msg);
#endif
    }
}

