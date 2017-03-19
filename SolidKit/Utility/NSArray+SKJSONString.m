//
//  NSArray+SKJSONString.m
//  SolidKitExample
//
//  Created by Sun,Kai(BBTD) on 17/3/12.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import "NSArray+SKJSONString.h"
#import "SKExceptionHandler.h"

@implementation NSArray (SKJSONString)

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
    
    NSRange range = {0,mutStr.length};
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range];
    
    return mutStr;
}

@end
