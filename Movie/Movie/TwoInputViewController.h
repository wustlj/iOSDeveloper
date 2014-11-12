//
//  TwoInputViewController.h
//  Movie
//
//  Created by lijian on 14/11/12.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "BaseViewController.h"

@interface TwoInputViewController : BaseViewController
{
    GPUMovie *_baseMovie;
    GPUMovie *_maskMovie;
    GPUFilter *_filter;
    GPUView *_glView;
}
@end
