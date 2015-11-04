//
//  ViewController.m
//  block
//
//  Created by lijian on 15/11/4.
//  Copyright © 2015年 youku. All rights reserved.
//

#import "ViewController.h"

#import "BViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"A";
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(50, 50, 100, 100);
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"push" forState:UIControlStateNormal];
    [self.view addSubview:btn];
    
}

- (void)btnAction:(id)sender {
    BViewController *bVC = [[BViewController alloc] init];
    [self.navigationController pushViewController:bVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
