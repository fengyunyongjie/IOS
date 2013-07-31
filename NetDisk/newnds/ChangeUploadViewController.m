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

#pragma mark －－－－－上传代理

//上传成功
-(void)upFinish:(NSInteger)fileTag
{
    NSLog(@"上传成功");
    UploadViewCell *cell = (UploadViewCell *)[self.uploadListTableView viewWithTag:UploadProessTag+fileTag];
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
    UploadViewCell *cell = (UploadViewCell *)[self.uploadListTableView viewWithTag:UploadProessTag];
    if([cell isKindOfClass:[UploadViewCell class]])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell.jinDuView setCurrFloat:proress];
        });
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
    CGRect bgIamge_rect = CGRectMake(320-180-20, 44, 180, 88);
    UIImageView *bgIamgeView = [[UIImageView alloc] initWithFrame:bgIamge_rect];
    [bgIamgeView setImage:[UIImage imageNamed:@"Bk_na.png"]];
    [self.more_control addSubview:bgIamgeView];
    //全部开始
    UIButton *btnNewFinder= [UIButton buttonWithType:UIButtonTypeCustom];
    float x = bgIamge_rect.origin.x;
    float y = bgIamge_rect.origin.y;
    btnNewFinder.frame=CGRectMake(x, y, 90, 88);
    [btnNewFinder setImage:[UIImage imageNamed:@"Bt_naUpload.png"] forState:UIControlStateNormal];
    [btnNewFinder setBackgroundImage:[UIImage imageNamed:@"Bk_naChecked.png"] forState:UIControlStateHighlighted];
    [btnNewFinder addTarget:self action:@selector(clicked_uploadAll:) forControlEvents:UIControlEventTouchUpInside];
    [self.more_control addSubview:btnNewFinder];
    UILabel *lblNewFinder=[[[UILabel alloc] init] autorelease];
    lblNewFinder.text=@"全部上传";
    lblNewFinder.textAlignment=UITextAlignmentCenter;
    lblNewFinder.font=[UIFont systemFontOfSize:12];
    lblNewFinder.textColor=[UIColor whiteColor];
    lblNewFinder.backgroundColor=[UIColor clearColor];
    lblNewFinder.frame=CGRectMake(x, y+44, 90, 21);
    [self.more_control addSubview:lblNewFinder];
    
    //全部清除
    UIButton *btnDeleteFinder= [UIButton buttonWithType:UIButtonTypeCustom];
    btnDeleteFinder.frame=CGRectMake(x+90, y, 90, 88);
    [btnDeleteFinder setImage:[UIImage imageNamed:@"Bt_naDelAll@2x.png"] forState:UIControlStateNormal];
    [btnDeleteFinder setBackgroundImage:[UIImage imageNamed:@"Bk_naChecked.png"] forState:UIControlStateHighlighted];
    [btnDeleteFinder addTarget:self action:@selector(clicked_clearAll:) forControlEvents:UIControlEventTouchUpInside];
    [self.more_control addSubview:btnDeleteFinder];
    lblNewFinder=[[[UILabel alloc] init] autorelease];
    lblNewFinder.text=@"全部清空";
    lblNewFinder.textAlignment=UITextAlignmentCenter;
    lblNewFinder.font=[UIFont systemFontOfSize:12];
    lblNewFinder.textColor=[UIColor whiteColor];
    lblNewFinder.backgroundColor=[UIColor clearColor];
    lblNewFinder.frame=CGRectMake(x+90, y+44, 90, 21);
    [self.more_control addSubview:lblNewFinder];
    [self.view addSubview:self.more_control];
    [self.more_control setHidden:YES];
    //全部清空
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.uploadListTableView reloadData];
}

#pragma mark －－－－－头部视图的几个方法

-(void)clicked_uploadState:(id)sender
{
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
    
    //显示上传进度
    isHistoryShow = NO;
    AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.uploadingList = app_delegate.upload_all.uploadAllList;
    [self.uploadListTableView reloadData];
}

-(void)clicked_uploadHistory:(id)sender
{
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
    
    //显示上传历史
    isHistoryShow = YES;
    TaskDemo *demo = [[TaskDemo alloc] init];
    if(historyList)
    {
        historyList = nil;
    }
    historyList = [demo selectFinishTaskTable];
    [self.uploadListTableView reloadData];
    [demo release];
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
    [self.more_control setHidden:YES];
    AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app_delegate.upload_all startUpload];
}

-(void)clicked_clearAll:(id)sender
{
    TaskDemo *demo = [[TaskDemo alloc] init];
    BOOL bl = [demo deleteAllTaskTable];
    NSLog(@"删除：%i",bl);
    [demo release];
    if(isHistoryShow)
    {
        if([historyList count]>0)
        {
            [historyList removeAllObjects];
            [self.uploadListTableView reloadData];
        }
    }
    else
    {
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
        return [NSString stringWithFormat:@"上传成功(%i)",count];
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
        title_leble.text =  [NSString stringWithFormat:@" 上传成功(%i)",count];
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
    static NSString *cellString = @"uploadHistoryCell";
    UploadViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellString];
    if(cell==nil)
    {
        cell = [[UploadViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellString];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    if(!isHistoryShow)
    {
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
        if(taskDemo.index_id<[historyList count])
        {
            [taskDemo deleteTaskTable];
            [historyList removeObjectAtIndex:taskDemo.index_id];
            NSIndexPath *index_path = [NSIndexPath indexPathForItem:taskDemo.index_id inSection:0];
            [self.uploadListTableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:index_path, nil] withRowAnimation:UITableViewRowAnimationRight];
        }
    }
    else
    {
        if(taskDemo.index_id<[self.uploadingList count])
        {
            UploadFile *demo = [self.uploadingList objectAtIndex:taskDemo.index_id];
            [demo upStop];
            AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [taskDemo deleteTaskTable];
            [app_delegate.upload_all setIsUpload:NO];
            [self.uploadingList removeObjectAtIndex:taskDemo.index_id];
            app_delegate.upload_all.uploadAllList = self.uploadingList;
            NSIndexPath *index_path = [NSIndexPath indexPathForItem:taskDemo.index_id inSection:0];
            [self.uploadListTableView beginUpdates];
            [self.uploadListTableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:index_path, nil] withRowAnimation:UITableViewRowAnimationRight];
            [self.uploadListTableView endUpdates];
            [app_delegate.upload_all startUpload];
        }
    }
//    int count = 0;
//    if(!isHistoryShow)
//    {
//        if(self.uploadingList)
//        {
//            count = [self.uploadingList count];
//        }
//        title_leble.text = [NSString stringWithFormat:@" 正在上传(%i)",count];
//    }
//    else
//    {
//        if(historyList)
//        {
//            count = [historyList count];
//        }
//        title_leble.text =  [NSString stringWithFormat:@" 上传成功(%i)",count];
//    }
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
