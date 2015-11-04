//
//  DViewController.m
//  block
//
//  Created by lijian on 15/11/4.
//  Copyright © 2015年 youku. All rights reserved.
//

#import "DViewController.h"
#import "TMutableArray.h"

@interface DViewController ()

@property (nonatomic, copy) CompletionBlock aBlock;

@property (nonatomic, strong) TObject *tObj;

@end

@implementation DViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"D";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(50, 50, 100, 100);
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"pop" forState:UIControlStateNormal];
    [self.view addSubview:btn];
    
    self.tObj = [[[TObject alloc] init] autorelease];
    
    DViewController __block *weakSelf2 = self;
    
    TObject *weakTObj = _tObj;
    
    self.aBlock = ^(NSString *title) {
        [weakSelf2 addObject:title];

        [weakTObj.array addObject:title];
    };
}

- (void)addObject:(id)obj {
    [self.tObj.array addObject:obj];
}

- (void)btnAction:(id)sender {
    self.block(self.title);
    self.aBlock(@"test C");
    
    NSLog(@">>>%@", self.tObj.array);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"D dealloc");
    
    Block_release(_aBlock);
    [_tObj release];
    
    [super dealloc];
}

@end
