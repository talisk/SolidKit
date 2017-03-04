//
//  SKHTTPModel.h
//  SolidKitExample
//
//  Created by 孙恺 on 2017/2/23.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SKHTTPModel : NSObject

@property (nonatomic,strong) NSURLRequest *request;
@property (nonatomic,strong) NSHTTPURLResponse *response;
@property (nonatomic,strong) NSString *starttime;
@property (nonatomic,strong) NSString *endtime;

@property (nonatomic,strong) NSString *req_url;
@property (nonatomic,strong) NSString *req_cache_policy;
@property (nonatomic,strong) NSString *req_timeout_interval;
@property (nonatomic,nullable,strong) NSString *req_http_method;
@property (nonatomic,nullable,strong) NSString *req_http_header;
@property (nonatomic,nullable,strong) NSString *req_http_body;

@property (nonatomic,nullable,strong) NSString *resp_mime_type;
@property (nonatomic,strong) NSString * resp_expected_content_length;
@property (nonatomic,nullable,strong) NSString *resp_encoding;
@property (nullable, nonatomic, strong) NSString *resp_suggested_filename;
@property (nonatomic,strong) NSNumber *resp_status_code;
@property (nonatomic,nullable,strong) NSString *resp_header;

@property (nonatomic,strong) NSString *receive_json;

@property (nonatomic,strong) NSString *mapPath;
@property (nonatomic,strong) NSString *mapJSONData;

@end

NS_ASSUME_NONNULL_END
