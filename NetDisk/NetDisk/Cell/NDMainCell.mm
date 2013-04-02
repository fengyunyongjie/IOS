//
//  NDMainCell.m
//  NetDisk
//
//  Created by jiangwei on 12-11-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NDMainCell.h"
#import "SevenCBoxClient.h"

void callfyn(Value &jsonValue,void *s_pv);

@implementation NDMainCell
@synthesize delegate;
@synthesize m_fileNameLabel,m_fileDescLabe,m_fileHeadImageView,m_lineImageView,m_isDonwloadedImageView,m_createdTimeLabel,m_sizeLabel;
@synthesize m_textField,m_postButton,m_addButton,m_shareButton;
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
    [m_fileNameLabel release];
    [m_fileDescLabe release];
    [m_fileHeadImageView release];
    [m_lineImageView release];

    if(m_textField)
    {
        [m_textField release],m_textField=nil;
    }
        
    [m_postButton release];
    [m_addButton release];
    [m_shareButton release];
    [m_indexPath release];
    
    [m_checkImageView release];
	m_checkImageView = nil;
    
    [m_isDonwloadedImageView release];
    m_isDonwloadedImageView = nil;
    
    [m_createdTimeLabel release];
    [m_sizeLabel release];
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (m_textField) {
        m_textField.delegate = self;
    }
    

}

