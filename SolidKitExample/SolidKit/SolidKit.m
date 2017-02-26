//
//  SolidKit.m
//  SolidKitExample
//
//  Created by 孙恺 on 2017/2/26.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import "SolidKit.h"
#import "SKURLProtocol.h"

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

- (SolidKit *(^)())enableNetwork {
    return ^() {
        [NSURLProtocol registerClass:[SKURLProtocol class]];
        return self;
    };
}

@end
