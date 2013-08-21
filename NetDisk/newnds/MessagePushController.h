//
//  MessagePushController.h
//  NetDisk
//
//  Created by Yangsl on 13-8-5.
//
//

#import <UIKit/UIKit.h>
#import "SCBMessageManager.h"
#import "SCBFriendManager.h"
#import "SCBShareManager.h"

@interface MessagePushController : UIViewController<UITableViewDataSource,UITableViewDelegate,SCBMessageManagerDelegate,SCBFriendManagerDelegate,SCBShareManagerDelegate>
{
    UITableView *table_view;
    /*
     自定义navBar
     */
    UIView *topView;
    NSMutableArray *table_array;
    SCBMessageManager *messageManager;
    SCBFriendManager *friendManager;
    SCBShareManager *shareManager;
    NSString *group_id;
    BOOL isSelect;
    BOOL isHiddenTabbar;
    int unreadBL;
}

@property(nonatomic,retain) UITableView *table_view;
@property(nonatomic,retain) UIView *topView;
@property(nonatomic,retain) NSMutableArray *table_array;
@property(nonatomic,retain) SCBMessageManager *messageManager;
@property(nonatomic,retain) SCBFriendManager *friendManager;
@property(nonatomic,retain) SCBShareManager *shareManager;
@property(nonatomic,retain) NSString *group_id;
@property(nonatomic,assign) BOOL isHiddenTabbar;


@end
