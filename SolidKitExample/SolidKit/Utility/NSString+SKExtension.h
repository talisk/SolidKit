//
//  NSString+SKExtension.h
//  SolidKitExample
//
//  Created by 孙恺 on 2017/2/18.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SKExtension)

+ (NSString *)cachesPathWithFileName:(NSString *)fileName;
+ (NSString *)bundlePathWithFileName:(NSString *)fileName type:(NSString *)type;

@end
