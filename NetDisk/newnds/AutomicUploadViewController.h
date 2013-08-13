//
//  AutomicUploadViewController.h
//  NetDisk
//
//  Created by Yangsl on 13-8-13.
//
//

#import <UIKit/UIKit.h>

@interface AutomicUploadViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *table_view;
    NSMutableArray *table_array;
    UIButton *automicOff_button;
    NSString *space_id;
}

@property(nonatomic,retain) UITableView *table_view;
@property(nonatomic,retain) NSMutableArray *table_array;

@end
