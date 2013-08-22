//
//  PhotoTableView.h
//  NetDisk
//
//  Created by Yangsl on 13-8-22.
//
//

#import <UIKit/UIKit.h>
#import "SCBPhotoManager.h"

@interface PhotoTableView : UITableView <SCBPhotoDelegate,UITableViewDataSource,UITableViewDelegate>
{
    SCBPhotoManager *photoManager;
    NSInteger show_height;
    NSMutableDictionary *allDictionary;
    NSInteger imageTa;
    UITableView *table_view;
    UIActivityIndicatorView *activity_indicator;
    NSString *user_id;
    NSString *user_token;
    NSMutableArray *allKeys;
    
    NSMutableArray *_arrVisibleCells; //重用的cell
	NSMutableDictionary *_dicReuseCells; //选中的数据
    BOOL editBL;  //是否为编辑状态，默认为false
    UIView *bottonView;
    NSMutableDictionary *photo_diction;
}

@property(nonatomic,assign) SCBPhotoManager *photoManager;
@property(nonatomic,assign) NSInteger show_height;
@property(nonatomic,retain) NSMutableDictionary *allDictionary;
@property(nonatomic,assign) NSInteger imageTa;
@property(nonatomic,retain) UITableView *table_view;
@property(nonatomic,retain) UIActivityIndicatorView *activity_indicator;
@property(nonatomic,retain) NSString *user_id;
@property(nonatomic,retain) NSString *user_token;
@property(nonatomic,retain) NSMutableArray *allKeys;

@property(nonatomic,retain) NSMutableArray *_arrVisibleCells; //重用的cell
@property(nonatomic,retain) NSMutableDictionary *_dicReuseCells; //选中的数据
@property(nonatomic,assign) BOOL editBL;  //是否为编辑状态，默认为false
@property(nonatomic,retain) UIView *bottonView;
@property(nonatomic,retain) NSMutableDictionary *photo_diction;

@end
