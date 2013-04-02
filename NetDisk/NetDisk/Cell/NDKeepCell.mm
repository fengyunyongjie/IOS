//
//  NDKeepCell.m
//  NetDisk
//
//  Created by jiangwei on 12-11-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NDKeepCell.h"
#import "Function.h"
#import "SevenCBoxClient.h"

@implementation NDKeepCell
@synthesize  m_view,m_imageView,m_activeView,m_fileNameLabel,m_removeButton;
@synthesize delegate;
@synthesize m_indexPath;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)dealloc
{
    [m_view release];
    [m_imageView release];
    [m_activeView release];
    [m_fileNameLabel release];
    [m_removeButton release];
    
    [super dealloc];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setData:(NSIndexPath *)indexPath dataDic:(NSDictionary *)dataDic
{
    self.m_indexPath = indexPath;
    
    m_removeButton.m_buttonType=BIButtonTypeSmall;
    [m_removeButton setNeedsDisplay];
    
    NSString *f_name = [dataDic objectForKey:@"f_name"];
    m_fileNameLabel.text = f_name;
    
    NSString *t_fl = [[dataDic objectForKey:@"f_mime"] lowercaseString];
    if([t_fl isEqualToString:@"png"]||
       [t_fl isEqualToString:@"jpg"]||
       [t_fl isEqualToString:@"jpeg"]||
       [t_fl isEqualToString:@"bmp"]){
        m_imageView.image = [UIImage imageNamed:@"icon_pic"];
        self.accessoryType = UITableViewCellAccessoryNone;
        //显示图片文件缩略图
        {
            NSString *picName = [Function picFileNameFromURL:[dataDic objectForKey:@"compressaddr"]];
            NSLog(@"%@",picName);
            NSString *picPath = [NSString stringWithFormat:@"%@/%@",[Function getTempCachePath],picName];
            
            UIImage *image = [UIImage imageWithContentsOfFile:picPath];
            if (image) {
                NSLog(@"%@",picPath);
                m_imageView.image=image;
            }else
            {
            }
        }
    }
    else{
        m_imageView.image = [UIImage imageNamed:@"icon_unkown"];
        
    }
    
    switch (indexPath.section) {
        case 0:
        {
            m_view.hidden = NO;
            CGRect rect = m_fileNameLabel.frame;
            rect.origin.y = 7;
            m_fileNameLabel.frame = rect;

        }
            break;
        case 1:
        {
            CGRect rect = m_fileNameLabel.frame;
            rect.origin.y = 15;
            m_fileNameLabel.frame = rect;
            m_view.hidden = YES;
            
        }
            break;    
        default:
            break;
    }
}
- (IBAction)removeAction:(id)sender
{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(removeKeepCell:)]) {
        [self.delegate removeKeepCell:self];
    }
}
@end
