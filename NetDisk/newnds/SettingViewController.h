//
//  SettingViewController.h
//  NetDisk
//
//  Created by fengyongning on 13-4-28.
//
//

#import <UIKit/UIKit.h>
@class MYTabBarController;
@interface SettingViewController : UITableViewController
{
    int switchTag;
}
@property(nonatomic,assign)MYTabBarController * rootViewController;
-(void)closeSwitch;
@end
