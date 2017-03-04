//
//  NSString+SKExtension.m
//  SolidKitExample
//
//  Created by 孙恺 on 2017/2/18.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import "NSString+SKExtension.h"

@implementation NSString (SKExtension)

+ (NSString *)cachesPathWithFileName:(NSString *)fileName {
    
    NSString *newStr = [fileName lastPathComponent];
    
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString *cachesFile = [cachesPath stringByAppendingPathComponent:newStr];
    
    return cachesFile;
}

+ (NSString *)bundlePathWithFileName:(NSString *)fileName type:(NSString *)type {
    return [[NSBundle mainBundle] pathForResource:fileName ofType:type];
}

@end
