//
//  KViewController.m
//  CoreAnimation
//
//  Created by jian li on 12-1-12.
//  Copyright (c) 2012年 Archermind. All rights reserved.
//

#import "KViewController.h"

@implementation KViewController

- (void)dealloc
{
    [super dealloc];
    
    [imageView release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStart:(CAAnimation *)anim
{
    if ([anim isKindOfClass:[CAKeyframeAnimation class]]) {
        NSLog(@"CAKeyframeAnimation start");
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if ([anim isKindOfClass:[CAKeyframeAnimation class]]) {
        NSLog(@"CAKeyframeAnimation stop");
        NSLog(@"flag:%d",flag);
//        CATransform3D transform3D = CATransform3DMakeTranslation(-1, -1, 1);
//        CGAffineTransform transform = CATransform3DMakeTranslation(1, -1, 1);
        imageView.layer.transform = CATransform3DMakeScale(2, 2, 1);
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"title2" ofType:@"png"]];
    imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, 17, 17);
    [self.view addSubview:imageView];
    
    CGMutablePathRef path;
    path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddCurveToPoint(path, NULL, 0, 300, 160, 300, 160, 0);
    CGPathAddCurveToPoint(path, NULL, 160, 300, 320, 300, 320, 0);

    CAKeyframeAnimation *theAnimation;
    theAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    theAnimation.path = path;
    theAnimation.duration = 2.0;
    theAnimation.autoreverses = YES;
    theAnimation.delegate = self;
    CFRelease(path);
    
    [CATransaction begin];
    [imageView.layer addAnimation:theAnimation forKey:@"keyframeAnimaion"];
    [CATransaction commit];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
