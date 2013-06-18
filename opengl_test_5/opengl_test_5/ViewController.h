//
//  ViewController.h
//  opengl_test_5
//
//  Created by Kalou on 13-6-18.
//  Copyright (c) 2013年 lijian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLView.h"

@interface ViewController : UIViewController <OpenGLViewDelegate>
{
    OpenGLView *_glView;
}

- (IBAction)shoulderRotateAction:(id)sender;
- (IBAction)belowRotateAction:(id)sender;

@end
