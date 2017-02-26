//
//  SKHTTPModel.m
//  SolidKitExample
//
//  Created by 孙恺 on 2017/2/23.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import "SKHTTPModel.h"

@implementation SKHTTPModel

-(void)setRequest:(NSURLRequest *)request_new{
    _request=request_new;
    self.req_url=[_request.URL absoluteString];
    
    switch (_request.cachePolicy) {
        case 0:
            self.req_cache_policy=@"NSURLRequestUseProtocolCachePolicy";
            break;
        case 1:
            self.req_cache_policy=@"NSURLRequestReloadIgnoringLocalCacheData";
            break;
        case 2:
            self.req_cache_policy=@"NSURLRequestReturnCacheDataElseLoad";
            break;
        case 3:
            self.req_cache_policy=@"NSURLRequestReturnCacheDataDontLoad";
            break;
        case 4:
            self.req_cache_policy=@"NSURLRequestUseProtocolCachePolicy";
            break;
        case 5:
            self.req_cache_policy=@"NSURLRequestReloadRevalidatingCacheData";
            break;
        default:
            self.req_cache_policy=@"";
            break;
    }
    
    self.req_timeout_interval = [NSString stringWithFormat:@"%.1lf",_request.timeoutInterval];
    self.req_http_method=_request.HTTPMethod;
    
    for (NSString *key in [_request.allHTTPHeaderFields allKeys]) {
        self.req_http_header=[NSString stringWithFormat:@"%@%@:%@\n",self.req_http_header,key,[_request.allHTTPHeaderFields objectForKey:key]];
    }
    if (self.req_http_header.length>1) {
        if ([[self.req_http_header substringFromIndex:self.req_http_header.length-1] isEqualToString:@"\n"]) {
            self.req_http_header=[self.req_http_header substringToIndex:self.req_http_header.length-1];
        }
    }
    if (self.req_http_header.length>6) {
        if ([[self.req_http_header substringToIndex:6] isEqualToString:@"(null)"]) {
            self.req_http_header=[self.req_http_header substringFromIndex:6];
        }
    }
    
    if ([_request HTTPBody].length>512) {
        self.req_http_body = @"requestHTTPBody too long";
    }else{
        self.req_http_body = [[NSString alloc] initWithData:[_request HTTPBody] encoding:NSUTF8StringEncoding];
    }
    if (self.req_http_body.length>1) {
        if ([[self.req_http_body substringFromIndex:self.req_http_body.length-1] isEqualToString:@"\n"]) {
            self.req_http_body = [self.req_http_body substringToIndex:self.req_http_body.length-1];
        }
    }
    
}

- (void)setResponse:(NSHTTPURLResponse *)response_new {
    
    _response=response_new;
    
    self.resp_mime_type = @"";
    self.resp_expected_content_length = @"";
    self.resp_encoding = @"";
    self.resp_suggested_filename = @"";
    self.resp_status_code = @200;
    self.resp_header = @"";
    
    self.resp_mime_type=[self.response MIMEType];
    self.resp_expected_content_length=[NSString stringWithFormat:@"%lld",[self.response expectedContentLength]];
    self.resp_encoding=[self.response textEncodingName];
    self.resp_suggested_filename=[self.response suggestedFilename];
    self.resp_status_code = [NSNumber numberWithInteger:self.response.statusCode];
    
    for (NSString *key in [self.response.allHeaderFields allKeys]) {
        NSString *headerFieldValue=[self.response.allHeaderFields objectForKey:key];
        if ([key isEqualToString:@"Content-Security-Policy"]) {
            if ([[headerFieldValue substringFromIndex:12] isEqualToString:@"'none'"]) {
                headerFieldValue=[headerFieldValue substringToIndex:11];
            }
        }
        self.resp_header=[NSString stringWithFormat:@"%@%@:%@\n",self.resp_header,key,headerFieldValue];
        
    }
    
    if (self.resp_header.length>1) {
        if ([[self.resp_header substringFromIndex:self.resp_header.length-1] isEqualToString:@"\n"]) {
            self.resp_header=[self.resp_header substringToIndex:self.resp_header.length-1];
        }
    }
    
}

@end

