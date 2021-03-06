//
//  UploadViewController.m
//  NetDisk
//
//  Created by fengyongning on 13-5-21.
//
//

#import "UploadViewController.h"
#import "ALAsset+AGIPC.h"
#import "TaskDemo.h"
#import "Reachability.h"
#import "SCBSession.h"
#import "AppDelegate.h"
#import "YNFunctions.h"
#import "UploadViewCell.h"

#define TableViewHeight self.view.frame.size.height
#define ChangeTabWidth 90
#define RightButtonBoderWidth 0
#define UploadProessTag 10000

@interface UploadViewController ()

@end

@implementation UploadViewController
@synthesize stateImageview;
@synthesize nameLabel;
@synthesize uploadTypeButton;
@synthesize diyUploadButton;
@synthesize basePhotoLabel;
@synthesize formatLabel;
@synthesize uploadNumberLabel;
@synthesize user_id,user_token;
@synthesize waitBackGround;
@synthesize uploadWaitLabel;
@synthesize uploadWaitButton;
@synthesize uploadImageView;
@synthesize uploadProgressView;
@synthesize currFileNameLabel;
@synthesize uploadFinshPageLabel;
@synthesize unWifiOrNetWorkImageView;
@synthesize uploadFinshLabel;
@synthesize uploadFinshImageView;
@synthesize uploderDemo;
@synthesize isUpload;
@synthesize isStop;
@synthesize isNeedBackButton;
@synthesize isNeedChangeUpload;
@synthesize uploadListTableView;

@synthesize photoArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    isStop = TRUE;
    if (self) {
        
    }
    return self;
}

-(void)dealloc
{
    [user_id release];
    [user_token release];
    [stateImageview release];
    [nameLabel release];
    [uploadTypeButton release];
    [diyUploadButton release];
    [basePhotoLabel release];
    [formatLabel release];
    [uploadNumberLabel release];
    [photoArray release];
    [waitBackGround release];
    [uploadWaitLabel release];
    [uploadWaitButton release];
    [uploadImageView release];
    [uploadProgressView release];
    [currFileNameLabel release];
    [uploadFinshPageLabel release];
    [unWifiOrNetWorkImageView release];
    [uploadFinshLabel release];
    [uploadFinshImageView release];
    [uploderDemo release];
    [super dealloc];
}

- (void)viewDidLoad
{
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
    if(isNeedBackButton)
    {
        UIImage *back_image = [UIImage imageNamed:@"Bt_Back.png"];
        UIButton *back_button = [[UIButton alloc] initWithFrame:CGRectMake(RightButtonBoderWidth, (44-back_image.size.height/2)/2, back_image.size.width/2, back_image.size.height/2)];
        [back_button setBackgroundImage:imge forState:UIControlStateHighlighted];
        [back_button setImage:back_image forState:UIControlStateNormal];
        [topView addSubview:back_button];
        [back_button release];
    }
    [self.tabBarController setHidesBottomBarWhenPushed:YES];
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
    [more_button setFrame:CGRectMake(320-RightButtonBoderWidth-moreImage.size.width/2, (44-moreImage.size.height/2)/2, moreImage.size.width/2, moreImage.size.height/2)];
    [more_button setImage:moreImage forState:UIControlStateNormal];
    [more_button addTarget:self action:@selector(clicked_more:) forControlEvents:UIControlEventTouchDown];
    [more_button setBackgroundImage:imge forState:UIControlStateHighlighted];
    [topView addSubview:more_button];
    [more_button release];
    [self.view addSubview:topView];
    
    baseBL = TRUE;
    isAlert = TRUE;
    libaryTimer = nil;
    allHeight = self.view.frame.size.height - TabBarHeight;
//    int defHeight = (allHeight-260)/2;
//    CGRect rect = CGRectMake((320-184)/2, defHeight, 184, 124);
//    stateImageview = [[UIImageView alloc] initWithFrame:rect];
//    [stateImageview setImage:[UIImage imageNamed:@"upload_bg.png"]];
//    [self.view addSubview:stateImageview];
//
//    rect = CGRectMake(78, rect.origin.y+92, 150, 25);
//    uploadNumberLabel = [[UILabel alloc] initWithFrame:rect];
//    [uploadNumberLabel setBackgroundColor:[UIColor clearColor]];
//    [uploadNumberLabel setTextAlignment:NSTextAlignmentCenter];
//    [self.view addSubview:uploadNumberLabel];
//
//    rect = CGRectMake((320-180)/2, rect.origin.y+40, 180, 25);
//    nameLabel = [[UILabel alloc] initWithFrame:rect];
//    [nameLabel setText:@"自动备份照片"];
//    [self.view addSubview:nameLabel];
//
//    rect = CGRectMake(180, rect.origin.y-4, 82, 33);
//    uploadTypeButton = [[UIButton alloc] initWithFrame:rect];
//    [uploadTypeButton setBackgroundImage:[UIImage imageNamed:@"upload_btn_lock.png"] forState:UIControlStateNormal];
//    [uploadTypeButton addTarget:self action:@selector(updateTypeClick:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:uploadTypeButton];
//
//    rect = CGRectMake((320-180)/2, rect.origin.y+4+40, 180, 25);
//    basePhotoLabel = [[UILabel alloc] initWithFrame:rect];
//    [basePhotoLabel setText:@"本地照片: "];
//    [self.view addSubview:basePhotoLabel];
//
//    rect = CGRectMake((320-180)/2, rect.origin.y+40, 180, 25);
//    formatLabel = [[UILabel alloc] initWithFrame:rect];
//    [formatLabel setText:@"已上传照片: "];
//    [self.view addSubview:formatLabel];
//    deviceName = [AppDelegate deviceString];
//    y = 40;
//    if(![deviceName isEqualToString:@"iPhone 5"])
//    {
//        y = 0;
//    }
//    
//    //准备上传界面
//    //背景图
//    CGRect waitBackRect = CGRectMake(0, y, 320, 222);
//    waitBackGround = [[UIImageView alloc] initWithFrame:waitBackRect];
//    [waitBackGround setImage:[UIImage imageNamed:@"背景图.png"]];
//    [self.view addSubview:waitBackGround];
//    
//    CGRect waitLabelRect = CGRectMake(10, y+240, 300, 20);
//    uploadWaitLabel = [[UILabel alloc] initWithFrame:waitLabelRect];
//    [uploadWaitLabel setText:@"开启照片自动备份"];
//    [uploadWaitLabel setFont:[UIFont systemFontOfSize:16]];
//    [uploadWaitLabel setTextAlignment:NSTextAlignmentCenter];
//    [uploadWaitLabel setBackgroundColor:[UIColor clearColor]];
//    [self.view addSubview:uploadWaitLabel];
//    //上传按钮
//    CGRect waitButtonRect = CGRectMake(89, y+290, 142, 33);
//    uploadWaitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [uploadWaitButton setFrame:waitButtonRect];
//    [uploadWaitButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
//    [uploadWaitButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
//    [uploadWaitButton setTitle:@"开启" forState:UIControlStateNormal];
//    [uploadWaitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [uploadWaitButton setBackgroundImage:[UIImage imageNamed:@"Updata_Bt_Start.png"] forState:UIControlStateNormal];
//    [uploadWaitButton addTarget:self action:@selector(startSouStart) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:uploadWaitButton];
//    
//    CGRect uploadImageRect = CGRectMake(90, y+20, 140, 210);
//    uploadImageView = [[BoderView alloc] initWithFrame:uploadImageRect];
//    [self.view addSubview:uploadImageView];
//    CGRect unWifiOrNetWorkImageRect = CGRectMake(61, y+106, 198, 107);
//    unWifiOrNetWorkImageView = [[UIImageView alloc] initWithFrame:unWifiOrNetWorkImageRect];
//    [self.view addSubview:unWifiOrNetWorkImageView];
//    
//    CGRect progressRect = CGRectMake(40, y+250, 240, 2);
//    uploadProgressView = [[UIProgressView alloc] initWithFrame:progressRect];
//    [self.view addSubview:uploadProgressView];
//    CGRect currFileNameRect = CGRectMake(40, y+277, 240, 25);
//    currFileNameLabel = [[UILabel alloc] initWithFrame:currFileNameRect];
//    [currFileNameLabel setTextAlignment:NSTextAlignmentCenter];
//    [currFileNameLabel setTextColor:[UIColor colorWithRed:57.0/255.0 green:65.0/255.0 blue:92.0/255.0 alpha:1]];
//    [self.view addSubview:currFileNameLabel];
//    CGRect uploadFinshPageRect = CGRectMake(40, y+317, 240, 20);
//    uploadFinshPageLabel = [[UILabel alloc] initWithFrame:uploadFinshPageRect];
//    [uploadFinshPageLabel setTextAlignment:NSTextAlignmentCenter];
//    [uploadFinshPageLabel setFont:[UIFont systemFontOfSize:14]];
//    [uploadFinshPageLabel setTextColor:[UIColor colorWithRed:148.0/255.0 green:156.0/255.0 blue:170.0/255.0 alpha:1]];
//    [self.view addSubview:uploadFinshPageLabel];
//    
//    //上传完成界面
//    CGRect uploadFinshImageRect = CGRectMake(0, y, 320, 222);
//    uploadFinshImageView = [[UIImageView alloc] initWithFrame:uploadFinshImageRect];
//    [uploadFinshImageView setImage:[UIImage imageNamed:@"Updata_Complite.png"]];
//    [self.view addSubview:uploadFinshImageView];
//    CGRect uploadFinshRect = CGRectMake(10, y+260, 300, 20);
//    uploadFinshLabel = [[UILabel alloc] initWithFrame:uploadFinshRect];
//    [uploadFinshLabel setText:@"现已全部完成，你的照片已上传到虹盘"];
//    [uploadFinshLabel setTextColor:[UIColor colorWithRed:57.0/255.0 green:65.0/255.0 blue:92.0/255.0 alpha:1]];
//    [uploadFinshLabel setTextAlignment:NSTextAlignmentCenter];
//    [self.view addSubview:uploadFinshLabel];
//    
//    [self showUploadingView:YES];
//    [self showUploadFinshView:YES];
//    [self showStartUploadView:NO];
    //准备选择文件上传
    connection = nil;
    isStop = TRUE;
    photoArray = [[NSMutableArray alloc] init];
    
    photoManger = [[SCBPhotoManager alloc] init];
    [photoManger setNewFoldDelegate:self];
    isLookLibray = TRUE;
    [self uploadListShow];
    [super viewDidLoad];
}

