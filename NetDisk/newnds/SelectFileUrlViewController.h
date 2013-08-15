//
//  SelectFileUrlViewController.h
//  NetDisk
//
//  Created by Yangsl on 13-8-13.
//
//

#import <UIKit/UIKit.h>
#import "SelectDetailViewController.h"

@interface SelectFileUrlViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *table_view;
    NSString *space_id;
}

@property(nonatomic,retain) UITableView *table_view;

@end
