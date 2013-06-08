//
//  ViewController.h
//  opengl_test_3
//
//  Created by Kalou on 13-6-8.
//  Copyright (c) 2013年 lijian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLView.h"

@interface ViewController : UIViewController <OpenGLViewDelegate>
{
    OpenGLView *_openGLView;
    CGRect _boundFrame;
}
@end
