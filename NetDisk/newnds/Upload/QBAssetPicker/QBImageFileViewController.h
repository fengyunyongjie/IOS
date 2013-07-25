//
//  QBImageFileViewController.h
//  NetDisk
//
//  Created by Yangsl on 13-7-25.
//
//

#import <UIKit/UIKit.h>
#import "SCBPhotoManager.h"

@interface QBImageFileViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,NewFoldDelegate>
{
    UITableView *table_view;
    /*
     自定义navBar
     */
    UIView *topView;
    UIView *bottonView;
    UIButton *change_myFile_button;
    BOOL isNeedBackButton;
    SCBPhotoManager *photoManger;
    NSMutableArray *fileArray;
    NSMutableArray *url_array;
}
@property(nonatomic,retain) UITableView *table_view;
@property(nonatomic,retain) NSMutableArray *fileArray;

@end
