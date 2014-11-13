//
//  ThreeInputViewController.h
//  Movie
//
//  Created by lijian on 14/11/13.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "BaseViewController.h"

@interface ThreeInputViewController : BaseViewController
{
    GPUMovie *_baseMovie;
    GPUMovie *_overMovie;
    GPUMovie *_alphaMovie;
    GPUFilter *_filter;
    GPUView *_glView;
}
@end
