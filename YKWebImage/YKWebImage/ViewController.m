//
//  ViewController.m
//  YKWebImage
//
//  Created by lijian on 16/2/22.
//  Copyright © 2016年 youku. All rights reserved.
//

#import "ViewController.h"
#import "YKImageDownload.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_dataArray;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.view addSubview:_tableView];
    
    [self setupData];
}

- (void)setupData {
    _dataArray = [[NSMutableArray alloc] initWithCapacity:10];
    
    [_dataArray addObject:@"http://d.lanrentuku.com/down/png/1601/20yuanxingyinyingtubiao/lollipop.png"];
    [_dataArray addObject:@"http://d.lanrentuku.com/down/png/1601/20yuanxingyinyingtubiao/lifebuoy.png"];
    [_dataArray addObject:@"http://d.lanrentuku.com/down/png/1601/20yuanxingyinyingtubiao/home.png"];
    [_dataArray addObject:@"http://d.lanrentuku.com/down/png/1601/zen-icons/zen-icons-pen.png"];
    [_dataArray addObject:@"http://d.lanrentuku.com/down/png/1507/34yuanxing-icon/stats.png"];

    for (int i=0; i<100; i++) {
        [_dataArray addObject:[NSString stringWithFormat:@"https://s3.amazonaws.com/fast-image-cache/demo-images/FICDDemoImage%03d.jpg", i]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    
    cell.imageView.image = nil;
    [[YKImageDownload shareInstance] downloadImageWithURL:[NSURL URLWithString:_dataArray[indexPath.row]]
                                                 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                     NSLog(@"%ld,%ld,%f", (long)receivedSize, (long)expectedSize, (float)receivedSize/expectedSize);
                                                 } completed:^(UIImage *image, NSError *error, BOOL isFinished) {
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         cell.imageView.image = image;
                                                         [cell setNeedsLayout];
                                                     });
                                                 }];
    
    cell.textLabel.text = [_dataArray[indexPath.row] lastPathComponent];
    
    return cell;
}

@end
