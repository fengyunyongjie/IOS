//
//  MASettingViewController.h
//  NetDisk
//
//  Created by fengyongning on 13-11-7.
//
//

#import <UIKit/UIKit.h>

@interface MASettingViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property(strong,nonatomic)UITableView *tableView;
@property(strong,nonatomic)NSArray *listArray;
@end
