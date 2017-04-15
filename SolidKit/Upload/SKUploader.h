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
};

@interface SKUploader : NSObject

+ (void)uploadWithCompletionHandler:(void(^)(SKUploadResult result))completionHandler;

@end