-(void)uploadListShow
{
    if(self.uploadListTableView == nil)
    {
        CGRect rect = CGRectMake(0, 44, 320, TableViewHeight);
        self.uploadListTableView = [[UITableView alloc] initWithFrame:rect];
        [self.uploadListTableView setDataSource:self];
        [self.uploadListTableView setDelegate:self];
        self.uploadListTableView.showsVerticalScrollIndicator = NO;
        self.uploadListTableView.alwaysBounceVertical = YES;
        self.uploadListTableView.alwaysBounceHorizontal = NO;
        [self.view addSubview:self.uploadListTableView];
    }
}

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
    TaskDemo *demo = [[TaskDemo alloc] init];
    [photoArray removeAllObjects];
    photoArray = [demo selectAllTaskTable];
    [self.uploadListTableView reloadData];
    [demo release];
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
    TaskDemo *demo = [[TaskDemo alloc] init];
    [photoArray removeAllObjects];
    if(historyArray)
    {
        [historyArray release];
    }
    else
    {
        historyArray = [[NSMutableArray alloc] init];
    }
    historyArray = [demo selectFinishTaskTable];
    [self.uploadListTableView reloadData];
    [demo release];
}

-(void)clicked_more:(id)sender
{
    
}


-(void)stopWiFi
{
    if(netWorkState==2)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(uploderDemo)
            {
                [uploderDemo setUpLoadDelegate:nil];
                [uploderDemo release];
                uploderDemo = nil;
            }
            isWlanUpload = FALSE;
            isAlert = TRUE;
            
            isConnection = FALSE;
            
            [self showUploadingView:NO];
            [unWifiOrNetWorkImageView setImage:[UIImage imageNamed:@"Updata_ErrWifi.png"]];
            [unWifiOrNetWorkImageView setHidden:NO];
            [uploadImageView setHidden:YES];
            [uploadProgressView setHidden:YES];
            [uploadFinshPageLabel setHidden:NO];
            [uploadFinshPageLabel setText:@"或者你可以去设置关闭”仅在Wi-Fi下上传/下载“"];
            
            uploadFinshPageLabel.numberOfLines=0;
            CGSize size = [uploadFinshPageLabel sizeThatFits:CGSizeMake(uploadFinshPageLabel.frame.size.width-20, 0)];//假定label_1设置的固定宽度为100，自适应高
            [uploadFinshPageLabel.text sizeWithFont:uploadFinshPageLabel.font
                                  constrainedToSize:size
                                      lineBreakMode:UILineBreakModeWordWrap];  //这句加上才能自适应
            NSLog(@"字符在宽度不变，自适应高：%f",size.height);
            CGRect rct = uploadFinshPageLabel.frame;
            rct.size.height=size.height;
            uploadFinshPageLabel.frame = rct;
            [currFileNameLabel setText:@"等待Wi-Fi上传"];
            
            uploadNumber = 0;
            [photoArray removeAllObjects];
            [self.uploadListTableView reloadData];
            isConnection = FALSE;
            if(connectionTimer==nil && !isStop)
            {
                connectionTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(isUPloadImage) userInfo:nil repeats:YES];
            }
        });
    }
}