- (void)setData:(NSIndexPath *)indexPath dataDic:(NSDictionary *)dataDic
{
    m_isDonwloadedImageView.hidden = YES;
    self.m_indexPath = indexPath;
    m_fileDescLabe.hidden = YES;
    self.backgroundColor = [UIColor clearColor];
    m_fileNameLabel.textColor = [UIColor colorWithRed:0.129f green:0.129f blue:0.129f alpha:1.0f];
    m_fileNameLabel.frame = CGRectMake(48, 14, 240, 21);
    m_sizeLabel.hidden = YES;
    m_createdTimeLabel.hidden = YES;
    switch (indexPath.section) {
        case 0:
            [m_shareButton setImage:[UIImage imageNamed:@"icon_more"] forState:UIControlStateNormal];
            self.m_shareButton.userInteractionEnabled = NO;
            self.m_shareButton.hidden = NO;
            switch (indexPath.row) {
                case 0:
                    //m_fileNameLabel.textColor = [UIColor colorWithRed:0.0 green:0.4 blue:0.0 alpha:1.0];
                    m_fileNameLabel.text = @"我的共享";
                    m_fileDescLabe.text = @"仅好友可见";
                    m_fileDescLabe.hidden = NO;
                    m_fileHeadImageView.image = [UIImage imageNamed:@"icon_myShare"];
                    break;
//                case 1:
//                    //m_fileNameLabel.textColor = [UIColor colorWithRed:1.0 green:0.4 blue:0.0 alpha:1.0];
//                    m_fileNameLabel.text = @"我的照片";
//                    m_fileHeadImageView.image = [UIImage imageNamed:@"icon_myPhoto"];
//                    break;
                case 1:
                    //m_fileNameLabel.textColor = [UIColor colorWithRed:0.0 green:0.4 blue:0.0 alpha:1.0];
                    m_fileNameLabel.text = @"我的收藏";
                    m_fileHeadImageView.image = [UIImage imageNamed:@"icon_myFavorite"];
                    break;
           /*     case 3:
                    //m_fileNameLabel.textColor = [UIColor colorWithRed:0.0 green:0.4 blue:0.0 alpha:1.0];
                    m_fileNameLabel.text = @"我的空间";
                    m_fileHeadImageView.image = [UIImage imageNamed:@"icon_myShare"];
                    break;
                case 4:
                    //m_fileNameLabel.textColor = [UIColor colorWithRed:1.0 green:0.4 blue:0.0 alpha:1.0];
                    m_fileNameLabel.text = @"账户设置";
                    m_fileHeadImageView.image = [UIImage imageNamed:@"icon_myPhoto"];
                    break;*/
                case 2:
                    //m_fileNameLabel.textColor = [UIColor colorWithRed:1.0 green:0.4 blue:0.0 alpha:1.0];
                    m_fileNameLabel.text = @"传输管理";
                    m_fileHeadImageView.image = [UIImage imageNamed:@"icon_myTrans"];
                    break;
                default:
                    break;
            }
            break;
        case 1:
        {   
            m_fileNameLabel.frame = CGRectMake(48, 7, 240, 21);
            m_sizeLabel.hidden = NO;
            m_createdTimeLabel.hidden = NO;
            
            self.m_shareButton.hidden = YES;
            
            NSString *text = [dataDic objectForKey:@"f_name"];
            NSString *tid=[dataDic objectForKey:@"f_id"];
            NSString *t_fl = [[dataDic objectForKey:@"f_mime"] lowercaseString];
            m_createdTimeLabel.text = [dataDic objectForKey:@"f_create"];
            m_fileNameLabel.text = [dataDic objectForKey:@"f_name"];
            
            //显示操作图标“icon_arrowDown”
            [m_shareButton setImage:[UIImage imageNamed:@"icon_arrowDown"] forState:UIControlStateNormal];
            self.m_shareButton.userInteractionEnabled = YES;
            self.m_shareButton.hidden = NO;
            
            //－－目录－－
            if ([t_fl isEqualToString:@"directory"]) {
                
                //隐藏文件大小信息
                m_sizeLabel.hidden = YES;
                
                //无选中样式
                self.selectionStyle=UITableViewCellSelectionStyleNone;
                
                //图标设为文件夹图标"icon_Folder"
                m_fileHeadImageView.image = [UIImage imageNamed:@"icon_Folder"];
            }
            //－－图像文件－－
            else if([t_fl isEqualToString:@"png"]||
                    [t_fl isEqualToString:@"jpg"]||
                    [t_fl isEqualToString:@"jpeg"]||
                    [t_fl isEqualToString:@"bmp"]){
                
                //显示图标
                m_fileHeadImageView.image = [UIImage imageNamed:@"icon_pic"];
                //显示图片文件缩略图
                {
                    NSNumber *daf =[dataDic objectForKey:@"f_id"];
                    string f_id = [[Function covertNumberToString:daf] cStringUsingEncoding:NSUTF8StringEncoding];
                    NSString *picName = [Function picFileNameFromURL:[dataDic objectForKey:@"compressaddr"]];
                    NSString *picPath = [NSString stringWithFormat:@"%@/%@",[Function getTempCachePath],picName];
                    
                    UIImage *image = [UIImage imageWithContentsOfFile:picPath];
                    if (image) {
                        m_fileHeadImageView.image=image;
                    }else
                    {
//                        SevenCBoxClient::FmDownloadThumbFile(f_id,[picPath cStringUsingEncoding:NSUTF8StringEncoding]);
                        //SevenCBoxClient::StartTaskMonitor();
                    }
                }
                //self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            //－－其它－－
            else{
                m_fileHeadImageView.image = [UIImage imageNamed:@"icon_unkown"];
                
            }
            if (![t_fl isEqualToString:@"directory"]) {
//                self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                m_sizeLabel.text = [Function convertSize:[dataDic objectForKey:@"f_size"]];
                
                NSString *filePath=[[Function getImgCachePath] stringByAppendingPathComponent:text];
                if([Function fileSizeAtPath:filePath]>2)
                {
                    m_isDonwloadedImageView.hidden = NO;
                }
            }
            
            
        }   

            break;
        default:
            break;
             
    }
}
void callfyn(Value &jsonValue,void *s_pv)
{
//    string vall = jsonValue.toStyledString().c_str();
//    NSString *vallStr = [NSString stringWithCString:vall.c_str() encoding:NSUTF8StringEncoding];
////    [s_pv keepFileSucess:vallStr];
}
- (void)setDataForSubPath:(NSIndexPath *)indexPath dataDic:(NSDictionary *)dataDic
{
    self.m_indexPath = indexPath;
    
//    m_fileNameLabel.frame = CGRectMake(48, 14, 240, 21);
    m_sizeLabel.hidden = NO;
    m_createdTimeLabel.hidden = NO;
    
    m_isDonwloadedImageView.hidden = YES;
    m_fileDescLabe.hidden = YES;
    self.backgroundColor = [UIColor clearColor];
    m_fileNameLabel.textColor = [UIColor colorWithRed:0.129f green:0.129f blue:0.129f alpha:1.0f];
    self.m_shareButton.hidden = YES;
    
    m_fileNameLabel.frame = CGRectMake(48, 7, 240, 21);
    m_sizeLabel.hidden = NO;
    m_createdTimeLabel.hidden = NO;
    
    self.m_shareButton.hidden = YES;
    
    NSString *text = [dataDic objectForKey:@"f_name"];
    NSString *tid=[dataDic objectForKey:@"f_id"];
    NSString *t_fl = [[dataDic objectForKey:@"f_mime"] lowercaseString];
    m_createdTimeLabel.text = [dataDic objectForKey:@"f_create"];
    m_fileNameLabel.text = [dataDic objectForKey:@"f_name"];
    
    //显示操作图标“icon_arrowDown”
    [m_shareButton setImage:[UIImage imageNamed:@"icon_arrowDown"] forState:UIControlStateNormal];
    self.m_shareButton.userInteractionEnabled = YES;
    self.m_shareButton.hidden = NO;
    
    //－－目录－－
    if ([t_fl isEqualToString:@"directory"]) {
        
        //隐藏文件大小信息
        m_sizeLabel.hidden = YES;
        
        //无选中样式
        self.selectionStyle=UITableViewCellSelectionStyleNone;
        
        //图标设为文件夹图标"icon_Folder"
        m_fileHeadImageView.image = [UIImage imageNamed:@"icon_Folder"];
    }
    //－－图像文件－－
    else if([t_fl isEqualToString:@"png"]||
            [t_fl isEqualToString:@"jpg"]||
            [t_fl isEqualToString:@"jpeg"]||
            [t_fl isEqualToString:@"bmp"]){
        
        //显示图标
        m_fileHeadImageView.image = [UIImage imageNamed:@"icon_pic"];
        //显示图片文件缩略图
        {
            NSNumber *daf =[dataDic objectForKey:@"f_id"];
            string f_id = [[Function covertNumberToString:daf] cStringUsingEncoding:NSUTF8StringEncoding];
            NSString *picName = [Function picFileNameFromURL:[dataDic objectForKey:@"compressaddr"]];
            NSString *picPath = [NSString stringWithFormat:@"%@/%@",[Function getTempCachePath],picName];
            
            UIImage *image = [UIImage imageWithContentsOfFile:picPath];
            if (image) {
                m_fileHeadImageView.image=image;
            }else
            {
//                SevenCBoxClient::FmDownloadThumbFile(f_id,[picPath cStringUsingEncoding:NSUTF8StringEncoding]);
                //SevenCBoxClient::StartTaskMonitor();
            }
        }
        //self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    //－－其它－－
    else{
        m_fileHeadImageView.image = [UIImage imageNamed:@"icon_unkown"];
        
    }
    if (![t_fl isEqualToString:@"directory"]) {
        //                self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        m_sizeLabel.text = [Function convertSize:[dataDic objectForKey:@"f_size"]];
        
        NSString *filePath=[[Function getImgCachePath] stringByAppendingPathComponent:text];
        if([Function fileSizeAtPath:filePath]>2)
        {
            m_isDonwloadedImageView.hidden = NO;
        }
    }
}
#pragma mark - IBAction Methods
- (IBAction)addCell:(id)sender{
/*    m_addButton.hidden = YES;
    m_postButton.hidden = NO;
    m_textField.hidden = NO;
 */
  //  m_addButton.userInteractionEnabled = NO;
    if (self.delegate&&[self.delegate respondsToSelector:@selector(mainCellAddItem:)]) {
        [self.delegate mainCellAddItem:self];
    }
}

- (IBAction)putAddFm:(id)sender{
    NSString *textStr = m_textField.text;
    if (textStr==nil||[textStr isEqualToString:@""]) {
        UIAlertView *_alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"文件夹名称不可为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [_alertView show];
        [_alertView release];
        return;
    }
    [m_textField resignFirstResponder];
    if (self.delegate&&[self.delegate respondsToSelector:@selector(mainCellAddFinderName:)]) {
        [self.delegate mainCellAddFinderName:m_textField.text];
    }
}
- (IBAction)shareFile:(id)sender{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(itemOpertionForCell:)]) {
        [self.delegate itemOpertionForCell:self];
    }
}
#pragma mark - UITextFieldDelegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(mainCellChangeText:textEdit:)]) {
        [self.delegate mainCellChangeText:self textEdit:YES];
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (m_textField!=nil) {
        [m_textField resignFirstResponder];
    }
    if (self.delegate&&[self.delegate respondsToSelector:@selector(mainCellChangeText:textEdit:)]) {
        [self.delegate mainCellChangeText:self textEdit:NO];
    }
    return YES;
}

