//
//  SettingViewController.h
//  NetDisk
//
//  Created by fengyongning on 13-4-28.
//
//

#import <UIKit/UIKit.h>
@class MYTabBarController;
@interface SettingViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    int switchTag;
    UIButton *automicOff_button;
}
@property(nonatomic,assign)MYTabBarController * rootViewController;
@property(strong,nonatomic)UITableView *tableView;
-(void)closeSwitch;
@end