-(void)stopAllDo
{
    if(uploderDemo)
    {
        [uploderDemo setUpLoadDelegate:nil];
        [uploderDemo release];
        uploderDemo = nil;
    }
    isSelected = FALSE;
    isStop = YES;
    [photoArray removeAllObjects];
    [self.uploadListTableView reloadData];
    uploadNumber = 0;
    if(connectionTimer)
    {
        [connectionTimer invalidate];
        connectionTimer = nil;
    }
    if(libaryTimer)
    {
        [libaryTimer invalidate];
        libaryTimer = nil;
    }
    [self showStartUploadView:NO];
    [uploadWaitButton setTitle:@"开启" forState:UIControlStateNormal];
}

-(void)startSouStart
{
    isOpenLibray = TRUE;
    if(isStop)
    {
        if (![YNFunctions isOnlyWifi] && !isUpload) {
            [self stopAllDo];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"这可能会产生流量费用，您是否要继续？"
                                                               delegate:self
                                                      cancelButtonTitle:@"取消"
                                                      otherButtonTitles:@"继续", nil];
            [alertView show];
            [alertView release];
        }
        else
        {
            isStop = NO;
            isSelected = TRUE;
            if(isLookLibray && !isNeedChangeUpload)
            {
                isLookLibray = FALSE;
                [self getPhotoLibrary];
            }
            isConnection = FALSE;
            [uploadWaitButton setTitle:@"加载中..." forState:UIControlStateNormal];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"isAutoUpload"];
            });
            
            if(!connectionTimer)
            {
                if(isNeedChangeUpload)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self isUPloadImage];
                    });
                }
                connectionTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(isUPloadImage) userInfo:nil repeats:YES];
            }
        }
        isUpload = FALSE;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 获取照片库信息
-(void)getPhotoLibrary
{
    //    isGetLibary ＝ YES;
    NSLog(@"判断照片库是否更新");
    if(libaryTimer)
    {
        [libaryTimer invalidate];
        libaryTimer = nil;
    }
    
    if(isGetLibary)
    {
        return;
    }
    isGetLibary = TRUE;
    NSLog(@"查询图片");
    if(isStop)
    {
        isLookLibray = TRUE;
        [self stopAllDo];
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc]init];//生成整个photolibrary句柄的实例
        //    NSMutableArray *mediaArray = [[NSMutableArray alloc]init];//存放media的数组
        __block BOOL first = TRUE;
        __block int groupIndex = 0;
        isOnce = FALSE;
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {//获取所有group
            if(isStop)
            {
                isLookLibray = TRUE;
                return ;
            }
            if(first)
            {
                first = FALSE;
                __block BOOL isLoad = FALSE;
                int groupCount = group.numberOfAssets;
                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if(isStop)
                    {
                        isLookLibray = TRUE;
                        return ;
                    }
                    //从group里面
                    groupIndex++;
                    NSString* assetType = [result valueForProperty:ALAssetPropertyType];
                    if ([assetType isEqualToString:ALAssetTypePhoto]) {
                        TaskDemo *demo = [[TaskDemo alloc] init];
                        demo.f_state = 0;
                        demo.f_data = nil;
                        demo.f_lenght = 0;
                        //获取照片名称
                        demo.f_base_name = [[result defaultRepresentation] filename];
                        demo.result = [result retain];
                        BOOL bl;
                        
                        NSLog(@"isOnce:%i",isOnce);
                        
                        if(!isOnce)
                        {
                            bl = [demo isPhotoExist];
                            NSLog(@"1:%i",bl);
                        }
                        else
                        {
                            bl = [demo isExistOneImage];
                            NSLog(@"2:%i",bl);
                        }
                        if(!bl)
                        {
                            bl = [demo isExistOneImage];
                            NSLog(@"3:%i",bl);
                            if(!bl)
                            {
                                [demo insertTaskTable];
                                NSLog(@"4:%i",bl);
                            }
                            [photoArray addObject:demo];
                            isLoad = TRUE;
                        }
                        [demo release];
                    }
                    NSLog(@"groupIndex++:%i",groupIndex);
                }];
                isOnce = TRUE;
                isGetLibary = FALSE;
                if(isLoad)
                {
                    if(uploadNumber<[photoArray count] && !isStop)
                    {
                        if(connectionTimer == nil && !isConnection)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self isUPloadImage];
                                connectionTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(isUPloadImage) userInfo:nil repeats:YES];
                            });
                        }
                    }
                }
                NSLog(@"groupCount：%i",groupCount);
                if(groupCount <= groupIndex-1 || groupCount==0)
                {
                    isLookLibray = TRUE;
                    NSLog(@"groupIndex：%i",groupCount);
                    if([photoArray count] == 0 && !isNeedChangeUpload)
                    {
                        NSLog(@"照片库扫瞄完成");
                        [self showUploadFinshView:NO];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(!libaryTimer)
                            {
                                NSLog(@"计时器开启");
                                libaryTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(getPhotoLibrary) userInfo:nil repeats:YES];
                            }
                        });
                    }
                }
            }
            
        } failureBlock:^(NSError *error) {
            if(isOpenLibray)
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self stopAllDo];
                    NSLog(@"[[UIDevice currentDevice] systemVersion]:%@",[[UIDevice currentDevice] systemVersion]);
                    
                    NSString *titleString;
                    if([[[UIDevice currentDevice] systemVersion] intValue]>=6.0)
                    {
                        titleString = @"因iOS系统限制，开启照片服务才能上传，传输过程严格加密，不会作其他用途。\n\n\t步骤：设置>隐私>照片>虹盘";
                    }
                    else
                    {
                        titleString = @"因iOS系统限制，开启照片服务才能上传，传输过程严格加密，不会作其他用途。\n\n\t\t步骤：设置>定位服务>虹盘";
                    }
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:titleString delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
                    [alertView show];
                    [alertView release];
                    isOpenLibray = FALSE;
                });
            }
        }];
    });
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    NSLog(@"lll:%@",editingInfo);
    imageV = image;
    [[picker parentViewController] dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"11111：%@",info);
    [picker dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
}

#pragma mark 创建上传集合
-(void)createUploadArray
{
    
}

