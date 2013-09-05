//
//  ChangeUploadViewController.m
//  NetDisk
//
//  Created by Yangsl on 13-7-26.
//
//


#import "ChangeUploadViewController.h"
//引用的类
#import "AppDelegate.h"
#import "UploadAll.h"
#define TableViewHeight self.view.frame.size.height-TabBarHeight-44
#define ChangeTabWidth 90
#define RightButtonBoderWidth 0
#define UploadProessTag 100000
#define UploadFinishProessTag 200000

@interface ChangeUploadViewController ()

@end

@implementation ChangeUploadViewController
@synthesize topView;
@synthesize uploadListTableView;
@synthesize uploadingList;
@synthesize historyList;
@synthesize isHistoryShow;
@synthesize more_control;
@synthesize isUploadAll;
@synthesize isAutomaticUpload;
@synthesize headerView;


#pragma mark ----删除上传时列表
-(void)deleteUploadingIndexRow:(int)row_ isDeleteRecory:(BOOL)isDelete
{
    if(row_<[self.uploadingList count])
    {
        UploadFile *demo = [self.uploadingList objectAtIndex:row_];
        AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if(isDelete)
        {
            [demo.demo deleteTaskTable];
        }
        if(row_ == 0)
        {
            [demo upStop];
            [app_delegate.upload_all setIsUpload:NO];
        }
        
        [self.uploadingList removeObjectAtIndex:row_];
        
        if(!isHistoryShow && [self.uploadListTableView.indexPathsForVisibleRows count]>0)
        {
            [self.uploadListTableView beginUpdates];
            NSIndexPath *index_path = [NSIndexPath indexPathForRow:row_ inSection:0];
            [self.uploadListTableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:index_path, nil] withRowAnimation:UITableViewRowAnimationRight];
            [self.uploadListTableView endUpdates];
            [self.uploadListTableView reloadInputViews];
        }
        int count = 0;
        if(self.uploadingList)
        {
            count = [self.uploadingList count];
        }
        if(!isHistoryShow)
        {
            title_leble.text = [NSString stringWithFormat:@" 正在上传(%i)",count];
        }
        else
        {
            isHistoryShow = FALSE;
            [self clicked_uploadHistory:nil];
        }
        [self updateReloadData];
        if([self.uploadingList count]>0 && row_ == 0 && self.isUploadAll)
        {
            [app_delegate.upload_all startUpload];
        }
    }
}

#pragma mark ----删除上传记录列表
-(void)deleteFinishIndexRow:(int)row_
{
    if(row_<[historyList count])
    {
        TaskDemo *demo = [historyList objectAtIndex:row_];
        [demo deleteTaskTable];
        selectedIndex = demo.index_id+1;
        [historyList removeObjectAtIndex:demo.index_id];
        if(isHistoryShow)
        {
            [self.uploadListTableView beginUpdates];
            NSIndexPath *index_path = [NSIndexPath indexPathForItem:row_ inSection:0];
            [self.uploadListTableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:index_path, nil] withRowAnimation:UITableViewRowAnimationRight];
            int count = 0;
            if(historyList)
            {
                count = [historyList count];
            }
            title_leble.text =  [NSString stringWithFormat:@" 上传完成(%i)",count];
            [self.uploadListTableView endUpdates];
        }
        [self updateReloadData];
    }
}

#pragma mark ----更新上传任务列表
-(void)updateReloadData
{
//    BOOL isChange = FALSE;
    for(int i=0;i<[self.uploadListTableView.visibleCells count];i++)
    {
        UploadViewCell *cell = (UploadViewCell *)[self.uploadListTableView.visibleCells objectAtIndex:i];
        if([cell isKindOfClass:[UploadViewCell class]])
        {
            NSLog(@"-----:%i",i);
        }
        if(!isHistoryShow)
        {
            if(i<[self.uploadingList count])
            {
                UploadFile *demo = [self.uploadingList objectAtIndex:i];
                demo.demo.index_id = i;
                NSLog(@"demo.demo.index_id:%i",demo.demo.index_id);
            }
        }
        else
        {
//            if(cell.demo.index_id == selectedIndex)
//            {
//                isChange = TRUE;
//            }
//            if(isChange)
//            {
//                cell.demo.index_id -= 1;
//            }
            
            for(int j=0;j<[historyList count];j++)
            {
                TaskDemo *demo = [historyList objectAtIndex:j];
                demo.index_id = j;
            }
        }
    }
}

