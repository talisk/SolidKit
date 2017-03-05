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
@property (weak, nonatomic) IBOutlet UITextField *requestPathTextField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    View *view = [[View alloc] init];
    [self.view addSubview:view];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSLog(@"shake");
}
- (IBAction)performanceSwitch:(id)sender {
    UISwitch *switcher = (UISwitch *)sender;
    [SolidKit sharedKit].enablePerformanceMonitor(switcher.isOn);
}

- (IBAction)requestIntereptorSwitch:(id)sender {
    UISwitch *switcher = (UISwitch *)sender;
    [SolidKit sharedKit].enableNetworkLog(switcher.isOn);
}

- (IBAction)loglevelChanged:(id)sender {
    NSArray<NSNumber *> *loglevel = @[@3, @4, @6, @7];
    
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    [SolidKit sharedKit].setLevel(loglevel[segmentedControl.selectedSegmentIndex].integerValue);
}

- (IBAction)managerKeyChanged:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    [SolidKit sharedKit].setManagerKey(segmentedControl.selectedSegmentIndex);
}

- (IBAction)requestPressed:(id)sender {
    NSURL *url = [NSURL URLWithString:self.requestPathTextField.text];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"%@",data);
    }];
    [dataTask resume];
}

- (IBAction)errorPressed:(id)sender {
    Error(1, @"error");
}

- (IBAction)warningPressed:(id)sender {
    Warning(1, @"warning");
}
- (IBAction)infoPressed:(id)sender {
    Info(@"info");
}
- (IBAction)debugPressed:(id)sender {
    Debug(@"debug");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