-(BOOL)isUPloadImage
{
    __block BOOL bl = FALSE;
    if(isStop)
    {
        [self stopAllDo];
        return bl;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSLog(@"检测网络");
        NSString *switchFlag = [[NSUserDefaults standardUserDefaults] objectForKey:@"switch_flag"];
        if([switchFlag boolValue] || !switchFlag)
        {
            //wifi
            if([[self GetCurrntNet] isEqualToString:@"WIFI"])
            {
                netWorkState = 1;
                isWlanUpload = FALSE;
                isAlert = TRUE;
                if([photoArray count]==0 && isLookLibray && !isNeedChangeUpload)
                {
                    [self getPhotoLibrary];
                }
                if(!isConnection && uploadNumber<[photoArray count])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        isConnection = TRUE;
                        if(connectionTimer)
                        {
                            [connectionTimer invalidate];
                            connectionTimer = nil;
                        }
                        [self upLoad];
                    });
                }
                bl = TRUE;
            }
            else if([[self GetCurrntNet] isEqualToString:@"WLAN"])
            {
                netWorkState = 2;
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    isWlanUpload = FALSE;
                    isAlert = TRUE;
                    
                    isConnection = FALSE;
                    bl = FALSE;
                    
                    [self showUploadingView:NO];
                    [unWifiOrNetWorkImageView setImage:[UIImage imageNamed:@"Updata_ErrWifi.png"]];
                    [unWifiOrNetWorkImageView setHidden:NO];
                    [uploadImageView setHidden:YES];
                    [uploadProgressView setHidden:YES];
                    [uploadFinshPageLabel setHidden:NO];
                    [uploadFinshPageLabel setText:@"或者你可以去设置关闭”仅在Wi-Fi下上传/下载“"];
                    
                    uploadFinshPageLabel.numberOfLines=0;
                    CGSize size = [uploadFinshPageLabel sizeThatFits:CGSizeMake(uploadFinshPageLabel.frame.size.width-20, 0)];//假定label_1设置的固定宽度为100，自适应高
                    [uploadFinshPageLabel.text sizeWithFont:uploadFinshPageLabel.font
                                          constrainedToSize:size
                                              lineBreakMode:UILineBreakModeWordWrap];  //这句加上才能自适应
                    NSLog(@"字符在宽度不变，自适应高：%f",size.height);
                    CGRect rct = uploadFinshPageLabel.frame;
                    rct.size.height=size.height;
                    uploadFinshPageLabel.frame = rct;
                    [currFileNameLabel setText:@"等待Wi-Fi上传"];
                    
                    uploadNumber = 0;
                    [photoArray removeAllObjects];
                    [self.uploadListTableView reloadData];
                    isConnection = FALSE;
                    if(connectionTimer==nil && !isStop)
                    {
                        connectionTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(isUPloadImage) userInfo:nil repeats:YES];
                    }
                });
            }
            else if([[self GetCurrntNet] isEqualToString:@"没有网络链接"])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    netWorkState = 3;
                    isWlanUpload = FALSE;
                    isAlert = TRUE;
                    [self showUploadingView:NO];
                    [unWifiOrNetWorkImageView setImage:[UIImage imageNamed:@"Updata_ErrInternet.png"]];
                    [unWifiOrNetWorkImageView setHidden:NO];
                    [uploadImageView setHidden:YES];
                    [uploadProgressView setHidden:YES];
                    [uploadFinshPageLabel setHidden:YES];
                    [currFileNameLabel setText:@"无法连接Internet，请检查网络"];
                    isUpload = FALSE;
                    bl = FALSE;
                    uploadNumber = 0;
                    [photoArray removeAllObjects];
                    [self.uploadListTableView reloadData];
                    isConnection = FALSE;
                    if(connectionTimer==nil && !isStop)
                    {
                        connectionTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(isUPloadImage) userInfo:nil repeats:YES];
                    }
                });
            }
        }
        else
        {
            //非仅wifi
            if([[self GetCurrntNet] isEqualToString:@"WIFI"])
            {
                netWorkState = 1;
                isWlanUpload = FALSE;
                isAlert = TRUE;
                if([photoArray count]==0 && isLookLibray && !isNeedChangeUpload)
                {
                    [self getPhotoLibrary];
                }
                if(!isConnection && uploadNumber<[photoArray count])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        isConnection = TRUE;
                        if(connectionTimer)
                        {
                            [connectionTimer invalidate];
                            connectionTimer = nil;
                        }
                        [self upLoad];
                    });
                }
                bl = TRUE;
            }
            else if([[self GetCurrntNet] isEqualToString:@"WLAN"])
            {
                netWorkState = 2;
                if([photoArray count]==0 && isLookLibray && !isNeedChangeUpload)
                {
                    [self getPhotoLibrary];
                }
                if(!isConnection && uploadNumber<[photoArray count])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        isConnection = TRUE;
                        if(connectionTimer)
                        {
                            [connectionTimer invalidate];
                            connectionTimer = nil;
                        }
                        [self upLoad];
                    });
                }
            }
            else if([[self GetCurrntNet] isEqualToString:@"没有网络链接"])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    netWorkState = 3;
                    isWlanUpload = FALSE;
                    isAlert = TRUE;
                    [self showUploadingView:NO];
                    [unWifiOrNetWorkImageView setImage:[UIImage imageNamed:@"Updata_ErrInternet.png"]];
                    [unWifiOrNetWorkImageView setHidden:NO];
                    [uploadImageView setHidden:YES];
                    [uploadProgressView setHidden:YES];
                    [uploadFinshPageLabel setHidden:YES];
                    [currFileNameLabel setText:@"无法连接Internet，请检查网络"];
                    uploadFinshPageLabel.numberOfLines=0;
                    CGSize size = [uploadFinshPageLabel sizeThatFits:CGSizeMake(uploadFinshPageLabel.frame.size.width-20, 0)];//假定label_1设置的固定宽度为100，自适应高
                    [uploadFinshPageLabel.text sizeWithFont:uploadFinshPageLabel.font
                                          constrainedToSize:size
                                              lineBreakMode:UILineBreakModeWordWrap];  //这句加上才能自适应
                    NSLog(@"字符在宽度不变，自适应高：%f",size.height);
                    CGRect rct = uploadFinshPageLabel.frame;
                    rct.size.height=size.height;
                    uploadFinshPageLabel.frame = rct;
                    isUpload = FALSE;
                    bl = FALSE;
                    uploadNumber = 0;
                    [photoArray removeAllObjects];
                    [self.uploadListTableView reloadData];
                    isConnection = FALSE;
                    if(connectionTimer==nil && !isStop)
                    {
                        connectionTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(isUPloadImage) userInfo:nil repeats:YES];
                    }
                });
            }
        }
        
    });
    return bl;
}

