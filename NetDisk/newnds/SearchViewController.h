//
//  SearchViewController.h
//  NetDisk
//
//  Created by Yangsl on 13-9-5.
//
//

#import <UIKit/UIKit.h>
#import "FileTableView.h"
#import <MessageUI/MessageUI.h>

@interface SearchViewController : UIViewController <FileTableViewDelegate,UITextFieldDelegate,MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate>
{
    FileTableView *fileTableView;
    UIView *topView;
    UIView *searchView;
    UITextField *tfdSearch;
    MBProgressHUD *hud;
}

@property(nonatomic,retain) FileTableView *fileTableView;
@property(nonatomic,retain) UIView *topView;
@property(nonatomic,retain) UIView *searchView;
@property(nonatomic,retain) UITextField *tfdSearch;
@property(nonatomic,retain) MBProgressHUD *hud;

@end
