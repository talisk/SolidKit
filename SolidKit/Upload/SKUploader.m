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
#import "SKReachability.h"

@interface SKUploader () {
    dispatch_source_t timer;
}

@property (nonatomic, copy) NSString *address;

@end

@implementation SKUploader

static SKUploader * _uploader;

#pragma mark - Public

+ (void)setupUploadTaskWithTimeInterval:(NSTimeInterval)timeInterval uploadLimit:(SKUploadAmount)uploadAmount {
    [[SKUploader sharedUploader] setupUploadTaskWithTimeInterval:timeInterval uploadLimit:uploadAmount];
}

+ (void)setupUploadTaskWithTimeInterval:(NSTimeInterval)timeInterval uploadLimit:(SKUploadAmount)uploadAmount address:(NSString *)address {
    [[SKUploader sharedUploader] setAddress:address];
    [[SKUploader sharedUploader] setupUploadTaskWithTimeInterval:timeInterval uploadLimit:uploadAmount];
}

+ (void)uploadLimit:(SKUploadAmount)uploadAmount completionHandler:(void(^)(SKUploadResult))completionHandler {
    
    NetworkStatus networkStatus = [[SKReachability reachabilityWithHostName:[SKUploader sharedUploader].address] currentReachabilityStatus];
    
    if (networkStatus != ReachableViaWiFi) {
        completionHandler(SKUploadResultNoWifi);
        return;
    }
    
    dispatch_group_t group = dispatch_group_create();
    
    @autoreleasepool {
        
        __block NSArray *packageArray = [[NSMutableArray alloc] init];
        
        __block NSInteger logCount = 0, performanceCount = 0, networkCount = 0;
        
        dispatch_group_enter(group);
        [SKUploader selectWithLimit:uploadAmount dataType:SKDataTypeLog completionHandler:^(NSArray *result) {
            for(NSDictionary *logData in result) {
                [logData setValue:@"log" forKey:@"log_type"];
            }
            packageArray = [packageArray arrayByAddingObjectsFromArray:result];
            logCount = result.count;
            dispatch_group_leave(group);
        }];
        
        dispatch_group_enter(group);
        [SKUploader selectWithLimit:uploadAmount dataType:SKDataTypePerformance completionHandler:^(NSArray *result) {
            for(NSDictionary *logData in result) {
                [logData setValue:@"perf" forKey:@"log_type"];
            }
            packageArray = [packageArray arrayByAddingObjectsFromArray:result];
            performanceCount = result.count;
            dispatch_group_leave(group);
        }];
        
        dispatch_group_enter(group);
        [SKUploader selectWithLimit:uploadAmount dataType:SKDataTypeNetwork completionHandler:^(NSArray *result) {
            for(NSDictionary *logData in result) {
                [logData setValue:@"net" forKey:@"log_type"];
            }
            packageArray = [packageArray arrayByAddingObjectsFromArray:result];
            networkCount = result.count;
            dispatch_group_leave(group);
        }];
        
        dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSString *string = [packageArray convertToJSONString];
            
            
            
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/add", [SKUploader sharedUploader].address]];
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

- (void)setupUploadTaskWithTimeInterval:(NSTimeInterval)timeInterval uploadLimit:(SKUploadAmount)uploadAmount {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, (NSInteger)timeInterval * NSEC_PER_SEC, NSEC_PER_SEC);

    dispatch_source_set_event_handler(timer, ^{
        
        [SKUploader uploadLimit:uploadAmount completionHandler:^(SKUploadResult result) {
            switch (result) {
                case SKUploadResultNetworkError:
                    NSLog(@"upload network error");
                    break;
                case SKUploadResultNoWifi:
                    NSLog(@"upload no wifi");
                    break;
                default:
                    NSLog(@"upload success");
                    break;
            }
        }];
        
    });
    
    dispatch_resume(timer);
}

#pragma mark - Singleton

+ (instancetype)sharedUploader {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _uploader = [[self alloc] init];
        [_uploader setAddress:@"http://localhost:8181"];
    });
    return _uploader;
}

#pragma mark - Private

+ (void)deleteWithLimit:(NSUInteger)limit dataType:(SKDataType)dataType completionHandler:(void(^)())completionHandler {
    [SKDatabaseManager deleteDataCount:limit from:dataType completionHandler:^{
        completionHandler();
    }];
}

+ (void)selectWithLimit:(NSUInteger)limit dataType:(SKDataType)dataType completionHandler:(void(^)(NSArray *result))completionHandler {
    [SKDatabaseManager selectData:dataType WithLimit:limit completionHandler:^(NSArray *result) {
        completionHandler(result);
    }];
}

@end