#pragma mark 判断上传
-(void)updateTypeClick:(id)sender
{
    NSLog(@"个数：%i",[photoArray count]);
    UIButton *button = sender;
    if(isSelected)
    {
        isSelected = FALSE;
        isStop = YES;
        [photoArray removeAllObjects];
        [self.uploadListTableView reloadData];
        uploadNumber = 0;
        if(connectionTimer)
        {
            [connectionTimer invalidate];
            connectionTimer = nil;
        }
        if(libaryTimer)
        {
            [libaryTimer invalidate];
            libaryTimer = nil;
        }
    }
    else
    {
        [button setBackgroundImage:[UIImage imageNamed:@"upload_btn_unlock.png"] forState:UIControlStateNormal];
        isStop = NO;
        isSelected = TRUE;
        [self getPhotoLibrary];
        isConnection = FALSE;
        dispatch_async(dispatch_get_main_queue(), ^{
            connectionTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(isUPloadImage) userInfo:nil repeats:YES];
            libaryTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(getPhotoLibrary) userInfo:nil repeats:YES];
        });
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    //    if(buttonIndex == 0)
    //    {
    //        isWlanUpload = FALSE;
    //        AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //        [app_delegate.myTabBarController setSelectedIndex:4];
    //    }
    if(buttonIndex == 1)
    {
        isStop = NO;
        isSelected = TRUE;
        if(!isNeedChangeUpload)
        {
            [self getPhotoLibrary];
        }
        isConnection = FALSE;
        [uploadWaitButton setTitle:@"加载中..." forState:UIControlStateNormal];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"isAutoUpload"];
        });
        dispatch_async(dispatch_get_main_queue(), ^{
            if(!connectionTimer)
            {
                connectionTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(isUPloadImage) userInfo:nil repeats:YES];
            }
            if(!libaryTimer && !isNeedChangeUpload)
            {
                libaryTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(getPhotoLibrary) userInfo:nil repeats:YES];
            }
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"isAutoUpload"];
        });
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    //上传使用
    QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsMultipleSelection = YES;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
    [navigationController setNavigationBarHidden:YES];
    [self presentModalViewController:navigationController animated:YES];
    [imagePickerController release];
    [navigationController release];
    return;
    baseBL = TRUE;
    if([[SCBSession sharedSession] userId] != user_id || [[SCBSession sharedSession] userToken] != user_token)
    {
        [uploadTypeButton setBackgroundImage:[UIImage imageNamed:@"upload_btn_lock.png"] forState:UIControlStateNormal];
        isSelected = FALSE;
        if(libaryTimer)
        {
            [libaryTimer invalidate];
            libaryTimer = nil;
        }
        if(connectionTimer)
        {
            [connectionTimer invalidate];
            connectionTimer = nil;
        }
        uploadNumber = 0;
        isStop = YES;
        [photoArray removeAllObjects];
        [self.uploadListTableView reloadData];
        user_id = [[SCBSession sharedSession] userId];
        user_token = [[SCBSession sharedSession] userToken];
    }
    if([YNFunctions isAutoUpload] && isStop)
    {
        [self startSouStart];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    baseBL = FALSE;
}

#pragma mark 上传校验
-(void)upLoad
{
    AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(app_delegate.isUnUpload)
    {
        [app_delegate setIsUnUpload:NO];
        [uploadTypeButton setBackgroundImage:[UIImage imageNamed:@"upload_btn_lock.png"] forState:UIControlStateNormal];
        isSelected = FALSE;
        if(libaryTimer)
        {
            [libaryTimer invalidate];
            libaryTimer = nil;
        }
        if(connectionTimer)
        {
            [connectionTimer invalidate];
            connectionTimer = nil;
        }
        uploadNumber = 0;
        isStop = YES;
        [photoArray removeAllObjects];
        [self.uploadListTableView reloadData];
        return;
    }
    
    NSLog(@"开始请求");
    NSLog(@"------------------uploadNumber:%i;[photoArray count]:%i",uploadNumber,[photoArray count]);
    f_pid = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        if(uploadNumber < [photoArray count])
        {
            TaskDemo *demo = [photoArray objectAtIndex:uploadNumber];
            if(demo.f_data == nil)
            {
                ALAsset *result = demo.result;
                NSError *error = nil;
                Byte *data = malloc(result.defaultRepresentation.size);
                
                //获得照片图像数据
                [result.defaultRepresentation getBytes:data fromOffset:0 length:result.defaultRepresentation.size error:&error];
                demo.f_data = [NSData dataWithBytesNoCopy:data length:result.defaultRepresentation.size];
                
            }
            
            if([demo.f_data length]==0)
            {
                if(uploadNumber<[photoArray count])
                {
                    TaskDemo *demo = [photoArray objectAtIndex:uploadNumber];
                    demo.f_state = 1;
                    demo.f_lenght = [demo.f_data length];
                    [demo updateTaskTableFName];
                    [photoArray removeObjectAtIndex:0];
                    [self.uploadListTableView reloadData];
                }
                if(!isStop && uploadNumber<[photoArray count])
                {
                    isConnection = FALSE;
                    [self isUPloadImage];
                }
                else if(!isStop && uploadNumber >= [photoArray count])
                {
                    [self showUploadFinshView:NO];
                    [photoArray removeAllObjects];
                    [self.uploadListTableView reloadData];
                    uploadNumber = 0;
                    isConnection = FALSE;
                    if(!libaryTimer && [photoArray count] == 0 && !isNeedChangeUpload)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            libaryTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(getPhotoLibrary) userInfo:nil repeats:YES];
                        });
                    }
                }
                return ;
            }

            
            [self showUploadingView:NO];
            UIImage *imageB = [UIImage imageWithData:demo.f_data];
            CGSize imageSize = imageB.size;
            float width = uploadProgressView.frame.size.width;
            if(imageSize.width>width)
            {
                imageSize = CGSizeMake(width, width*imageSize.height/imageSize.width);
            }
            float height = uploadProgressView.frame.origin.y-40;
            if(imageSize.height>height)
            {
                imageSize = CGSizeMake(height*imageSize.width/imageSize.height, height);
            }
            CGRect uploadImageRect = uploadImageView.frame;
            uploadImageRect.size = imageSize;
            uploadImageRect.origin.x = (320-imageSize.width)/2;
            uploadImageRect.origin.y = (uploadProgressView.frame.origin.y-imageSize.height)/2;
            [uploadImageView setFrame:uploadImageRect];
            [uploadImageView.boderImageView performSelectorOnMainThread:@selector(setImage:) withObject:[UIImage imageWithData:demo.f_data] waitUntilDone:YES];
            
            [uploadProgressView setProgress:0];
            [currFileNameLabel setText:[NSString stringWithFormat:@"正在上传 %@",demo.f_base_name]];
            [uploadFinshPageLabel setText:[NSString stringWithFormat:@"剩下 %i",[photoArray count]]];
            [uploadWaitButton setTitle:@"开启" forState:UIControlStateNormal];
            [self showUploadingView:NO];
        }
        else
        {
            NSLog(@"突然停止");
        }
        
    });
    if(uploadNumber >= [photoArray count])
    {
        [uploadNumberLabel setText:@"已完成"];
    }
    else
    {
        //判断文件是否存在
        NSLog(@"1:打开文件目录");
        [photoManger openFinderWithID:@"1"];
    }
}

