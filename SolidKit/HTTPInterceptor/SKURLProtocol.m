//
//  SKURLProtocol.m
//  SolidKitExample
//
//  Created by 孙恺 on 2017/2/23.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import "SKURLProtocol.h"
#import "SKHTTPModel.h"
#import <sys/time.h>
#import "SKDatabaseManager.h"
#import "SKDatabaseManager+HTTPModel.h"

static NSString * const SKURLProtocolHandledKey = @"SKURLProtocolHandledKey";

@interface SKURLProtocol()<NSURLSessionDelegate, NSURLSessionDataDelegate>
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic,strong) SKHTTPModel *httpModel;

@property (atomic,strong,readwrite) NSURLSessionDataTask *task;
@property (nonatomic,strong) NSURLSession *session;
@end

@implementation SKURLProtocol

#pragma mark - Init

- (instancetype)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id<NSURLProtocolClient>)client {
    return [super initWithRequest:request cachedResponse:cachedResponse client:client];
}

#pragma mark - Filter

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if (![request.URL.scheme isEqualToString:@"http"] &&
        ![request.URL.scheme isEqualToString:@"https"]) {
        return NO;
    }
    
    if ([NSURLProtocol propertyForKey:SKURLProtocolHandledKey inRequest:request] ) {
        return NO;
    }
    
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
    return [mutableReqeust copy];
}

- (void)startLoading {
    self.startDate = [NSDate date];
    struct timeval tv;
    gettimeofday(&tv , NULL);
    self.data = [NSMutableData data];
    
    NSURLSessionConfiguration *configure = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    self.session = [NSURLSession sessionWithConfiguration:configure delegate:self delegateQueue:queue];
    self.task = [self.session dataTaskWithRequest:self.request];
    [self.task resume];
    
    self.httpModel=[[SKHTTPModel alloc] init];
    self.httpModel.request = self.request;
    self.httpModel.starttime = [[NSString alloc] initWithFormat:@"%ld.%d", tv.tv_sec, tv.tv_usec];
}

- (void)stopLoading {
    [self.session invalidateAndCancel];
    self.session = nil;
    
    struct timeval tv;
    gettimeofday(&tv , NULL);
    
    self.httpModel.response=(NSHTTPURLResponse *)self.response;
    self.httpModel.endtime = [[NSString alloc] initWithFormat:@"%ld.%d", tv.tv_sec, tv.tv_usec];
    
    NSString *mimeType = self.response.MIMEType;
    
    if ([mimeType isEqualToString:@"application/json"]) {
        self.httpModel.receive_json = [self responseJSONFromData:self.data];
    } else if ([mimeType isEqualToString:@"text/javascript"]) {
        
        NSString *jsonString = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];

        if ([jsonString hasSuffix:@")"]) {
            jsonString = [NSString stringWithFormat:@"%@;", jsonString];
        }
        if ([jsonString hasSuffix:@");"]) {
            NSRange range = [jsonString rangeOfString:@"("];
            if (range.location != NSNotFound) {
                range.location++;
                range.length = [jsonString length] - range.location - 2;
                jsonString = [jsonString substringWithRange:range];
                NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                self.httpModel.receive_json = [self responseJSONFromData:jsonData];
            }
        }
        
    }else if ([mimeType isEqualToString:@"application/xml"] ||[mimeType isEqualToString:@"text/xml"]){
        NSString *xmlString = [[NSString alloc]initWithData:self.data encoding:NSUTF8StringEncoding];
        if (xmlString && xmlString.length>0) {
            self.httpModel.receive_json = xmlString;
        }
    }
    double flowCount=[[[NSUserDefaults standardUserDefaults] objectForKey:@"flowCount"] doubleValue];
    if (!flowCount) {
        flowCount=0.0;
    }
    flowCount=flowCount+self.response.expectedContentLength/(1024.0*1024.0);
    [[NSUserDefaults standardUserDefaults] setDouble:flowCount forKey:@"flowCount"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [SKDatabaseManager insertModel:self.httpModel to:SKDataTypeNetwork withCompletionHandler:^{
        NSLog(@"network");
    }];
}

#pragma mark - NSURLConnectionDataDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error != nil) {
        [self.client URLProtocol:self didFailWithError:error];
    } else {
        [self.client URLProtocolDidFinishLoading:self];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    self.response = response;
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [[self client] URLProtocol:self didLoadData:data];
    [self.data appendData:data];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse * _Nullable))completionHandler {
    completionHandler(proposedResponse);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)newRequest completionHandler:(void (^)(NSURLRequest *))completionHandler
{
    NSMutableURLRequest*    redirectRequest;
    redirectRequest = [newRequest mutableCopy];
    
    if (response != nil){
        self.response = response;
        [[self class] removePropertyForKey:SKURLProtocolHandledKey inRequest:redirectRequest];
        [[self client] URLProtocol:self wasRedirectedToRequest:redirectRequest redirectResponse:response];
    }
    
    
    [self.task cancel];
    [[self client] URLProtocol:self didFailWithError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil]];
}

#pragma mark - Utils

-(id)responseJSONFromData:(NSData *)data {
    if(data == nil) return nil;
    NSError *error = nil;
    id returnValue = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if(error) {
        NSLog(@"JSON Parsing Error: %@", error);
        return nil;
    }
    if (!returnValue || returnValue == [NSNull null]) {
        return nil;
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:returnValue options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

- (NSString *)stringWithDate:(NSDate *)date {
    NSString *destDateString = [[SKURLProtocol defaultDateFormatter] stringFromDate:date];
    return destDateString;
}

+ (NSDateFormatter *)defaultDateFormatter {
    static NSDateFormatter *staticDateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticDateFormatter=[[NSDateFormatter alloc] init];
        [staticDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    });
    return staticDateFormatter;
}

@end
