//
//  BViewController.m
//  block
//
//  Created by lijian on 15/11/4.
//  Copyright © 2015年 youku. All rights reserved.
//

#import "BViewController.h"
#import "CViewController.h"
#import "DViewController.h"

@interface BViewController ()

@property (nonatomic, strong) CViewController *cVC;

@end

@implementation BViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"B";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(50, 50, 100, 100);
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"push" forState:UIControlStateNormal];
    [self.view addSubview:btn];
}
#ifdef ARC_TEST
- (void)btnAction:(id)sender {
    CViewController *cVC = [[CViewController alloc] init];
    typeof(self) __weak weakSelf = self;
    cVC.block = ^(NSString *title) {
        weakSelf.title = [NSString stringWithFormat:@"%@-%@", weakSelf.title, title];
    };
    [self.navigationController pushViewController:cVC animated:YES];
}
#else
- (void)btnAction:(id)sender {
    DViewController *dVC = [[DViewController alloc] init];
    typeof(self) __weak weakSelf = self;
    dVC.block = ^(NSString *title) {
        weakSelf.title = [NSString stringWithFormat:@"%@-%@", weakSelf.title, title];
    };
    [self.navigationController pushViewController:dVC animated:YES];
}
#endif

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"B dealloc");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