//判断当前的网络是3g还是wifi
-(NSString*) GetCurrntNet
{
    NSString *connectionKind;
    Reachability *hostReach = [Reachability reachabilityWithHostName:@"www.google.com"];
    switch ([hostReach currentReachabilityStatus]) {
        case NotReachable:
        {
            connectionKind = @"没有网络链接";
        }
            break;
        case ReachableViaWiFi:
        {
            connectionKind = @"WIFI";
        }
            break;
        case ReachableViaWWAN:
        {
            connectionKind = @"WLAN";
        }
            break;
        default:
            break;
    }
    return connectionKind;
}



-(void)newFold:(NSDictionary *)dictionary
{
    NSLog(@"newFold dictionary:%@",dictionary);
    BOOL bl = FALSE;
    if(!isStop && uploadNumber<[photoArray count])
    {
        if(f_pid > 0)
        {
            bl = TRUE;
        }
        if([[dictionary objectForKey:@"code"] intValue] == 0)
        {
            if(f_pid > 0)
            {
                f_id = [[dictionary objectForKey:@"f_id"] intValue];
                [self requestVerify];
            }
            else
            {
                f_pid = [[dictionary objectForKey:@"f_id"] intValue];
                [photoManger requestNewFold:deviceName FID:f_pid];
            }
        }
        else
        {
            if(bl && f_pid > 0)
            {
                [photoManger requestNewFold:deviceName FID:f_pid];
            }
            if(f_pid==0)
            {
                [photoManger requestNewFold:@"手机照片" FID:1];
            }
        }
    }
}

-(void)openFile:(NSDictionary *)dictionary
{
    NSLog(@"打开成功 dictionary:%@ deviceName:%@",dictionary,deviceName);
    BOOL bl = FALSE;
    if([[dictionary objectForKey:@"code"] intValue] == 0 && !isStop && uploadNumber<[photoArray count])
    {
        if(f_pid>0)
        {
            bl = TRUE;
        }
        NSArray *array = [dictionary objectForKey:@"files"];
        for(int i=0;i<[array count];i++)
        {
            NSString *f_name = [[array objectAtIndex:i] objectForKey:@"f_name"];
            if([f_name isEqualToString:@"手机照片"])
            {
                f_pid = [[[array objectAtIndex:i] objectForKey:@"f_id"] intValue];
                [photoManger openFinderWithID:[NSString stringWithFormat:@"%i",f_pid]];
                break;
            }
            if([f_name isEqualToString:deviceName])
            {
                f_id = [[[array objectAtIndex:i] objectForKey:@"f_id"] intValue];
                [self requestVerify];
            }
        }
        if(f_pid==0)
        {
            [photoManger requestNewFold:@"手机照片" FID:1];
        }
        if(f_pid>0 && f_id==0 && bl)
        {
            [photoManger requestNewFold:deviceName FID:f_pid];
        }
    }
}

-(void)requestVerify
{
    if(!isStop && uploadNumber<[photoArray count])
    {
        TaskDemo *demo = [photoArray objectAtIndex:uploadNumber];
        SCBUploader *uploder = [[[SCBUploader alloc] init] autorelease];
        [uploder setUpLoadDelegate:self];
        NSLog(@"1:申请效验");
        if(demo.f_data == nil)
        {
            ALAsset *result = demo.result;
            NSError *error = nil;
            Byte *data = malloc(result.defaultRepresentation.size);
            //获得照片图像数据
            [result.defaultRepresentation getBytes:data fromOffset:0 length:result.defaultRepresentation.size error:&error];
            demo.f_data = [NSData dataWithBytesNoCopy:data length:result.defaultRepresentation.size];
        }
        NSLog(@"demo.f_data:%i",[demo.f_data length]);
        uploadData = [[NSString alloc] initWithString:[self md5:demo.f_data]];
        [uploder requestUploadVerify:f_id f_name:demo.f_base_name f_size:[NSString stringWithFormat:@"%i",[demo.f_data length]] f_md5:uploadData];
    }
    else if(!isStop && uploadNumber >= [photoArray count])
    {
        [self showUploadFinshView:NO];
        [photoArray removeAllObjects];
        [self.uploadListTableView reloadData];
        uploadNumber = 0;
    }
}

#pragma mark 上传代理

-(void)uploadVerify:(NSDictionary *)dictionary
{
    NSLog(@"upload:%@",dictionary);
    if(!isStop && uploadNumber<[photoArray count])
    {
        if([[dictionary objectForKey:@"code"] intValue] == 0 )
        {
            TaskDemo *demo = [photoArray objectAtIndex:uploadNumber];
            SCBUploader *uploder = [[[SCBUploader alloc] init] autorelease];
            [uploder setUpLoadDelegate:self];
            NSLog(@"2:申请效验");
            [uploder requestUploadState:demo.f_base_name];
        }
        else if([[dictionary objectForKey:@"code"] intValue] == 5 )
        {
            [uploadData release];
            TaskDemo *demo = [photoArray objectAtIndex:uploadNumber];
            demo.f_state = 1;
            demo.f_lenght = [demo.f_data length];
            [demo updateTaskTableFName];
            UploadViewCell *cell = (UploadViewCell *)[self.uploadListTableView viewWithTag:UploadProessTag+demo.f_id];
            if([cell isKindOfClass:[UploadViewCell class]])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell.jinDuView setCurrFloat:1];
                });
            }
            [photoArray removeObjectAtIndex:0];
            [self.uploadListTableView reloadData];
            
//            [uploadProgressView setProgress:1];
            [currFileNameLabel setText:[NSString stringWithFormat:@"正在上传 %@",demo.f_base_name]];
            [uploadFinshPageLabel setText:[NSString stringWithFormat:@"剩下 %i",[photoArray count]]];
            if(!isStop && uploadNumber<[photoArray count])
            {
                isConnection = FALSE;
                [self isUPloadImage];
            }
            else if(!isStop && uploadNumber >= [photoArray count])
            {
                [self showUploadFinshView:NO];
                
                [photoArray removeAllObjects];
                [self.uploadListTableView reloadData];
                uploadNumber = 0;
                isConnection = FALSE;
                if(!libaryTimer && [photoArray count] == 0 && !isNeedChangeUpload)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        libaryTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(getPhotoLibrary) userInfo:nil repeats:YES];
                    });
                }
            }
        }
    }
}

