//
//  SKUploader.h
//  SolidKitExample
//
//  Created by Sun,Kai(BBTD) on 2017/4/6.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SKUploadResult) {
    SKUploadResultSuccess = 0,
    SKUploadResultNetworkError = 1,
    SKUploadResultNoWifi = 2,
};

typedef NS_ENUM(NSUInteger, SKUploadAmount) {
    SKUploadAmountLite = 10,
    SKUploadAmountMedium = 30,
    SKUploadAmountHuge = 50,
    SKUploadAmountAll = UINT_MAX
};

@interface SKUploader : NSObject

+ (void)setupUploadTaskWithTimeInterval:(NSTimeInterval)timeInterval uploadLimit:(SKUploadAmount)uploadAmount;
+ (void)setupUploadTaskWithTimeInterval:(NSTimeInterval)timeInterval uploadLimit:(SKUploadAmount)uploadAmount address:(NSString *)address;
+ (void)uploadLimit:(SKUploadAmount)uploadAmount completionHandler:(void(^)(SKUploadResult))completionHandler;

@end
