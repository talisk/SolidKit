//
//  SKDatabaseManager+HTTPModel.m
//  SolidKitExample
//
//  Created by 孙恺 on 2017/2/26.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import "SKDatabaseManager+HTTPModel.h"
#import "SKDatabaseManager.h"
#import "SKHTTPModel.h"
#import <objc/runtime.h>

@implementation SKDatabaseManager (HTTPModel)

static NSString *tableName;
static NSString *tableKeyString;
static NSDictionary *tableStructure;

+ (void)insertModel:(SKHTTPModel *)model to:(SKDataType)type withCompletionHandler:(SKDatabaseCompletionHandler)completionHandler {
    
    dispatch_async([SKDatabaseManager dbQueue] , ^{
        @autoreleasepool {
            unsigned int propertyCount;
            objc_property_t *propertyList = class_copyPropertyList([model class], &propertyCount);
            
            NSMutableDictionary *httpModelDictionary = [[NSMutableDictionary alloc] init];
            
            for (unsigned int i = 0; i < propertyCount; ++i) {
                objc_property_t property = propertyList[i];
                const char *propertyName = property_getName(property);
                id object = [model valueForKey:[NSString stringWithFormat:@"%s", propertyName]];
                [httpModelDictionary setObject:(object?object:@"") forKey:[NSString stringWithUTF8String:property_getName(property)]];
            }
            
            free(propertyList);
            
            [SKDatabaseManager insertDictionary:httpModelDictionary type:SKDataTypeNetwork completionHandler:^{
                if (completionHandler) {
                    completionHandler();
                }
            }];
        }
    });
}

+ (void)load {
    tableName = @"network_data";
    
    tableKeyString = @"starttime,endtime,req_url,req_cache_policy,req_timeout_interval,req_http_method,req_http_header,req_http_body,resp_mime_type,resp_expected_content_length,resp_encoding,resp_suggested_filename,resp_status_code,resp_header,receive_json";
    
    tableStructure = @{@"id": @"integer", @"starttime": @"real", @"endtime": @"real", @"req_url": @"text", @"req_cache_policy": @"text", @"req_timeout_interval": @"real", @"req_http_method": @"text", @"req_http_header": @"text", @"req_http_body": @"text", @"resp_mime_type": @"text", @"resp_expected_content_length": @"text", @"resp_encoding": @"text", @"resp_suggested_filename": @"text", @"resp_status_code": @"text", @"resp_header": @"text", @"receive_json": @"text"};
}

@end
