//
//  SKCrashHandler.m
//  SolidKitExample
//
//  Created by 孙恺 on 2017/3/5.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import "SKCrashHandler.h"
#import <UIKit/UIKit.h>
#include <libkern/OSAtomic.h>
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <execinfo.h>
#include <sys/time.h>

int backtrace(void **buffer, int size);
char **backtrace_symbols(void *const *buffer, int size);
void backtrace_symbols_fd(void *const *buffer, int size, int fd);
static const void * const kPerformanceQueueSpecificKey = &kPerformanceQueueSpecificKey;

NSString * const SK_EXCEPTION_SIGNAL_NAME = @"EXCEPTION_SIGNAL";
NSString * const SK_EXCEPTION_SIGNAL_KEY = @"EXCEPTION_SIGNAL_KEY";
NSString * const SK_EXCEPTION_ADDRESS_KEY = @"EXCEPTION_ADDRESS_KEY";

volatile int32_t g_gtUncaughtExceptionCount = 0;
const int32_t g_gtUncaughtExceptionMaximum = 10;

static NSUncaughtExceptionHandler* g_old_ExceptionHandler = NULL;


void exceptionHandlerForGT(NSException *exception) {
    
    if (g_old_ExceptionHandler != NULL) {
        g_old_ExceptionHandler(exception);
    }
    
    NSArray *arr = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    struct timeval tv;
    gettimeofday(&tv , NULL);
    
    NSString *crashStr = [NSString stringWithFormat:@"timestamp: %@\rNAME : %@\rREASON : %@\r%@\rCALL STACK:\r%@\r\r\r", [[NSString alloc] initWithFormat:@"%ld.%d", tv.tv_sec, tv.tv_usec], name, reason, [SKCrashHandler getAppInfo], [arr componentsJoinedByString:@"\r"]];
    
    [SKCrashHandler saveData:crashStr toDir:@"SolidKitCrash"];
}

void crashSignalHandlerForGT(int signal) {
    NSArray *callStack = [SKCrashHandler backtrace];
    
    [[[SKCrashHandler alloc] init]
     performSelectorOnMainThread:NSSelectorFromString(@"handleException:")
     withObject:[NSException
                 exceptionWithName:SK_EXCEPTION_SIGNAL_NAME
                 reason:[NSString stringWithFormat:NSLocalizedString(@"Signal %@(%d) was raised.\n"
                                                                     @"%@", nil), [SKCrashHandler getSignalInfo:signal], signal, [SKCrashHandler getAppInfo]]
                 userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:signal], callStack, nil] forKeys:[NSArray arrayWithObjects:SK_EXCEPTION_SIGNAL_KEY, SK_EXCEPTION_ADDRESS_KEY, nil]]]
     waitUntilDone:YES];
    
}

@interface SKCrashHandler () {
    dispatch_queue_t    _queue;
}

@end

@implementation SKCrashHandler

static SKCrashHandler *_handler;

+ (instancetype)sharedHandler {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _handler = [[self alloc] init];
    });
    return _handler;
}

- (id)init {
    self = [super init];
    if (self) {
        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        NSString *crashDirPath = [cachesPath stringByAppendingPathComponent:@"SolidKitCrash"];
        NSString *performanceDirPath = [cachesPath stringByAppendingPathComponent:@"SolidKitPerformance"];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:crashDirPath])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:crashDirPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:performanceDirPath])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:performanceDirPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        _queue = dispatch_queue_create([@"com.talisk.solidkit.perfqueue" UTF8String], DISPATCH_QUEUE_SERIAL);
        dispatch_queue_set_specific(_queue, kPerformanceQueueSpecificKey, (__bridge void *)self, NULL);
        dispatch_set_target_queue(_queue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
        
        // 记录之前已经注册的回调
        g_old_ExceptionHandler = NSGetUncaughtExceptionHandler();
        
        // 注册异常回调
        NSSetUncaughtExceptionHandler(&exceptionHandlerForGT);
        
        // 注册异常信号回调
        [self installUncaughtExceptionHandler];
    }
    
    return self;
}

- (void)installUncaughtExceptionHandler {
    signal(SIGABRT, crashSignalHandlerForGT);
    signal(SIGILL, crashSignalHandlerForGT);
    signal(SIGSEGV, crashSignalHandlerForGT);
    signal(SIGFPE, crashSignalHandlerForGT);
    signal(SIGBUS, crashSignalHandlerForGT);
    signal(SIGPIPE, crashSignalHandlerForGT);
}

