//
//  SKMehodSwizzling.m
//  SolidKitExample
//
//  Created by Sun,Kai(BBTD) on 17/3/12.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import "SKMehodSwizzling.h"
#import <objc/runtime.h>

@implementation SKMehodSwizzling

+ (void)exchangeOriginalMethod:(SEL)original withMethod:(SEL)swizzled originalClass:(Class)originalCls swizzledCls:(Class)swizzledCls {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originalSelector = original;
        SEL swizzledSelector = swizzled;
        Method originalMethod = class_getInstanceMethod(originalCls, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(swizzledCls, swizzledSelector);
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

@end