#pragma mark －－－－－上传代理

//上传成功
-(void)upFinish:(NSInteger)fileTag
{
    NSLog(@"上传成功");
    UploadViewCell *cell = (UploadViewCell *)[self.uploadListTableView viewWithTag:UploadProessTag];
    if([cell isKindOfClass:[UploadViewCell class]])
    {
        [cell.jinDuView setCurrFloat:1];
        [self.uploadingList removeObjectAtIndex:0];
        if([self.uploadingList count]>0)
        {
            UploadFile *upload_file = [self.uploadingList objectAtIndex:0];
            upload_file.demo.f_state = 2;
//            [upload_file setDelegate:self];
//            [upload_file upload];
        }
        [self.uploadListTableView reloadData];
    }
}

//上传进行时，发送上传进度数据
-(void)upProess:(float)proress fileTag:(NSInteger)fileTag
{
    NSLog(@"上传进行时，发送上传进度数据");
    if(!isHistoryShow)
    {
        UploadViewCell *cell = (UploadViewCell *)[self.uploadListTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        if([cell isKindOfClass:[UploadViewCell class]])
        {
            [cell.jinDuView setCurrFloat:proress];
        }
    }
    NSLog(@"上传进行时-------------");
}

//上传失败
-(void)upError:(NSInteger)fileTag
{
    UploadViewCell *cell = (UploadViewCell *)[self.uploadListTableView viewWithTag:UploadProessTag+fileTag];
    if([cell isKindOfClass:[UploadViewCell class]])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell.jinDuView setCurrFloat:1];
        });
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //添加头部试图
    [self.navigationController setNavigationBarHidden:YES];
    topView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
    UIImageView *images = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [images setImage:[UIImage imageNamed:@"Bk_Title.png"]];
    [topView addSubview:images];
    
    //把色值转换成图片
    CGRect rect_image = CGRectMake(0, 0, ChangeTabWidth, 44);
    UIGraphicsBeginImageContext(rect_image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,
                                   [hilighted_color CGColor]);
    CGContextFillRect(context, rect_image);
    UIImage * imge = [[[UIImage alloc] init] autorelease];
    imge = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //返回按钮
    UIImage *back_image = [UIImage imageNamed:@"Bt_Back.png"];
    UIButton *back_button = [[UIButton alloc] initWithFrame:CGRectMake(RightButtonBoderWidth, (44-back_image.size.height/2)/2, back_image.size.width/2, back_image.size.height/2)];
    [back_button setBackgroundImage:imge forState:UIControlStateHighlighted];
    [back_button setImage:back_image forState:UIControlStateNormal];
    [topView addSubview:back_button];
    [back_button setHidden:YES];
    [back_button release];
    
    //选项卡栏目
    UIButton *phoot_button = [[UIButton alloc] init];
    [phoot_button setTag:23];
    [phoot_button setFrame:CGRectMake(320/2-ChangeTabWidth, 0, ChangeTabWidth, 44)];
    [phoot_button setTitle:@"上传进度" forState:UIControlStateNormal];
    [phoot_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [phoot_button addTarget:self action:@selector(clicked_uploadState:) forControlEvents:UIControlEventTouchDown];
    [phoot_button setBackgroundImage:imge forState:UIControlStateHighlighted];
    [topView addSubview:phoot_button];
    isHistoryShow = YES;
    [self clicked_uploadState:phoot_button];
    [phoot_button release];
    
    UIButton *file_button = [[UIButton alloc] init];
    [file_button setTag:24];
    [file_button setFrame:CGRectMake(320/2, 0, ChangeTabWidth, 44)];
    [file_button setTitle:@"上传历史" forState:UIControlStateNormal];
    [file_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [file_button addTarget:self action:@selector(clicked_uploadHistory:) forControlEvents:UIControlEventTouchDown];
    [file_button setBackgroundImage:imge forState:UIControlStateHighlighted];
    [topView addSubview:file_button];
    [file_button release];
    
    //更多按钮
    UIButton *more_button = [[UIButton alloc] init];
    UIImage *moreImage = [UIImage imageNamed:@"Bt_More.png"];
    [more_button setFrame:CGRectMake(320-moreImage.size.width/2, (44-moreImage.size.height/2)/2, moreImage.size.width/2, moreImage.size.height/2)];
    [more_button setImage:moreImage forState:UIControlStateNormal];
    [more_button addTarget:self action:@selector(clicked_more:) forControlEvents:UIControlEventTouchUpInside];
    [more_button setBackgroundImage:imge forState:UIControlStateHighlighted];
    [topView addSubview:more_button];
    [more_button release];
    [self.view addSubview:topView];
    
    //添加视图列表
    CGRect rect = CGRectMake(0, 44, 320, TableViewHeight);
    self.uploadListTableView = [[UITableView alloc] initWithFrame:rect];
    [self.uploadListTableView setDataSource:self];
    [self.uploadListTableView setDelegate:self];
    self.uploadListTableView.showsVerticalScrollIndicator = NO;
    self.uploadListTableView.alwaysBounceVertical = YES;
    self.uploadListTableView.alwaysBounceHorizontal = NO;
    [self.view addSubview:self.uploadListTableView];
    
    //添加更多数据
    self.more_control = [[UIControl alloc] initWithFrame:self.view.bounds];
    [self.more_control addTarget:self action:@selector(clicked_more_control:) forControlEvents:UIControlEventTouchDown];
    
    //添加背景
    CGRect bgIamge_rect = CGRectMake(320-180-20, 40, 180, 92);
    bgIamgeView = [[UIImageView alloc] initWithFrame:bgIamge_rect];
    [bgIamgeView setImage:[UIImage imageNamed:@"Bk_na_2.png"]];
    [self.more_control addSubview:bgIamgeView];
    //全部开始
    uploadAll_button= [UIButton buttonWithType:UIButtonTypeCustom];
    float x = bgIamge_rect.origin.x;
    float y = bgIamge_rect.origin.y+4;
    uploadAll_button.frame=CGRectMake(x, y, 90, 88);
    [uploadAll_button setImage:[UIImage imageNamed:@"Bt_naUpload.png"] forState:UIControlStateNormal];
    [uploadAll_button setBackgroundImage:[UIImage imageNamed:@"Bk_naChecked.png"] forState:UIControlStateHighlighted];
    [uploadAll_button addTarget:self action:@selector(clicked_uploadAll:) forControlEvents:UIControlEventTouchUpInside];
    [self.more_control addSubview:uploadAll_button];
    uploadAll_label=[[[UILabel alloc] init] autorelease];
    uploadAll_label.text=@"全部上传";
    uploadAll_label.textAlignment=UITextAlignmentCenter;
    uploadAll_label.font=[UIFont systemFontOfSize:12];
    uploadAll_label.textColor=[UIColor whiteColor];
    uploadAll_label.backgroundColor=[UIColor clearColor];
    uploadAll_label.frame=CGRectMake(x, y+44, 90, 21);
    [self.more_control addSubview:uploadAll_label];
    
    //全部清除
    deleteAll_button= [UIButton buttonWithType:UIButtonTypeCustom];
    deleteAll_button.frame=CGRectMake(x+90, y, 90, 88);
    [deleteAll_button setImage:[UIImage imageNamed:@"Bt_naDelAll@2x.png"] forState:UIControlStateNormal];
    [deleteAll_button setBackgroundImage:[UIImage imageNamed:@"Bk_naChecked.png"] forState:UIControlStateHighlighted];
    [deleteAll_button addTarget:self action:@selector(clicked_clearAll:) forControlEvents:UIControlEventTouchUpInside];
    [self.more_control addSubview:deleteAll_button];
    deleteAll_label=[[[UILabel alloc] init] autorelease];
    deleteAll_label.text=@"全部清空";
    deleteAll_label.textAlignment=UITextAlignmentCenter;
    deleteAll_label.font=[UIFont systemFontOfSize:12];
    deleteAll_label.textColor=[UIColor whiteColor];
    deleteAll_label.backgroundColor=[UIColor clearColor];
    deleteAll_label.frame=CGRectMake(x+90, y+44, 90, 21);
    [self.more_control addSubview:deleteAll_label];
    [self.view addSubview:self.more_control];
    [self.more_control setHidden:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.uploadListTableView reloadData];
}

#pragma mark －－－－－头部视图的几个方法

-(void)clicked_uploadState:(id)sender
{
    if(isHistoryShow)
    {
        isHistoryShow = NO;
        UIButton *button = sender;
        //把色值转换成图片
        CGRect rect_image = CGRectMake(0, 0, ChangeTabWidth, 44);
        UIGraphicsBeginImageContext(rect_image.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context,
                                       [hilighted_color CGColor]);
        CGContextFillRect(context, rect_image);
        UIImage * imge = [[[UIImage alloc] init] autorelease];
        imge = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [button setBackgroundImage:imge forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        UIButton *file_button = (UIButton *)[self.view viewWithTag:24];
        [file_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [file_button setBackgroundImage:nil forState:UIControlStateNormal];
        
        dispatch_async(dispatch_get_main_queue(), ^{
        //显示上传进度
        AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            if([app_delegate.upload_all.uploadAllList count]>0)
            {
                self.uploadingList = app_delegate.upload_all.uploadAllList;
            }
            if([app_delegate.maticUpload.assetArray count]>0)
            {
                [self startAutomatic:automicImage progess:automicProgess taskDemo:automicDemo total:automicTotal];
            }
            [self.uploadListTableView reloadData];
        });
    }
}

-(void)clicked_uploadHistory:(id)sender
{
    if(!isHistoryShow)
    {
        self.uploadListTableView.tableHeaderView = nil;
        
        UIButton *button = sender;
        //把色值转换成图片
        CGRect rect_image = CGRectMake(0, 0, ChangeTabWidth, 44);
        UIGraphicsBeginImageContext(rect_image.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context,
                                       [hilighted_color CGColor]);
        CGContextFillRect(context, rect_image);
        UIImage * imge = [[[UIImage alloc] init] autorelease];
        imge = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [button setBackgroundImage:imge forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        UIButton *photo_button = (UIButton *)[self.view viewWithTag:23];
        [photo_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [photo_button setBackgroundImage:nil forState:UIControlStateNormal];
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        //显示上传历史
        isHistoryShow = YES;
        
        if([historyList count]>0)
        {
            TaskDemo *task_demo = [historyList lastObject];
            [historyList addObjectsFromArray:[task_demo selectFinishTaskTable]];
        }
        else
        {
            TaskDemo *demo = [[TaskDemo alloc] init];
            demo.t_id = 0;
            historyList = [demo selectFinishTaskTable];
            [demo release];
        }
        [self.uploadListTableView reloadData];
        
//        });
    }
}

-(void)clicked_more_control:(id)sender
{
    if(!self.more_control.hidden)
    {
        [self.more_control setHidden:YES];
    }
}

-(void)clicked_more:(id)sender
{
    if(isHistoryShow)
    {
        CGRect bgIamge_rect = CGRectMake(320-180-20+90, 40, 90, 88);
        [bgIamgeView setImage:[UIImage imageNamed:@"Bk_na_2.png"]];
        [bgIamgeView setFrame:bgIamge_rect];
        [uploadAll_button setHidden:YES];
        [uploadAll_label setHidden:YES];
        [deleteAll_button setHidden:NO];
        [deleteAll_label setHidden:NO];
    }
    else
    {
        CGRect bgIamge_rect = CGRectMake(320-180-20, 40, 180, 88);
        [bgIamgeView setImage:[UIImage imageNamed:@"Bk_na_3.png"]];
        [bgIamgeView setFrame:bgIamge_rect];
        
        [uploadAll_button setHidden:NO];
        [uploadAll_label setHidden:NO];
        [deleteAll_button setHidden:NO];
        [deleteAll_label setHidden:NO];
    }
    [self.more_control setHidden:NO];
//    //打开照片库
//    QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
//    imagePickerController.delegate = self;
//    imagePickerController.allowsMultipleSelection = YES;
//    
//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
//    [navigationController setNavigationBarHidden:YES];
//    [self presentModalViewController:navigationController animated:YES];
//    [imagePickerController release];
//    [navigationController release];
}

-(void)clicked_uploadAll:(id)sender
{
    self.isUploadAll = YES;
    [self.more_control setHidden:YES];
    AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app_delegate.upload_all startUpload];
}

-(void)clicked_clearAll:(id)sender
{
    TaskDemo *demo = [[TaskDemo alloc] init];
    if(isHistoryShow)
    {
        BOOL bl = [demo deleteFinishTaskTable];
        NSLog(@"删除：%i",bl);
        if([historyList count]>0)
        {
            [historyList removeAllObjects];
            [self.uploadListTableView reloadData];
        }
    }
    else
    {
        BOOL bl = [demo deleteUploadTaskTable];
        NSLog(@"删除：%i",bl);
        if([self.uploadingList count]>0)
        {
            UploadFile *upload_file = (UploadFile *)[self.uploadingList objectAtIndex:0];
            [upload_file upStop];
            AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [app_delegate.upload_all setIsUpload:NO];
            [self.uploadingList removeAllObjects];
            [self.uploadListTableView reloadData];
        }
    }
    [self.more_control setHidden:YES];
    [demo release];
}


#pragma mark tableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    int count = 0;
    if(!isHistoryShow)
    {
        if(self.uploadingList)
        {
            count = [self.uploadingList count];
        }
        return [NSString stringWithFormat:@"正在上传(%i)",count];
    }
    else
    {
        if(historyList)
        {
            count = [historyList count];
        }
        return [NSString stringWithFormat:@"上传完成(%i)",count];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = 0;
    if(!isHistoryShow)
    {
        if(self.uploadingList)
        {
            count = [self.uploadingList count];
        }
    }
    else
    {
        if(historyList)
        {
            count = [historyList count];
        }
    }
    return count;
}

-(float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect header_rect = CGRectMake(0, 0, 320, 20);
    title_leble = [[UILabel alloc] initWithFrame:header_rect];

    int count = 0;
    if(!isHistoryShow)
    {
        if(self.uploadingList)
        {
            count = [self.uploadingList count];
        }
        title_leble.text = [NSString stringWithFormat:@" 正在上传(%i)",count];
    }
    else
    {
        if(historyList)
        {
            count = [historyList count];
        }
        title_leble.text =  [NSString stringWithFormat:@" 上传完成(%i)",count];
    }
    [title_leble setTextColor:[UIColor whiteColor]];
    [title_leble setBackgroundColor:[UIColor colorWithRed:71.0/255.0 green:85.0/255.0 blue:96.0/255.0 alpha:1]];
    [title_leble setFont:[UIFont systemFontOfSize:14]];
    return [title_leble autorelease];
}

//- (UITableViewHeaderFooterView *)headerViewForSection:(NSInteger)section NS_AVAILABLE_IOS(6_0){
//    CGRect header_rect = CGRectMake(0, 0, 320, 20);
//    UITableViewHeaderFooterView *headerFooterView = [[UITableViewHeaderFooterView alloc] initWithFrame:header_rect];
//    [headerFooterView.textLabel setFont:[UIFont systemFontOfSize:10]];
//    CGRect text_rect = CGRectMake(0, 0, 320, 10);
//    [headerFooterView.textLabel setFrame:text_rect];
//    return [headerFooterView autorelease];
//}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UploadViewCell *cell;
    
    if(!isHistoryShow)
    {
        static NSString *cellString = @"uploadUploadingCell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellString];
        if(cell==nil)
        {
            cell = [[UploadViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellString];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        if(self.uploadingList)
        {
            UploadFile *demo = [self.uploadingList objectAtIndex:indexPath.row];
            [cell setTag:UploadProessTag+[indexPath row]];
            demo.demo.index_id = [indexPath row];
            NSLog(@"cellTag:%i",demo.demo.state);
            [cell setUploadDemo:demo.demo];
        }
    }
    else
    {
        static NSString *cellString = @"uploadHistoryCell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellString];
        if(cell==nil)
        {
            cell = [[UploadViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellString];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        if(historyList)
        {
            TaskDemo *demo = [historyList objectAtIndex:indexPath.row];
            [cell setTag:UploadFinishProessTag+[indexPath row]];
            demo.index_id = [indexPath row];
            NSLog(@"cellTag:%i",demo.f_data.length);
            [cell setUploadDemo:demo];
        }
    }
    [cell setDelegate:self];
    return cell;
}

#pragma mark cell代理方法

-(void)deletCell:(TaskDemo *)taskDemo
{
    if(isHistoryShow)
    {
        [self deleteFinishIndexRow:taskDemo.index_id];
    }
    else
    {
        [self deleteUploadingIndexRow:taskDemo.index_id isDeleteRecory:YES];
//        if(taskDemo.index_id<[self.uploadingList count])
//        {
//            UploadFile *demo = [self.uploadingList objectAtIndex:taskDemo.index_id];
//            [demo upStop];
//            AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//            [taskDemo deleteTaskTable];
//            [app_delegate.upload_all setIsUpload:NO];
//            [self.uploadingList removeObjectAtIndex:taskDemo.index_id];
//            NSIndexPath *index_path = [NSIndexPath indexPathForItem:taskDemo.index_id inSection:0];
//            [self.uploadListTableView beginUpdates];
//            [self.uploadListTableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:index_path, nil] withRowAnimation:UITableViewRowAnimationRight];
//            [self.uploadListTableView endUpdates];
//            
//            //修改视图信息
//            for(int i=0;i<[self.uploadingList count];i++)
//            {
//                UploadFile *demo = [self.uploadingList objectAtIndex:i];
//                UploadViewCell *cell = (UploadViewCell *)[self.uploadListTableView.visibleCells objectAtIndex:i];
//                [cell setTag:UploadProessTag+i];
//                demo.demo.index_id = i;
//                [cell setUploadDemo:demo.demo];
//            }
//            app_delegate.upload_all.uploadAllList = self.uploadingList;
//            [app_delegate.upload_all startUpload];
//        }
    }
}

//自动备份上传
-(void)startAutomatic:(UIImage *)uploadImage progess:(CGFloat)progess taskDemo:(TaskDemo *)taskdemo total:(int)total
{
    automicImage = uploadImage;
    automicProgess = progess;
    automicDemo = taskdemo;
    automicTotal = total;
    
    if(!isHistoryShow)
    {
        if(top_headerView==nil)
        {
            CGRect top_rect = CGRectMake(0, 0, 320, 70);
            top_headerView = [[UIView alloc] initWithFrame:top_rect];
            CGRect label_rect = CGRectMake(0, 0, 320, 20);
            top_header_label = [[UILabel alloc] initWithFrame:label_rect];
            [top_header_label setTextColor:[UIColor whiteColor]];
            [top_header_label setBackgroundColor:[UIColor colorWithRed:71.0/255.0 green:85.0/255.0 blue:96.0/255.0 alpha:1]];
            [top_header_label setFont:[UIFont systemFontOfSize:14]];
            [top_headerView addSubview:top_header_label];
            static NSString *headerString = @"headerView";
            headerView = [[UploadViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:headerString];
            CGRect rect = headerView.frame;
            rect.origin.y = 20;
            rect.size.height = 50;
            [headerView setFrame:rect];
            [top_headerView addSubview:headerView];
            [headerView.button_dele_button setHidden:YES];
        }
        self.uploadListTableView.tableHeaderView = top_headerView;
        [headerView setTag:-100];
        [headerView setUploadDemo:taskdemo];
        if(taskdemo.state == 2)
        {
            [headerView.jinDuView showText:@"已暂停"];
        }
        else
        {
            [headerView.jinDuView setCurrFloat:progess];
        }
        [top_header_label setText:[NSString stringWithFormat:@" 相册自动备份(%i)",total]];
    }
}

//关闭自动备份上传
-(void)stopAutomatic
{
    if(self.uploadListTableView.tableHeaderView)
    {
        self.uploadListTableView.tableHeaderView = nil;
    }
}

#pragma mark UIScrollviewDelegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(isHistoryShow)
    {
        int y = self.uploadListTableView.contentOffset.y+self.uploadListTableView.frame.size.height;
        NSLog(@"y:%i",y);
        if(y>=self.uploadListTableView.contentSize.height)
        {
            NSLog(@"scrollViewDidEndDecelerating-----------0000000000");
            if([historyList count]>0)
            {
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    TaskDemo *task_demo = [historyList lastObject];
                    NSArray *array = [task_demo selectFinishTaskTable];
                    if([array count]>0)
                    {
                        [historyList addObjectsFromArray:array];
                        [self.uploadListTableView reloadData];
                    }
//                });
            }
        }
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(isHistoryShow)
    {
        int y = self.uploadListTableView.contentOffset.y+self.uploadListTableView.frame.size.height;
        NSLog(@"y:%i",y);
        if(y>=self.uploadListTableView.contentSize.height)
        {
            NSLog(@"scrollViewDidEndDecelerating-----------1111111111");
            if([historyList count]>0)
            {
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    TaskDemo *task_demo = [historyList lastObject];
                    NSArray *array = [task_demo selectFinishTaskTable];
                    if([array count]>0)
                    {
                        [historyList addObjectsFromArray:array];
                        [self.uploadListTableView reloadData];
                    }
//                });
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)dealloc
{
    [topView release];
    [uploadListTableView release];
    [uploadingList release];
    [historyList release];
    [super dealloc];
}

@end
