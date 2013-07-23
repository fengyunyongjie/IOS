//
//  MainViewController.h
//  NetDisk
//
//  Created by fengyongning on 13-7-22.
//
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property(strong,nonatomic)UITableView *tableView;
@end
