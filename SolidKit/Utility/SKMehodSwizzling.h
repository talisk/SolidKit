//
//  SKMehodSwizzling.h
//  SolidKitExample
//
//  Created by Sun,Kai(BBTD) on 17/3/12.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKMehodSwizzling : NSObject

+ (void)exchangeOriginalMethod:(SEL)original withMethod:(SEL)swizzled originalClass:(Class)originalCls swizzledCls:(Class)swizzledCls;

@end
