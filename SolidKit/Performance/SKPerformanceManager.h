//
//  SKPerformanceManager.h
//  SolidKitExample
//
//  Created by 孙恺 on 2017/3/4.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKPerformanceConfig.h"

@interface SKPerformanceManager : NSObject

@property (nonatomic, strong) SKPerformanceConfig *config;

+ (instancetype)sharedManager;

- (void)handleTick;

@end
