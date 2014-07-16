//
//  DetailViewController.h
//  SwipTableCell
//
//  Created by lijian on 14-4-28.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (retain, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
