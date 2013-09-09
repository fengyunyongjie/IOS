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

@interface SelectFileUrlViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,SCBFileManagerDelegate>
{
    UITableView *table_view;
    NSString *space_id;
    SCBFileManager *fileManager;
    NSMutableArray *tableArray;
    int showType; //0 是默认，1 是家庭空间
}

@property(nonatomic,retain) UITableView *table_view;
@property(nonatomic,retain) SCBFileManager *fileManager;
@property(nonatomic,retain) NSMutableArray *tableArray;
@property(nonatomic,assign) int showType;

@end
