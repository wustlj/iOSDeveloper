//
//  CViewController.m
//  block
//
//  Created by lijian on 15/11/4.
//  Copyright © 2015年 youku. All rights reserved.
//

#import "CViewController.h"

@interface CViewController ()

@property (nonatomic, copy) CompletionBlock aBlock;

@property (nonatomic, strong) NSMutableArray *array;

@end

@implementation CViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"C";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(50, 50, 100, 100);
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"pop" forState:UIControlStateNormal];
    [self.view addSubview:btn];
    
    self.array = [NSMutableArray array];
    
    // ARC Avoid Strong Reference Cycles offer 2 ways:
    // 1 __weak
    typeof(self) __weak weakSelf = self;
    // 2 __block, must set nil when completion(In ARC mode, __block x will retain x)
    CViewController __block *weakSelf2 = self;
    
    self.aBlock = ^(NSString *title) {
        [weakSelf.array addObject:title];
        
        [weakSelf2.array addObject:title];
        weakSelf2 = nil;
    };
}

- (void)btnAction:(id)sender {
    self.block(self.title);
    self.aBlock(@"test C");
    
    NSLog(@">>>%@", self.array);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"C dealloc");
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
