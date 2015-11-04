//
//  CViewController.h
//  block
//
//  Created by lijian on 15/11/4.
//  Copyright © 2015年 youku. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CompletionBlock)(NSString *);

@interface CViewController : UIViewController

@property (copy, nonatomic) CompletionBlock block;

@end
