//
//  SelectFileUrlViewController.h
//  NetDisk
//
//  Created by Yangsl on 13-8-13.
//
//

#import <UIKit/UIKit.h>
#import "SelectDetailViewController.h"
#import "SCBFileManager.h"

@protocol SelectFileUrlDelegate <NSObject>

-(void)setFileSpace:(NSString *)spaceID withFileFID:(NSString *)fID;

@end

@interface SelectFileUrlViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,SCBFileManagerDelegate,SelectDetailViewDelegate,SelectFileUrlDelegate>
{
    UITableView *table_view;
    NSString *space_id;
    SCBFileManager *fileManager;
    NSMutableArray *tableArray;
    int showType; //0 是默认，1 是家庭空间
    BOOL isAutomatic; //0 是上传，1是其他
    id<SelectFileUrlDelegate> delegate;
    BOOL isEdtion;
}

@property(nonatomic,retain) UITableView *table_view;
@property(nonatomic,retain) SCBFileManager *fileManager;
@property(nonatomic,retain) NSMutableArray *tableArray;
@property(nonatomic,assign) int showType;
@property(nonatomic,assign) BOOL isAutomatic;
@property(nonatomic,retain) id<SelectFileUrlDelegate> delegate;
@property(nonatomic,assign) BOOL isEdtion;

@end
