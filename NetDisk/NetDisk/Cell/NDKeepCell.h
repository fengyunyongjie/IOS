//
//  NDKeepCell.h
//  NetDisk
//
//  Created by jiangwei on 12-11-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BIButton.h"
@class NDKeepCell;

@protocol NDKeepCellDelegate <NSObject>

@optional
- (void)removeKeepCell:(NDKeepCell *)cell;

@end


@interface NDKeepCell : UITableViewCell
{
    UIView *m_view;
    UIImageView *m_imageView;
    UIActivityIndicatorView *m_activeView;
    UILabel *m_fileNameLabel;
    BIButton *m_removeButton;
    
    id<NDKeepCellDelegate>delegate;
    
    NSIndexPath *m_indexPath;
}
@property (nonatomic,assign) id<NDKeepCellDelegate>delegate;
@property (nonatomic,retain) NSIndexPath *m_indexPath;

@property (nonatomic,retain) IBOutlet UIView *m_view;
@property (nonatomic,retain) IBOutlet UIImageView *m_imageView;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *m_activeView;
@property (nonatomic,retain) IBOutlet UILabel *m_fileNameLabel;
@property (nonatomic,retain) IBOutlet BIButton *m_removeButton;

- (IBAction)removeAction:(id)sender;

- (void)setData:(NSIndexPath *)indexPath dataDic:(NSDictionary *)dataDic;

@end
