//
//  ViewController.h
//  opengl_test_4_1
//
//  Created by Kalou on 13-6-24.
//  Copyright (c) 2013年 lijian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLView.h"

@interface ViewController : UIViewController <OpenGLViewDelegate>
{
    OpenGLView *_glView;
}
@end
