//
//  ViewController.m
//  GCD_Queue_Count
//
//  Created by lijian on 14-5-4.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "ViewController.h"

void runOnMainQueueWithoutDeadlocking(void (^block)(void))
{
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

void runSynchronouslyOnQueue(dispatch_queue_t queue, void (^block)(void))
{
    if (dispatch_get_current_queue() == queue) {
        block();
    } else {
        dispatch_sync(queue, block);
    }
}

void runAsynchronouslyOnQueue(dispatch_queue_t queue, void (^block)(void))
{
    if (dispatch_get_current_queue() == queue) {
        block();
    } else {
        dispatch_async(queue, block);
    }
}

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

/*
    //     From here,wo can see the system create 3 thread
    //     Queue:com.apple.root.high-priority
    //     Queue:com.apple.root.default-priority
    //     Queue:com.apple.root.low-priority
    //     So, the system run 3 thread all the time.
    //     but the system create a new thread if using dispatch_create,it will end when block completion.
 
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        for (int i = 0; i < 100; i++) {
            NSLog(@"async HIGH queue %d", i);
        }
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i < 100; i++) {
            NSLog(@"async DEFAULT queue %d", i);
        }
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        for (int i = 0; i < 100; i++) {
            NSLog(@"async LOW queue %d", i);
        }
    });
    
    dispatch_async(dispatch_queue_create("com.youku.ljtest", 0), ^{
        for (int i = 0; i < 100; i++) {
            NSLog(@"async LOW queue %d", i);
        }
    });
*/
    
/*
     //     Form here,the two block run concurrent ont DISPATCH_QUEUE_PRIORITY_HIGH queue, but blcok(2) run on its child thread.
     
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        for (int i = 0; i < 100; i++) {
            NSLog(@"async HIGH queue %d(1)", i);
        }
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        for (int i = 0; i < 100; i++) {
            NSLog(@"async HIGH queue %d(2)", i);
        }
    });
*/
    
/*
    //      Notif:sync can't at main thread here,it will results in deadlock
    dispatch_sync(dispatch_get_main_queue(), ^{
        for (int i = 0; i < 100; i++) {
            NSLog(@"sync main queue %d", i);
        }
    });
 
    //  This method can avoid deadlock
    runSynchronouslyOnQueue(dispatch_get_main_queue(), ^{
        for (int i = 0; i < 100; i++) {
            NSLog(@"sync main queue %d", i);
        }
    });
*/
    
    NSLog(@"xxx");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
