//
//  SKPerformanceMonitorFactory.h
//  SolidKitExample
//
//  Created by 孙恺 on 2017/3/4.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKPerformanceMonitorFactory : NSObject

+ (instancetype)sharedFactory;

- (id)getSingletonForClass:(Class)cls;

@end
