//
//  SolidKit.h
//  SolidKitExample
//
//  Created by 孙恺 on 2017/2/26.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import "SKLog.h"

@interface SolidKit : NSObject

typedef SolidKit* (^nonParamBlock)();
typedef SolidKit* (^strParamBlock)(NSString *);

+ (SolidKit *)enable;

- (SolidKit *(^)())enableNetwork;

@end
