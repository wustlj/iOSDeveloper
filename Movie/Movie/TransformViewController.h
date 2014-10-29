//
//  TransformViewController.h
//  Movie
//
//  Created by lijian on 14-10-29.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "BaseViewController.h"

@interface TransformViewController : BaseViewController
{
    GPUMovie *_baseMovie;
    GPUFilter *_filter;
    GPUView *_glView;
}
@end