- (void) setCheckImageViewCenter:(CGPoint)pt alpha:(CGFloat)alpha animated:(BOOL)animated
{
	if (animated)
	{		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.3];
		
		m_checkImageView.center = pt;
		m_checkImageView.alpha = alpha;
		
		[UIView commitAnimations];
	}
	else
	{
		m_checkImageView.center = pt;
		m_checkImageView.alpha = alpha;
	}
}


- (void) setEditing:(BOOL)editting animated:(BOOL)animated
{
	if (self.editing == editting)
	{
		return;
	}
	
	[super setEditing:editting animated:animated];
	
	if (editting)
	{
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.backgroundView = [[[UIView alloc] init] autorelease];
		self.backgroundView.backgroundColor = [UIColor clearColor];
		
		if (m_checkImageView == nil)
		{
			m_checkImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Unselected.png"]];
			[self addSubview:m_checkImageView];
		}
		
		[self setChecked:m_checked];
		m_checkImageView.center = CGPointMake(-CGRectGetWidth(m_checkImageView.frame) * 0.5, 
											  CGRectGetHeight(self.bounds) * 0.5);
		m_checkImageView.alpha = 0.0;
		[self setCheckImageViewCenter:CGPointMake(20.5, CGRectGetHeight(self.bounds) * 0.5)
								alpha:1.0 animated:animated];
        
        CGRect lineRect = m_lineImageView.frame;
        lineRect.origin.x = lineRect.origin.x-30;
        m_lineImageView.frame = lineRect;
        
        
	}
	else 
	{
		m_checked = NO;
		self.selectionStyle = UITableViewCellSelectionStyleBlue;
		self.backgroundView = nil;
		
		if (m_checkImageView)
		{
			[self setCheckImageViewCenter:CGPointMake(-CGRectGetWidth(m_checkImageView.frame) * 0.5, 
													  CGRectGetHeight(self.bounds) * 0.5)
									alpha:0.0 
								 animated:animated];
		}
        CGRect lineRect = m_lineImageView.frame;
        lineRect.origin.x = 0;
        m_lineImageView.frame = lineRect;
	}
}



- (void) setChecked:(BOOL)checked
{
	if (checked)
	{
		m_checkImageView.image = [UIImage imageNamed:@"Selected.png"];
		self.backgroundView.backgroundColor = [UIColor colorWithRed:223.0/255.0 green:230.0/255.0 blue:250.0/255.0 alpha:1.0];
	}
	else
	{
		m_checkImageView.image = [UIImage imageNamed:@"Unselected.png"];
		self.backgroundView.backgroundColor = [UIColor whiteColor];
	}
	m_checked = checked;
}
@end
