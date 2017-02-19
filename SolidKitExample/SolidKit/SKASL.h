//
//  SKASL.h
//  SolidKitExample
//
//  Created by 孙恺 on 2017/2/19.
//  Copyright © 2017年 talisk. All rights reserved.
//

#ifndef SKASL_h
#define SKASL_h

#import <asl.h>

extern aslclient log_asl_client;

#define log_set_send_filter(level) asl_set_filter(log_asl_client, ASL_FILTER_MASK_UPTO(level));

#define log_(int_level, const_chars_fmt, ...) \
asl_log(log_asl_client, NULL, int_level, const_chars_fmt, ##__VA_ARGS__)

#define log(int_level, fmt, ...)    log_(int_level,         fmt, ##__VA_ARGS__)
#define log_emerg(fmt, ...)         log_(ASL_LEVEL_EMERG,   fmt, ##__VA_ARGS__)
#define log_alert(fmt, ...)         log_(ASL_LEVEL_ALERT,   fmt, ##__VA_ARGS__)
#define log_crit(fmt, ...)          log_(ASL_LEVEL_CRIT,    fmt, ##__VA_ARGS__)
#define log_err(fmt, ...)           log_(ASL_LEVEL_ERR,     fmt, ##__VA_ARGS__)
#define log_error(fmt, ...)         log_(ASL_LEVEL_ERR,     fmt, ##__VA_ARGS__)
#define log_warn(fmt, ...)          log_(ASL_LEVEL_WARNING, fmt, ##__VA_ARGS__)
#define log_notice(fmt, ...)        log_(ASL_LEVEL_NOTICE,  fmt, ##__VA_ARGS__)
#define log_info(fmt, ...)          log_(ASL_LEVEL_INFO,    fmt, ##__VA_ARGS__)
#define log_debug(fmt, ...)         log_(ASL_LEVEL_DEBUG,   fmt, ##__VA_ARGS__)

#endif
