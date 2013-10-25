//
//  QBImageFileViewController.h
//  NetDisk
//
//  Created by Yangsl on 13-7-25.
//
//

#import <UIKit/UIKit.h>
#import "SCBFileManager.h"

@protocol QBImageFileViewDelegate <NSObject>

-(void)uploadFileder:(NSString *)deviceName;
-(void)uploadFiledId:(NSString *)f_id_;

@end

@interface QBImageFileViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,QBImageFileViewDelegate,SCBFileManagerDelegate>
{
    UITableView *table_view;
    /*
     自定义navBar
     */
    UIView *topView;
    UIView *bottonView;
    UIButton *change_myFile_button;
    BOOL isNeedBackButton;
    NSMutableArray *fileArray;
    id<QBImageFileViewDelegate> qbDelegate;
    NSString *f_name;
    NSString *f_id;
    BOOL isChangeMove;
    SCBFileManager *fileManager;
}
@property(nonatomic,retain) UITableView *table_view;
@property(nonatomic,retain) NSMutableArray *fileArray;
@property(nonatomic,retain) id<QBImageFileViewDelegate> qbDelegate;
@property(nonatomic,retain) NSString *f_name;
@property(nonatomic,retain) NSString *f_id;
@property(nonatomic,assign) BOOL isChangeMove;
@property(nonatomic,assign) NSString *space_id;
@property(nonatomic,retain) SCBFileManager *fileManager;
@property (strong,nonatomic) UIToolbar *moreEditBar;

@end

@interface FileDeviceName : NSObject
{
    NSString *deviceName;
    NSString *f_id;
}
@property(nonatomic,retain) NSString *deviceName;
@property(nonatomic,retain) NSString *f_id;

@end
