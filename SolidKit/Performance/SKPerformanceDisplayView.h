//
//  SKPerformanceDisplayView.h
//  SolidKitExample
//
//  Created by 孙恺 on 2017/3/4.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKPerformanceDisplayView : UIView

@property (nonatomic, assign) float cpuUsage;
@property (nonatomic, assign) float memoryUsage;
@property (nonatomic, assign) float smooth;
@property (nonatomic, assign) float battery;

@end