-(void)uploadFinish:(NSDictionary *)dictionary
{
    if(connection)
    {
        connection = nil;
    }
    AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(app_delegate.isUnUpload)
    {
        [app_delegate setIsUnUpload:NO];
        [uploadTypeButton setBackgroundImage:[UIImage imageNamed:@"upload_btn_lock.png"] forState:UIControlStateNormal];
        isSelected = FALSE;
        if(libaryTimer)
        {
            [libaryTimer invalidate];
            libaryTimer = nil;
        }
        if(connectionTimer)
        {
            [connectionTimer invalidate];
            connectionTimer = nil;
        }
        
        uploadNumber = 0;
        isStop = YES;
        [photoArray removeAllObjects];
        [self.uploadListTableView reloadData];
    }
    
    NSLog(@"uploadFinishdictionary:%@",dictionary);
    if(!isStop && uploadNumber<[photoArray count])
    {
        if([[dictionary objectForKey:@"code"] intValue] == 0)
        {
            
//            [uploadProgressView setProgress:1 animated:YES];
            TaskDemo *demo = [photoArray objectAtIndex:uploadNumber];
            UploadViewCell *cell = (UploadViewCell *)[uploadListTableView viewWithTag:UploadProessTag+demo.f_id];
            if([cell isKindOfClass:[UploadViewCell class]])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell.jinDuView setCurrFloat:1];
                });
            }
            SCBUploader *uploder = [[[SCBUploader alloc] init] autorelease];
            [uploder setUpLoadDelegate:self];
            NSLog(@"4:提交上传表单:%@",finishName);
            [uploder requestUploadCommit:[NSString stringWithFormat:@"%i",f_id] f_name:demo.f_base_name s_name:finishName device:@"" skip:@"" f_md5:uploadData img_createtime:@""];
        }
        else
        {
            NSLog(@"3:重新上传");
            isConnection = FALSE;
            [self isUPloadImage];
        }
    }
}

-(void)requestUploadState:(NSDictionary *)dictionary
{
    NSLog(@"dictionary:%@",dictionary);
    if(!isStop && [[dictionary objectForKey:@"code"] intValue] == 0 && uploadNumber < [photoArray count])
    {
        TaskDemo *demo = [photoArray objectAtIndex:uploadNumber];
        if(uploderDemo)
        {
            [uploderDemo setUpLoadDelegate:nil];
            [uploderDemo release];
            uploderDemo = nil;
        }
        uploderDemo = [[SCBUploader alloc] init];
        [uploderDemo setUpLoadDelegate:self];
        finishName = [dictionary objectForKey:@"sname"];
        NSLog(@"3:开始上传：%@",finishName);
        if(demo.f_data == nil)
        {
            ALAsset *result = demo.result;
            NSError *error = nil;
            Byte *data = malloc(result.defaultRepresentation.size);
            //获得照片图像数据
            [result.defaultRepresentation getBytes:data fromOffset:0 length:result.defaultRepresentation.size error:&error];
            demo.f_data = [NSData dataWithBytesNoCopy:data length:result.defaultRepresentation.size];
        }
        NSLog(@"demo.f_data:%i",[demo.f_data length]);
        if([demo.f_data length]==0)
        {
            if(uploadNumber<[photoArray count])
            {
                TaskDemo *demo = [photoArray objectAtIndex:uploadNumber];
                demo.f_state = 1;
                demo.f_lenght = [demo.f_data length];
                [demo updateTaskTableFName];
                [photoArray removeObjectAtIndex:0];
                [self.uploadListTableView reloadData];
            }
            if(!isStop && uploadNumber<[photoArray count])
            {
                [uploadData release];
                isConnection = FALSE;
                [self isUPloadImage];
            }
            else if(!isStop && uploadNumber >= [photoArray count])
            {
                [self showUploadFinshView:NO];
                [photoArray removeAllObjects];
                [self.uploadListTableView reloadData];
                uploadNumber = 0;
                isConnection = FALSE;
                if(!libaryTimer && [photoArray count] == 0 && !isNeedChangeUpload)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        libaryTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(getPhotoLibrary) userInfo:nil repeats:YES];
                    });
                }
            }
        }
        else
        {
            connection = [uploderDemo requestUploadFile:[NSString stringWithFormat:@"%i",f_pid] f_name:demo.f_base_name s_name:finishName skip:[NSString stringWithFormat:@"%i",[demo f_lenght]] f_md5:[self md5:demo.f_data] Image:demo.f_data];
        }
    }
}

-(void)uploadCommit:(NSDictionary *)dictionary
{
    NSLog(@"dictionary:%@",dictionary);
    NSLog(@"5:完成");
    AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(app_delegate.isUnUpload)
    {
        [app_delegate setIsUnUpload:NO];
        [uploadTypeButton setBackgroundImage:[UIImage imageNamed:@"upload_btn_lock.png"] forState:UIControlStateNormal];
        isSelected = FALSE;
        if(libaryTimer)
        {
            [libaryTimer invalidate];
            libaryTimer = nil;
        }
        if(connectionTimer)
        {
            [connectionTimer invalidate];
            connectionTimer = nil;
        }
        uploadNumber = 0;
        isStop = YES;
        [photoArray removeAllObjects];
        [self.uploadListTableView reloadData];
    }
    
    if(!isStop && ([[dictionary objectForKey:@"code"] intValue] == 0 || [[dictionary objectForKey:@"code"] intValue] == 5) && uploadNumber < [photoArray count])
    {
        NSInteger fid = [[dictionary objectForKey:@"fid"] intValue];
        TaskDemo *demo = [photoArray objectAtIndex:uploadNumber];
//        [currFileNameLabel setText:[NSString stringWithFormat:@"正在上传 %@",demo.f_base_name]];
//        [uploadFinshPageLabel setText:[NSString stringWithFormat:@"剩下 %i",[photoArray count]]];
//        [NSThread sleepForTimeInterval:1.0];
        
        demo.f_id = fid;
        demo.f_state = 1;
        demo.f_lenght = [demo.f_data length];
        [demo updateTaskTableFName];
        
        [photoArray removeObjectAtIndex:0];
        [self.uploadListTableView reloadData];
    }
    
    NSLog(@"uploadNumber:%i;[photoArray count]:%i",uploadNumber,[photoArray count]);
    if(!isStop && uploadNumber<[photoArray count])
    {
        [uploadData release];
        isConnection = FALSE;
        [self isUPloadImage];
    }
    else if(!isStop && uploadNumber >= [photoArray count])
    {
        [self showUploadFinshView:NO];
        [photoArray removeAllObjects];
        [self.uploadListTableView reloadData];
        uploadNumber = 0;
        isConnection = FALSE;
        if(!libaryTimer && [photoArray count] == 0 && !isNeedChangeUpload)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                libaryTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(getPhotoLibrary) userInfo:nil repeats:YES];
            });
        }
    }
}

