//
//  MainViewController.h
//  ndspro
//
//  Created by fengyongning on 13-9-26.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property(strong,nonatomic) NSDictionary *dataDic;
@property(strong,nonatomic) NSArray *listArray;
@property(strong,nonatomic) UITableView *tableView;
@end
