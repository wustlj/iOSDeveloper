//
//  WriterViewController.h
//  Movie
//
//  Created by lijian on 14-10-29.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseViewController.h"

@interface WriterViewController : BaseViewController
{
    GPUMovie *_baseMovie;
    GPUMovieWriter *_movieWriter;
    
    CGAffineTransform preferredTransform;
    CGSize size;
}
@end
