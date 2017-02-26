//
//  UIWindow+SKManager.h
//  SKLogger
//
//  Created by 孙恺 on 16/8/13.
//  Copyright © 2016年 sunkai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SKManagerKey) {
    SKManagerKeyNone = 0,
    SKManagerKeyShortKey = 1,
    SKManagerKeyMotion = 2,
    SKManagerKeyShortKeyAndMotion = 3
};

@interface UIWindow (SKManager) <UIActionSheetDelegate>

@property (nonatomic, assign, readonly) BOOL enableShortKey;
@property (nonatomic, assign, readonly) BOOL enableMotion;

+ (void)setManagerSwitcher:(SKManagerKey)key;

@end
