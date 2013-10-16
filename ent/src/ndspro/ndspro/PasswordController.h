//
//  PasswordController.h
//  ndspro
//
//  Created by Yangsl on 13-10-16.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PasswordController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>

@property(nonatomic,retain) UITableView *table_view;

@end