- (void)handleException:(NSException *)exception {
    NSArray *arr = [[exception userInfo] objectForKey:SK_EXCEPTION_ADDRESS_KEY];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    struct timeval tv;
    gettimeofday(&tv , NULL);
    
    NSString *crashStr = [NSString stringWithFormat:@"timestamp: %@, NAME : %@\rREASON : %@\rCALL STACK:\r%@\r\r\r", [[NSString alloc] initWithFormat:@"%ld.%d", tv.tv_sec, tv.tv_usec], name, reason, arr];
    
    [SKCrashHandler saveData:crashStr toDir:@"SolidKitCrash"];
    
    NSSetUncaughtExceptionHandler(NULL);
    
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
    
    if ([[exception name] isEqual:SK_EXCEPTION_SIGNAL_NAME])
    {
        kill(getpid(), [[[exception userInfo] objectForKey:SK_EXCEPTION_SIGNAL_KEY] intValue]);
    }
    else
    {
        [exception raise];
    }
    
}

+ (NSString *)getSignalInfo:(int)signal {
    switch (signal) {
        case SIGABRT:
            return @"SIGABRT";
            
        case SIGILL:
            return @"SIGILL";
            
        case SIGSEGV:
            return @"SIGSEGV";
            
        case SIGFPE:
            return @"SIGFPE";
            
        case SIGBUS:
            return @"SIGBUS";
            
        case SIGPIPE:
            return @"SIGPIPE";
            
        default:
            return @"OTHER";
    }
}

+ (NSString *)getAppInfo {
    NSString *appInfo = [NSString stringWithFormat:@"App : %@ %@(%@)\nDevice : %@\nOS Version : %@ %@\n", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"], [UIDevice currentDevice].model, [UIDevice currentDevice].systemName, [UIDevice currentDevice].systemVersion];
    
    return appInfo;
}

+ (NSArray *)backtrace {
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    
    int i;
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    
    for (i = 2;//skip address
         i < frames;
         i++)
    {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    
    free(strs);
    
    return backtrace;
}

+ (void)saveData:(NSString *)crashInfo toDir:(NSString *)directory {
    
    dispatch_async([SKCrashHandler sharedHandler]->_queue, ^{
        
        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        NSString *crashDirPath = [cachesPath stringByAppendingPathComponent:directory];
        
        NSString *filePath = [NSString stringWithFormat:@"%.0f.log", [[NSDate date] timeIntervalSince1970]];
        
        FILE *file = fopen([[crashDirPath stringByAppendingPathComponent:filePath] UTF8String], "a+");
        
        if (file) {
            fprintf(file, "%s", [crashInfo UTF8String]);
            fflush(file);
            fclose(file);
        }
    });
}

+ (NSArray *)getCrashFileList {
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *crashDirPath = [cachesPath stringByAppendingPathComponent:@"SolidKitCrash"];
    
    NSArray *filePathsArray = [self filesByModDate:crashDirPath];
    return filePathsArray;
}

+ (NSArray *)filesByModDate:(NSString *)fullPath {
    NSError *error = nil;
    NSArray *files = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:fullPath
                                                                         error:&error];
    if(error == nil)
    {
        NSMutableDictionary *filesAndProperties = [NSMutableDictionary	dictionaryWithCapacity:[files count]];
        for(NSString *path in files)
        {
            NSDictionary *properties = [[NSFileManager defaultManager]
                                        attributesOfItemAtPath:[fullPath stringByAppendingPathComponent:path]
                                        error:&error];
            NSDate *modDate = [properties objectForKey:NSFileModificationDate];
            
            if(error == nil)
            {
                [filesAndProperties setValue:modDate forKey:path];
            }
        }
        return [filesAndProperties keysSortedByValueUsingSelector:@selector(compare:)];
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    return [NSArray arrayWithObjects:nil];
#pragma clang diagnostic pop
}


+ (NSString *)readCrashDetail:(NSString *)aPath {
    NSError *err = nil;
    NSString *data = [NSString stringWithContentsOfFile:aPath encoding:NSUTF8StringEncoding error:&err];
    return data;
}

+ (BOOL)removeFileInPath:(NSString *)aPath {
    return [[NSFileManager defaultManager] removeItemAtPath:aPath error:nil];
}

@end
