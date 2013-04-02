//
//  NDTaskCell.m
//  NetDisk
//
//  Created by jiangwei on 13-1-7.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "NDTaskCell.h"

@implementation NDTaskCell
@synthesize m_startButton,m_statusLabel,m_progressView,m_removeButton,m_fileNameLabel,m_imageView;
@synthesize m_taskid,delegate,m_indexPath,m_dataDic;

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
    [m_startButton release];
    [m_statusLabel release];
    [m_progressView release];
    [m_removeButton release];
    [m_fileNameLabel release];
    [m_imageView release];
    [m_indexPath release];
    [super dealloc];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)removeTask:(id)sender
{
    SevenCBoxClient::GetTaskManager()->Delete(m_taskid);
    [m_startButton setImage:[UIImage imageNamed:@"Icons48_Cancel_h"] forState:UIControlStateNormal];
    
    if (self.delegate&&[self.delegate respondsToSelector:@selector(removeTaskCell:)]) {
        [self.delegate removeTaskCell:self];
    }
}
- (IBAction)actionTask:(id)sender
{
    if (m_taskid==0) {
        return;
    }

    CTask *_task = SevenCBoxClient::GetTaskManager()->GetTask(m_taskid);
    int taskState = _task->GetTaskState();
    if (taskState==3) {
        return;
    }
    if (_task->IsRunning()) {
        SevenCBoxClient::GetTaskManager()->Stop(m_taskid);
        [m_startButton setImage:[UIImage imageNamed:@"icon_play"] forState:UIControlStateNormal];
    }
    else{
        SevenCBoxClient::GetTaskManager()->Start(m_taskid);
        [m_startButton setImage:[UIImage imageNamed:@"Icons48_pause_h"] forState:UIControlStateNormal];
    }
    
}
- (void)setData:(NSDictionary *)dataDic
{
    self.m_dataDic = dataDic;
    m_startButton.m_buttonType=BIButtonTypeSmall;
    [m_startButton setNeedsDisplay];
    m_removeButton.m_buttonType=BIButtonTypeSmall;
    [m_removeButton setNeedsDisplay];
    

    m_taskid = [[dataDic objectForKey:@"taskId"] intValue];
    
    m_fileNameLabel.text = [dataDic objectForKey:@"fileName"];
    NSString *process = [dataDic objectForKey:@"percentage"];
    float f_process = [process floatValue]*0.01;
    if (f_process<100.0 && f_process>1.0) {
        //int i=0;
    }
    [m_progressView setProgress:f_process];
    
    NSString *state = [dataDic objectForKey:@"state"];
    switch ([state intValue]) {
        case 0:
            [m_startButton setImage:[UIImage imageNamed:@"icon_play"] forState:UIControlStateNormal];
            break;
        case 1:
            [m_startButton setImage:[UIImage imageNamed:@"Icons48_pause_h"] forState:UIControlStateNormal];
            break;
        case 2:
            [m_startButton setImage:[UIImage imageNamed:@"icon_play"] forState:UIControlStateNormal];
            break;
        case 3:
            [m_startButton setImage:[UIImage imageNamed:@"icon_ok"] forState:UIControlStateNormal];
            break;    
        default:
            break;
    }
    NSString *t_fl = [[Function fileType:m_fileNameLabel.text] lowercaseString];
    if([t_fl isEqualToString:@"png"]||
       [t_fl isEqualToString:@"jpg"]||
       [t_fl isEqualToString:@"jpeg"]||
       [t_fl isEqualToString:@"bmp"]||
       [t_fl isEqualToString:@"directory"]){
        m_imageView.image = [UIImage imageNamed:@"icon_pic"];
        //显示图片文件缩略图
        {
            NSNumber *daf =[dataDic objectForKey:@"f_id"];
            string f_id = [[Function covertNumberToString:daf] cStringUsingEncoding:NSUTF8StringEncoding];
            NSString *picName = [Function picFileNameFromURL:[dataDic objectForKey:@"compressaddr"]];
            NSString *picPath = [NSString stringWithFormat:@"%@/%@",[Function getTempCachePath],picName];
            
            UIImage *image = [UIImage imageWithContentsOfFile:picPath];
            if (image) {
                m_imageView.image=image;
            }
        }
    }
    else{
        m_imageView.image = [UIImage imageNamed:@"icon_unkown"];
    }
    
}
@end
