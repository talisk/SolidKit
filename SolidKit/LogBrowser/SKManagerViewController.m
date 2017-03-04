//
//  SKManagerViewController.m
//  SKLogger
//
//  Created by 孙恺 on 16/8/13.
//  Copyright © 2016年 sunkai. All rights reserved.
//

#import "SKManagerViewController.h"

@implementation SKManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"SKLManagerViewController");
    [self setupUI];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Left btn

- (void)setupUI {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Dismiss" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss:)];
    self.navigationItem.leftBarButtonItem = item;
}

- (void)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
