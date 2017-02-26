//
//  UIWindow+SKManager.m
//  SKLogger
//
//  Created by 孙恺 on 16/8/13.
//  Copyright © 2016年 sunkai. All rights reserved.
//

#import "UIWindow+SKManager.h"
#import "SKManagerViewController.h"
#import "SKLogViewerViewController.h"
#import <objc/runtime.h>

@implementation UIWindow (SKManager)

@dynamic enableManager;

#pragma mark - Keyboard Command

- (BOOL)canBecomeFirstResponder {
    return self.enableManager;
}

- (NSArray<UIKeyCommand *> *)keyCommands {
    
    UIKeyCommand *keyCommand = [UIKeyCommand keyCommandWithInput:@"e"
                                                   modifierFlags:UIKeyModifierCommand
                                                          action:@selector(presentActionSheet)];
    
    return self.enableManager?@[keyCommand]:@[];
}

#pragma mark - Shake Motion
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (event.type != UIEventTypeMotion || event.subtype != UIEventSubtypeMotionShake) {
        return;
    }
    
    if (!self.enableManager) {
        return;
    }
    
    [self presentActionSheet];
}

#pragma mark - Action Sheet

- (void)presentActionSheet {
    if([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"Present Manager ViewController?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"OK", nil];
        [actionsheet showInView:[[[[UIApplication sharedApplication] delegate] window] rootViewController].view];
        #pragma clang diagnostic pop
    } else {
        UIAlertController *actionSheet = [UIAlertController
                                          alertControllerWithTitle:@"SKLogger"
                                          message:@"Present Manager ViewController?"
                                          preferredStyle:UIAlertControllerStyleActionSheet];
        
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
            [actionSheet loadViewIfNeeded];
        }
        
        [actionSheet addAction:[UIAlertAction
                                actionWithTitle:@"OK"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * _Nonnull action) {
                                    [self presentManagerVC];
                                }]];
        
        [actionSheet addAction:[UIAlertAction
                                actionWithTitle:@"Cancel"
                                style:UIAlertActionStyleCancel
                                handler:nil]];
        
        UIViewController *rootViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        
        if (!rootViewController.presentedViewController) {
            [rootViewController presentViewController:actionSheet animated:YES completion:nil];
        }
    }
}

#pragma mark UIAlertViewDelegate
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self presentManagerVC];
    }
}
#pragma clang diagnostic pop

#pragma mark - Present ManagerVC

- (void)presentManagerVC {
    SKManagerViewController *managerVC = [[SKManagerViewController alloc] init];
    [managerVC setTitle:@"Manager"];
    SKLogViewerViewController *logViewerVC = [[SKLogViewerViewController alloc] init];
    [logViewerVC setTitle:@"LogViewer"];
    
    UINavigationController *managerNaviVC = [[UINavigationController alloc] initWithRootViewController:managerVC];
    UINavigationController *logViewerNaviVC = [[UINavigationController alloc] initWithRootViewController:logViewerVC];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    [tabBarController setViewControllers:@[managerNaviVC, logViewerNaviVC]];
    
    [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:tabBarController animated:YES completion:nil];
}

#pragma mark - Association Object

- (BOOL)enableManager {
    NSNumber *num = objc_getAssociatedObject(self, @"enableManager");
    return num.boolValue;
}

- (void)setEnableManager:(BOOL)enableManager {
    NSNumber *num = [NSNumber numberWithBool:enableManager];
    objc_setAssociatedObject(self, @"enableManager", num, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
