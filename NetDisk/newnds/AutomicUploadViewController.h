//
//  AutomicUploadViewController.h
//  NetDisk
//
//  Created by Yangsl on 13-8-13.
//
//

#import <UIKit/UIKit.h>
#import "SelectFileUrlViewController.h"

@interface AutomicUploadViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *table_view;
    NSMutableArray *table_array;
    UIButton *automicOff_button;
    NSString *space_id;
    NSString *table_string;
}

@property(nonatomic,retain) UITableView *table_view;
@property(nonatomic,retain) NSMutableArray *table_array;
@property(nonatomic,retain) NSString *table_string;

@end
