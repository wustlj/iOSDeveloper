//
//  ViewController.m
//  quartz2D
//
//  Created by lijian on 14-6-9.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "ViewController.h"

#import "DrawView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    int a = 1, b = 2, c = 3, d = 4, m = 2, n = 2;
    (m=a>b)&&(n=c>d);
    NSLog(@"%d", n);
    
    DrawView *dView = [[DrawView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    [self.view addSubview:dView];
    
    [dView drawImage];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

@end
