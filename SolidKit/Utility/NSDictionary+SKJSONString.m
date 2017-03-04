//
//  NSDictionary+SKJSONString.m
//  SolidKitExample
//
//  Created by 孙恺 on 2017/2/18.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import "NSDictionary+SKJSONString.h"
#import "SKExceptionHandler.h"

@implementation NSDictionary (SKJSONString)

- (NSString *)convertToJSONString {
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = nil;
    
    if (!jsonData) {
        [SKExceptionHandler handleException:1];
        // todo: error number and handler
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSMutableString *mutStr = [jsonString mutableCopy];
    
    // todo: delete space and \n
    NSRange range = {0,jsonString.length};
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    
    NSRange range2 = {0,mutStr.length};
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
}

@end
