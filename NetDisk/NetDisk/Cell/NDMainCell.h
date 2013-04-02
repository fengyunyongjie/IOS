//
//  NDMainCell.h
//  NetDisk
//
//  Created by jiangwei on 12-11-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Function.h"
@class NDMainCell;

@protocol NDMainCellDelegate <NSObject>

@optional
- (void)mainCellAddItem:(NDMainCell *)cell;
- (void)mainCellAddFinderName:(NSString *)finderName;
- (void)mainCellChangeText:(NDMainCell *)cell textEdit:(BOOL)textEdit;

- (void)itemOpertionForCell:(NDMainCell *)cell;
@end

@interface NDMainCell : UITableViewCell<UITextFieldDelegate>
{
    id <NDMainCellDelegate>delegate;
    UILabel *m_fileNameLabel;
    UILabel *m_fileDescLabe;
    UIImageView *m_fileHeadImageView;
    
    UITextField *m_textField;
    UIButton *m_postButton;
    UIButton *m_addButton;
    UIButton *m_shareButton;
    NSIndexPath *m_indexPath;
    
    
@private
	UIImageView*	m_checkImageView;
	BOOL			m_checked;
    UIImageView*	m_lineImageView;
    UIImageView*    m_isDonwloadedImageView;
    UILabel *m_createdTimeLabel;
    UILabel *m_sizeLabel;
}
@property (nonatomic,assign) id <NDMainCellDelegate>delegate;
@property (nonatomic,retain) NSIndexPath *m_indexPath;
@property (nonatomic,retain) IBOutlet UILabel *m_createdTimeLabel;
@property (nonatomic,retain) IBOutlet UILabel *m_sizeLabel;
@property (nonatomic,retain) IBOutlet UILabel *m_fileNameLabel;
@property (nonatomic,retain) IBOutlet UILabel *m_fileDescLabe;
@property (nonatomic,retain) IBOutlet UIImageView *m_fileHeadImageView;     //网盘文件或目录图标
@property (nonatomic,retain) IBOutlet UITextField *m_textField;
@property (nonatomic,retain) IBOutlet UIButton *m_postButton;
@property (nonatomic,retain) IBOutlet UIButton *m_addButton;
@property (nonatomic,retain) IBOutlet UIButton *m_shareButton;
@property (nonatomic,retain) IBOutlet UIImageView *m_lineImageView;
@property (nonatomic,retain) IBOutlet UIImageView *m_isDonwloadedImageView;

- (IBAction)addCell:(id)sender;
- (IBAction)putAddFm:(id)sender;
- (IBAction)shareFile:(id)sender;

- (void)setData:(NSIndexPath *)indexPath dataDic:(NSDictionary *)dataDic;
- (void)setDataForSubPath:(NSIndexPath *)indexPath dataDic:(NSDictionary *)dataDic;

- (void) setChecked:(BOOL)checked;
@end
