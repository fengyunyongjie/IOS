//
//  SelectDetailViewController.h
//  NetDisk
//
//  Created by Yangsl on 13-8-13.
//
//

#import <UIKit/UIKit.h>
#import "SCBPhotoManager.h"
#import "SCBShareManager.h"

@protocol SelectDetailViewDelegate <NSObject>

-(void)setFileSpace:(NSString *)spaceID withFileFID:(NSString *)fID;

@end

@interface SelectDetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,NewFoldDelegate,SCBShareManagerDelegate,SelectDetailViewDelegate>
{
    UITableView *table_view;
    NSString *space_id; //目录id
    NSString *selected_id;
    NSMutableArray *table_array;
    SCBPhotoManager *photo_manager;
    NSString *f_id;
    SCBShareManager *share_manager;
    NSString *title_string;
    
    UIView *bottonView;
    BOOL isAutomatic; //0 是上传，1是其他
    BOOL isEdtion;
    id<SelectDetailViewDelegate> delegate;
}

@property(nonatomic,retain) UITableView *table_view;
@property(nonatomic,retain) NSString *space_id; //目录id
@property(nonatomic,retain) NSString *selected_id;
@property(nonatomic,retain) NSMutableArray *table_array;
@property(nonatomic,retain) SCBPhotoManager *photo_manager;
@property(nonatomic,retain) NSString *f_id;
@property(nonatomic,retain) SCBShareManager *share_manager;
@property(nonatomic,retain) NSString *title_string;
@property(nonatomic,assign) BOOL isAutomatic; //0 是上传，1是其他
@property(nonatomic,assign) BOOL isEdtion;
@property(nonatomic,retain) id<SelectDetailViewDelegate> delegate;

@end
