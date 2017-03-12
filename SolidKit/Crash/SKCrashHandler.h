//
//  SKCrashHandler.h
//  SolidKitExample
//
//  Created by 孙恺 on 2017/3/5.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKCrashHandler : NSObject

+ (instancetype)sharedHandler;
+ (NSArray *)backtrace;
+ (NSArray *) filesByModDate: (NSString *)fullPath;
+ (void) saveDataToLocal:(NSString *)crashInfo;
+ (NSString *)getSignalInfo:(int)signal;
+ (NSString *)getAppInfo;
+ (NSArray *) getCrashFileList;
+ (NSString *) readCrashDetail:(NSString *)aPath;
+ (BOOL)removeFileInPath:(NSString *)aPath;

@end
