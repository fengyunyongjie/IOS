//
//  NDKeepViewController.h
//  NetDisk
//
//  Created by jiangwei on 12-11-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NDKeepCell.h"
#import "Function.h"
#import "ATMHud.h"
#import "ImageShowViewController.h"
@interface NDKeepViewController : UIViewController<NDKeepCellDelegate>
{
    UITableView *m_tableView;
    NSMutableArray *m_keeped_listArray;
    NSMutableArray *m_keeping_listArray;
    NSTimer *m_timer;
    ATMHud *m_hud;
}
@property (nonatomic,retain) IBOutlet UITableView *m_tableView;

- (IBAction)comeBack:(id)sender;

- (void)moveItemToFinshed;
- (void)startTimer;
- (void)stopTimer;

@end