-(void)didFailWithError
{
    NSLog(@"网络连接失败");
    if(uploderDemo)
    {
        [uploderDemo setUpLoadDelegate:nil];
        [uploderDemo release];
        uploderDemo = nil;
    }
    isUpload = FALSE;
    uploadNumber = 0;
    [photoArray removeAllObjects];
    [self.uploadListTableView reloadData];
    isConnection = FALSE;
    dispatch_async(dispatch_get_main_queue(), ^{
        if(connectionTimer==nil && !isStop)
        {
            connectionTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(isUPloadImage) userInfo:nil repeats:YES];
        }
        if(!libaryTimer && [photoArray count] == 0 && !isStop && !isNeedChangeUpload)
        {
            libaryTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(getPhotoLibrary) userInfo:nil repeats:YES];
        }
    });
}

-(void)uploadFiles:(int)proress
{
    TaskDemo *demo = [photoArray objectAtIndex:uploadNumber];
    float f = (float)proress / (float)[demo.f_data length];
    NSLog(@"UploadProessTag+demo.f_id:%i",UploadProessTag+demo.f_id);
    UploadViewCell *cell = (UploadViewCell *)[self.uploadListTableView viewWithTag:UploadProessTag+demo.f_id];
    if([cell isKindOfClass:[UploadViewCell class]])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell.jinDuView setCurrFloat:f];
        });
    }
//    [uploadProgressView setProgress:f animated:YES];
}


-(IBAction)checkPhoto:(id)sender
{
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self presentModalViewController:picker animated:YES];
}

- (void)viewDidUnload {
    [self setUploadNumberLabel:nil];
    [super viewDidUnload];
}

-(NSString *)md5:(NSData *)concat {
    CC_MD5_CTX md5_ctx;
    CC_MD5_Init(&md5_ctx);
    
    NSData* filedata = concat;
    CC_MD5_Update(&md5_ctx, [filedata bytes], [filedata length]);
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(result, &md5_ctx);
    NSMutableString *hash = [NSMutableString string];
    for(int i=0;i<CC_MD5_DIGEST_LENGTH;i++)
    {
        [hash appendFormat:@"%02x",result[i]];
    }
    return [hash lowercaseString];
}

//+(NSString*) md5:(NSString*) str
//{
//    const char *cStr = [str UTF8String];
//    unsigned char result[CC_MD5_DIGEST_LENGTH];
//    CC_MD5( cStr, strlen(cStr), result );
//
//    NSMutableString *hash = [NSMutableString string];
//    for(int i=0;i<CC_MD5_DIGEST_LENGTH;i++)
//    {
//        [hash appendFormat:@"%02X",result[i]];
//    }
//    return [hash lowercaseString];
//}

-(void)lookDescript:(NSDictionary *)dictionary
{
    
}

#pragma mark ------------------- 新UI设计
#pragma mark 准备上传界面
-(void)showStartUploadView:(BOOL)hidden
{
    [waitBackGround setHidden:hidden];
    [uploadWaitLabel setHidden:hidden];
    [uploadWaitButton setHidden:hidden];
    if(hidden)
    {
        
    }
    else
    {
        [self showUploadingView:YES];
        [self showUploadFinshView:YES];
        [unWifiOrNetWorkImageView setHidden:YES];
    }
}

#pragma mark 正在上传界面
-(void)showUploadingView:(BOOL)hidden
{
    [uploadImageView setHidden:hidden];
    [uploadProgressView setHidden:hidden];
    [currFileNameLabel setHidden:hidden];
    [uploadFinshPageLabel setHidden:hidden];
    [unWifiOrNetWorkImageView setHidden:!hidden];
    if(hidden)
    {
        
    }
    else
    {
        [self showStartUploadView:YES];
        [self showUploadFinshView:YES];
    }
}

#pragma mark 等待wifi中界面
-(void)showWaitWifiView:(BOOL)hidden
{
    if(hidden)
    {
        
    }
    else
    {
        
    }
}

#pragma mark 用户无网络界面
-(void)showUserNotNetworkView:(BOOL)hidden
{
    if(hidden)
    {
        
    }
    else
    {
        
    }
}

#pragma mark 6上传完成界面
-(void)showUploadFinshView:(BOOL)hidden
{
    [uploadFinshLabel setHidden:hidden];
    [uploadFinshImageView setHidden:hidden];
    if(hidden)
    {
        
    }
    else
    {
        [self showStartUploadView:YES];
        [self showUploadingView:YES];
        [unWifiOrNetWorkImageView setHidden:YES];
    }
}

#pragma mark --- QBImagePickerControllerDelegate

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
}

-(void)changeUpload:(NSMutableOrderedSet *)array_
{
    isNeedChangeUpload = YES;
    
    if(photoArray==nil)
    {
        photoArray = [[NSMutableArray alloc] init];
    }
    int i=0;
    for(ALAsset *asset in array_)
    {
        TaskDemo *demo = [[TaskDemo alloc] init];
        demo.f_state = 0;
        demo.f_data = nil;
        demo.f_lenght = 0;
        demo.f_id = i;
        i++;
        //获取照片名称
        demo.f_base_name = [[asset defaultRepresentation] filename];
        ALAsset *result = [asset retain];
        NSError *error = nil;
        Byte *data = malloc(result.defaultRepresentation.size);
        
        //获得照片图像数据
        [result.defaultRepresentation getBytes:data fromOffset:0 length:result.defaultRepresentation.size error:&error];
        demo.f_data = [NSData dataWithBytesNoCopy:data length:result.defaultRepresentation.size];
        [photoArray insertObject:demo atIndex:0];
        [demo insertTaskTable];
    }
    [self startSouStart];
    [self.uploadListTableView reloadData];
    NSLog(@"回到上传管理页面");
}

#pragma mark tableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    int count = 0;
    if(photoArray)
    {
        count = [photoArray count];
    }
    return [NSString stringWithFormat:@"正在上传(%i)",count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = 0;
    if(photoArray)
    {
        count = [photoArray count];
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
    if(photoArray)
    {
        TaskDemo *demo = [photoArray objectAtIndex:indexPath.row];
        [cell setTag:UploadProessTag+demo.f_id];
        NSLog(@"cellTag:%i",demo.f_data.length);
        [cell setUploadDemo:demo];
    }
    return cell;
}

@end

@implementation photoImage
@synthesize image,name;
@synthesize image_device,imageSize,img_createtime;

-(void)dealloc
{
    [name release];
    [name release];
    [image_device release];
    [imageSize release];
    [img_createtime release];
    [super dealloc];
}


@end
