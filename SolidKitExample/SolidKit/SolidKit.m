//
//  SolidKit.m
//  SolidKitExample
//
//  Created by 孙恺 on 2017/2/26.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import "SolidKit.h"
#import "SKURLProtocol.h"
#import <UIKit/UIKit.h>
#import "UIWindow+SKManager.h"

static SolidKit *sharedInstance;

@implementation SolidKit

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SolidKit alloc] init];
    });
}

+ (SolidKit *)enable {
    return sharedInstance;
}

- (SolidKit *(^)())networkLog {
    return ^() {
        [NSURLProtocol registerClass:[SKURLProtocol class]];
        return self;
    };
}

- (SolidKit *(^)())manager {
    return ^() {
        [[[UIApplication sharedApplication].delegate window] setEnableManager:YES];
        return self;
    };
}

@end
