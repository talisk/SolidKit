//
//  SKPerformanceWatchDog.h
//  SolidKit
//
//  Created by Sun,Kai(BBTD) on 17/3/19.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKPerformanceWatchDog : NSObject

typedef void(^BarkingBehavior)();

+ (void)sitBack;

+ (void)watchWithThreshold:(NSTimeInterval)threshold barkingBehavior:(BarkingBehavior)barkingBehavior;

@end
