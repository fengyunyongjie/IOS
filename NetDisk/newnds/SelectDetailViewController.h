//
//  SelectDetailViewController.h
//  NetDisk
//
//  Created by Yangsl on 13-8-13.
//
//

#import <UIKit/UIKit.h>

@interface SelectDetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *table_view;
    NSString *f_id; //目录id
    NSString *selected_id;
    NSArray *array_id;
}

@property(nonatomic,retain) UITableView *table_view;
@property(nonatomic,retain) NSString *f_id; //目录id
@property(nonatomic,retain) NSString *selected_id;
@property(nonatomic,retain) NSArray *array_id;

@end
