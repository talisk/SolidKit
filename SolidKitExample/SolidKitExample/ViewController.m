//
//  ViewController.m
//  SolidKitExample
//
//  Created by 孙恺 on 2017/2/18.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import "ViewController.h"
#import "View.h"
#import "SolidKit.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    View *view = [[View alloc] init];
    [self.view addSubview:view];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)query:(id)sender {
//    [SKDatabaseManager selectDataWithLimit:3 completionHandler:^(NSArray *array) {
//        NSLog(@"query\n%@", array);
//    }];
    [SKDatabaseManager selectAllWithCompletionHandler:^(NSArray *result) {
        NSLog(@"query\n%@", result);
    }];
}

- (IBAction)pressed:(id)sender {
    NSDictionary *dic = @{@"heheh": @[@1, @2],
                          @"fdsafsfas": @"fffff",
                          @"sdfas": @1,
                          @"dictionary": @{@"dic1": @"111", @"dic2": @222}
                          };
    
    [SKDatabaseManager insertData:dic completionHandler:^{
        Debug(@"%@", dic);
//        Info(@"%@", dic);
//        Warning(1, @"%@", dic);
//        Error(1, @"%@", dic);
    }];
//    [SKDatabaseManager deleteDataCount:3 completionHandler:^{
//        NSLog(@"delete3");
//    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
