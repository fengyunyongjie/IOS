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

#define TableViewHeight self.view.frame.size.height-TabBarHeight-44
#define ChangeTabWidth 90
#define RightButtonBoderWidth 0
#define UploadProessTag 10000

@interface ChangeUploadViewController ()

@end

@implementation ChangeUploadViewController
@synthesize topView;
@synthesize uploadListTableView;
@synthesize uploadingList;
@synthesize historyList;
@synthesize isHistoryShow;

#pragma mark －－－－－上传代理

//上传成功
-(void)upFinish:(NSInteger)fileTag
{
    NSLog(@"上传成功");
    UploadViewCell *cell = (UploadViewCell *)[self.uploadListTableView viewWithTag:UploadProessTag+fileTag];
    if([cell isKindOfClass:[UploadViewCell class]])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell.progressView setProgress:1 animated:YES];
        });
        
        [uploadingList removeObjectAtIndex:0];
        [self.uploadListTableView reloadData];
        if([uploadingList count]>0)
        {
            UploadFile *upload_file = [uploadingList objectAtIndex:0];
            [upload_file setDelegate:self];
            [upload_file upload];
        }
    }
}

//上传进行时，发送上传进度数据
-(void)upProess:(float)proress fileTag:(NSInteger)fileTag
{
    NSLog(@"上传进行时，发送上传进度数据");
    UploadViewCell *cell = (UploadViewCell *)[self.uploadListTableView viewWithTag:UploadProessTag+fileTag];
    if([cell isKindOfClass:[UploadViewCell class]])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell.progressView setProgress:proress animated:YES];
        });
    }
}

//上传失败
-(void)upError:(NSInteger)fileTag
{
    UploadViewCell *cell = (UploadViewCell *)[self.uploadListTableView viewWithTag:UploadProessTag+fileTag];
    if([cell isKindOfClass:[UploadViewCell class]])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell.progressView setProgress:0.5 animated:YES];
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
//    TaskDemo *demo = [[TaskDemo alloc] init];
//    [photoArray removeAllObjects];
//    photoArray = [demo selectAllTaskTable];
    [self.uploadListTableView reloadData];
//    [demo release];
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        isHistoryShow = YES;
        TaskDemo *demo = [[TaskDemo alloc] init];
        if(historyList)
        {
            historyList = nil;
        }
        historyList = [demo selectFinishTaskTable];
        [self.uploadListTableView reloadData];
        [demo release];
    });
}

-(void)clicked_more:(id)sender
{
    //打开照片库
    QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsMultipleSelection = YES;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
    [navigationController setNavigationBarHidden:YES];
    [self presentModalViewController:navigationController animated:YES];
    [imagePickerController release];
    [navigationController release];
}
#pragma mark ------照片库代理方法
-(void)changeUpload:(NSMutableOrderedSet *)array_
{
    UIButton *photo_button = (UIButton *)[self.view viewWithTag:23];
    [self clicked_uploadState:photo_button];
    isHistoryShow = FALSE;
    
    if(!isHistoryShow)
    {
        if(uploadingList==nil)
        {
            uploadingList = [[NSMutableArray alloc] init];
        }
        int i=0;
        for(ALAsset *asset in array_)
        {
            TaskDemo *demo = [[TaskDemo alloc] init];
            demo.f_state = 0;
            demo.f_data = nil;
            demo.f_lenght = 0;
            demo.f_id = i;
            demo.proess = 0;
            demo.result = [asset retain];
            i++;
            //获取照片名称
            demo.f_base_name = [[asset defaultRepresentation] filename];
            NSError *error = nil;
            Byte *data = malloc(asset.defaultRepresentation.size);
            //获得照片图像数据
            [asset.defaultRepresentation getBytes:data fromOffset:0 length:asset.defaultRepresentation.size error:&error];
            demo.f_data = [NSData dataWithBytesNoCopy:data length:asset.defaultRepresentation.size];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [demo insertTaskTable];
            });
            UploadFile *upload_file = [[UploadFile alloc] init];
            [upload_file setDemo:demo];
            [demo release];
            [upload_file setDeviceName:deviceName];
            [uploadingList insertObject:upload_file atIndex:0];
            [upload_file release];
        }
        if([uploadingList count]>0)
        {
            UploadFile *upload_file = [uploadingList objectAtIndex:0];
            [upload_file setDelegate:self];
            [upload_file upload];
        }
        [self.uploadListTableView reloadData];
    }
    NSLog(@"回到上传管理页面");
}

-(void)changeDeviceName:(NSString *)device_name
{
    NSRange deviceRange = [device_name rangeOfString:@"来自于-"];
    if(deviceRange.length>0)
    {
        deviceName = [[NSString alloc] initWithString:device_name];
    }
    else
    {
        if([device_name isEqualToString:@"(null)"] || [device_name length]==0)
        {
            device_name = [AppDelegate deviceString];
        }
        deviceName = [[NSString alloc] initWithFormat:@"来自于-%@",device_name];
    }
    NSLog(@"deviceName:%@",deviceName);
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
        if(uploadingList)
        {
            count = [uploadingList count];
        }
    }
    else
    {
        if(historyList)
        {
            count = [historyList count];
        }
    }
    
    return [NSString stringWithFormat:@"正在上传(%i)",count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = 0;
    if(!isHistoryShow)
    {
        if(uploadingList)
        {
            count = [uploadingList count];
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
        if(uploadingList)
        {
            UploadFile *demo = [uploadingList objectAtIndex:indexPath.row];
            [cell setTag:UploadProessTag+demo.demo.f_id];
            NSLog(@"cellTag:%i",cell.tag);
            [cell setUploadDemo:demo.demo];
        }
    }
    else
    {
        if(historyList)
        {
            TaskDemo *demo = [historyList objectAtIndex:indexPath.row];
            [cell setTag:UploadProessTag+demo.f_id];
            NSLog(@"cellTag:%i",demo.f_data.length);
            [cell setUploadDemo:demo];
        }
    }
    [cell setDelegate:self];
    return cell;
}

#pragma mark cell代理方法

-(void)deletCell:(id)uploadCell
{
//    UploadViewCell *cell = uploadCell;
    NSLog(@"得到删除回调");
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
