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

@interface SKUploader ()

@end

@implementation SKUploader

static SKUploader * _uploader;

#pragma mark - Public

+ (void)uploadWithCompletionHandler:(void(^)(SKUploadResult))completionHandler {
    
    dispatch_group_t group = dispatch_group_create();
    
    @autoreleasepool {
        
        __block NSArray *packageArray = [[NSMutableArray alloc] init];
        
        __block NSInteger logCount = 0, performanceCount = 0, networkCount = 0;
        
        dispatch_group_enter(group);
        [SKUploader selectWithLimit:10 dataType:SKDataTypeLog completionHandler:^(NSArray *result) {
            packageArray = [packageArray arrayByAddingObjectsFromArray:result];
            logCount = result.count;
            dispatch_group_leave(group);
        }];
        
        dispatch_group_enter(group);
        [SKUploader selectWithLimit:10 dataType:SKDataTypePerformance completionHandler:^(NSArray *result) {
            packageArray = [packageArray arrayByAddingObjectsFromArray:result];
            performanceCount = result.count;
            dispatch_group_leave(group);
        }];
        
        dispatch_group_enter(group);
        [SKUploader selectWithLimit:10 dataType:SKDataTypeNetwork completionHandler:^(NSArray *result) {
            packageArray = [packageArray arrayByAddingObjectsFromArray:result];
            networkCount = result.count;
            dispatch_group_leave(group);
        }];
        
        dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSString *string = [packageArray convertToJSONString];
            
            NSURL *url = [NSURL URLWithString:@"http://localhost:8181/add"];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            [request setHTTPBody:[[string dataUsingEncoding:NSUTF8StringEncoding] gzipData]];
            [request setHTTPMethod:@"POST"];
            
            NSURLSession *session = [NSURLSession sharedSession];
            NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                
                if (error != nil && error.code != 0) {
                    completionHandler(SKUploadResultNetworkError);
                    return;
                }
                
                dispatch_group_t dbGroup = dispatch_group_create();
                dispatch_queue_t dbQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                
                dispatch_group_enter(dbGroup);
                [SKUploader deleteWithLimit:logCount dataType:SKDataTypeLog completionHandler:^{
                    dispatch_group_leave(dbGroup);
                }];
                
                dispatch_group_enter(dbGroup);
                [SKUploader deleteWithLimit:performanceCount dataType:SKDataTypePerformance completionHandler:^{
                    dispatch_group_leave(dbGroup);
                }];
                
                dispatch_group_enter(dbGroup);
                [SKUploader deleteWithLimit:networkCount dataType:SKDataTypeNetwork completionHandler:^{
                    dispatch_group_leave(dbGroup);
                }];
                
                dispatch_group_notify(dbGroup, dbQueue, ^{
                    completionHandler(SKUploadResultSuccess);
                });
                
            }];
            [dataTask resume];
            
        });
    }
    
}

#pragma mark - Private

+ (void)deleteWithLimit:(NSUInteger)limit dataType:(SKDataType)dataType completionHandler:(void(^)())completionHandler {
    [SKDatabaseManager deleteDataCount:limit from:dataType completionHandler:^{
        NSLog(@"delete complete");
        completionHandler();
    }];
}

+ (void)selectWithLimit:(NSUInteger)limit dataType:(SKDataType)dataType completionHandler:(void(^)(NSArray *result))completionHandler {
    [SKDatabaseManager selectData:dataType WithLimit:limit completionHandler:^(NSArray *result) {
        NSLog(@"query complete");
        completionHandler(result);
    }];
}

@end
