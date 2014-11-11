//
//  WriterAppendImageViewController.h
//  Movie
//
//  Created by lijian on 14/11/11.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "BaseViewController.h"

@interface WriterAppendImageViewController : BaseViewController
{
    GPUMovie *_baseMovie;
    GPUMovieWriter *_movieWriter;
    
    CGAffineTransform preferredTransform;
    CGSize size;
    
    GPUImage *_appendImage;
}
@end
