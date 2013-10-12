//
//  SettingViewController.h
//  ndspro
//
//  Created by fengyongning on 13-9-26.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController<UIActionSheetDelegate,UITableViewDataSource,UITableViewDelegate>
{
    int switchTag;
    UIButton *automicOff_button;
    double locationCacheSize;
}
@property(strong,nonatomic)UITableView *tableView;
@end
