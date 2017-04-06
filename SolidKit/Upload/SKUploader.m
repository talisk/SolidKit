//
//  SKUploader.m
//  SolidKitExample
//
//  Created by Sun,Kai(BBTD) on 2017/4/6.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import "SKUploader.h"
#import "SKDatabaseManager.h"
#import "NSDictionary+SKJSONString.h"
#import "NSArray+SKJSONString.h"
#import "NSData+SKGzipCompressor.h"

@implementation SKUploader

+ (void)upload {
    [SKDatabaseManager selectData:SKDataTypeLog WithLimit:10 completionHandler:^(NSArray *result) {
        NSLog(@"query complete");
        
        if (!result || [result count] == 0) {
            return;
        }
        
        NSString *string = [result convertToJSONString];
        
        NSURL *url = [NSURL URLWithString:@"http://localhost:8181/add"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPBody:[[string dataUsingEncoding:NSUTF8StringEncoding] gzipData]];
        [request setHTTPMethod:@"POST"];
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//            NSLog(@"%@",data);
            [SKDatabaseManager deleteDataCount:10 from:SKDataTypeLog completionHandler:^{
                NSLog(@"delete complete");
            }];
        }];
        [dataTask resume];
    }];
}

@end
