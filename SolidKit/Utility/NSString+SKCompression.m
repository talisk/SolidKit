//
//  NSString+SKCompression.m
//  SolidKitExample
//
//  Created by 孙恺 on 2017/2/23.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import "NSString+SKCompression.h"

@implementation NSString (SKCompression)

+ (NSString *)stringWithoutSpaceAndNewline:(NSString *)srcString {
    NSMutableString *mutStr = [srcString mutableCopy];
    
    NSRange range = {0, mutStr.length};
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    
    NSRange range2 = {0,mutStr.length};
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return [mutStr copy];
}

@end
