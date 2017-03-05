//
//  SKPerformanceConfig.h
//  SolidKitExample
//
//  Created by 孙恺 on 2017/3/4.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SKPerformanceMonitorItemType) {
    SKPerformanceItemCPU = 0,
    SKPerformanceItemMemory = 1,
    SKPerformanceItemSmooth = 2
};

@interface SKPerformanceConfig : NSObject

@property (nonatomic, assign) NSTimeInterval refreshInterval;

- (void)addMonitorItem:(SKPerformanceMonitorItemType)item;
- (void)removeMonitorItem:(SKPerformanceMonitorItemType)item;
- (BOOL)getMonitorState:(SKPerformanceMonitorItemType)item;
- (NSString *)getMonitorKeyWithItem:(SKPerformanceMonitorItemType)item;
- (NSInteger)getPerformanceTypeCount;

@end
