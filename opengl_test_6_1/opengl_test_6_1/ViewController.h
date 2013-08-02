//
//  ViewController.h
//  opengl_test_6
//
//  Created by lijian on 13-7-18.
//  Copyright (c) 2013年 lijian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLView.h"

@interface ViewController : UIViewController <OpenGLViewDelegate>
{
    OpenGLView *_glView;
}
@end
