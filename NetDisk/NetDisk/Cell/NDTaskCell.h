//
//  NDTaskCell.h
//  NetDisk
//
//  Created by jiangwei on 13-1-7.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BIButton.h"
#import "Function.h"
#include "clientlib/SevenCBoxClient.h"
#include "clientlib/Task.h"

@class NDTaskCell;

@protocol NDTaskCellDelegate <NSObject>

@optional
- (void)removeTaskCell:(NDTaskCell *)cell;

@end

@interface NDTaskCell : UITableViewCell
{
    BIButton *m_startButton;
    BIButton *m_removeButton;
    UIImageView *m_imageView;
    UIProgressView *m_progressView;
    UILabel *m_fileNameLabel;
    UILabel *m_statusLabel;
    
    int m_taskid;
    id<NDTaskCellDelegate>delegate;
    NSIndexPath *m_indexPath;
    NSDictionary *m_dataDic;
}
@property (nonatomic,retain) NSDictionary *m_dataDic;
@property (nonatomic,retain) NSIndexPath *m_indexPath;
@property (nonatomic,assign) id<NDTaskCellDelegate>delegate;
@property (nonatomic,retain) IBOutlet BIButton *m_startButton;
@property (nonatomic,retain) IBOutlet BIButton *m_removeButton;
@property (nonatomic,retain) IBOutlet UIImageView *m_imageView;
@property (nonatomic,retain) IBOutlet UIProgressView *m_progressView;
@property (nonatomic,retain) IBOutlet UILabel *m_fileNameLabel;
@property (nonatomic,retain) IBOutlet UILabel *m_statusLabel;

@property (nonatomic,assign) int m_taskid;

- (IBAction)removeTask:(id)sender;
- (IBAction)actionTask:(id)sender;
- (void)setData:(NSDictionary *)dataDic;
@end
