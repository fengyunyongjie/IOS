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
    baseBL = TRUE;
    isAlert = TRUE;
    allHeight = self.view.frame.size.height - 49;
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
    deviceName = [AppDelegate deviceString];
    y = 40;
    if(![deviceName isEqualToString:@"iPhone 5"])
    {
        y = 0;
    }
    
    //准备上传界面
    //背景图
    CGRect waitBackRect = CGRectMake(0, y, 320, 222);
    waitBackGround = [[UIImageView alloc] initWithFrame:waitBackRect];
    [waitBackGround setImage:[UIImage imageNamed:@"背景图.png"]];
    [self.view addSubview:waitBackGround];
    
    CGRect waitLabelRect = CGRectMake(10, y+240, 300, 20);
    uploadWaitLabel = [[UILabel alloc] initWithFrame:waitLabelRect];
    [uploadWaitLabel setText:@"开启照片自动备份"];
    [uploadWaitLabel setFont:[UIFont systemFontOfSize:16]];
    [uploadWaitLabel setTextAlignment:NSTextAlignmentCenter];
    [uploadWaitLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:uploadWaitLabel];
    //上传按钮
    CGRect waitButtonRect = CGRectMake(89, y+290, 142, 33);
    uploadWaitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [uploadWaitButton setFrame:waitButtonRect];
    [uploadWaitButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [uploadWaitButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [uploadWaitButton setTitle:@"开启" forState:UIControlStateNormal];
    [uploadWaitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [uploadWaitButton setBackgroundImage:[UIImage imageNamed:@"Updata_Bt_Start.png"] forState:UIControlStateNormal];
    [uploadWaitButton addTarget:self action:@selector(startSouStart) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:uploadWaitButton];
    
    CGRect uploadImageRect = CGRectMake(90, y+20, 140, 210);
    uploadImageView = [[UIImageView alloc] initWithFrame:uploadImageRect];
    [self.view addSubview:uploadImageView];
    CGRect unWifiOrNetWorkImageRect = CGRectMake(61, y+106, 198, 107);
    unWifiOrNetWorkImageView = [[UIImageView alloc] initWithFrame:unWifiOrNetWorkImageRect];
    [self.view addSubview:unWifiOrNetWorkImageView];
    
    CGRect progressRect = CGRectMake(40, y+250, 240, 2);
    uploadProgressView = [[UIProgressView alloc] initWithFrame:progressRect];
    [self.view addSubview:uploadProgressView];
    CGRect currFileNameRect = CGRectMake(40, y+277, 240, 25);
    currFileNameLabel = [[UILabel alloc] initWithFrame:currFileNameRect];
    [currFileNameLabel setTextAlignment:NSTextAlignmentCenter];
    [currFileNameLabel setTextColor:[UIColor colorWithRed:57.0/255.0 green:65.0/255.0 blue:92.0/255.0 alpha:1]];
    [self.view addSubview:currFileNameLabel];
    CGRect uploadFinshPageRect = CGRectMake(40, y+317, 240, 20);
    uploadFinshPageLabel = [[UILabel alloc] initWithFrame:uploadFinshPageRect];
    [uploadFinshPageLabel setTextAlignment:NSTextAlignmentCenter];
    [uploadFinshPageLabel setFont:[UIFont systemFontOfSize:14]];
    [uploadFinshPageLabel setTextColor:[UIColor colorWithRed:148.0/255.0 green:156.0/255.0 blue:170.0/255.0 alpha:1]];
    [self.view addSubview:uploadFinshPageLabel];
    
    //上传完成界面
    CGRect uploadFinshImageRect = CGRectMake(0, y, 320, 222);
    uploadFinshImageView = [[UIImageView alloc] initWithFrame:uploadFinshImageRect];
    [uploadFinshImageView setImage:[UIImage imageNamed:@"Updata_Complite.png"]];
    [self.view addSubview:uploadFinshImageView];
    CGRect uploadFinshRect = CGRectMake(10, y+240, 300, 20);
    uploadFinshLabel = [[UILabel alloc] initWithFrame:uploadFinshRect];
    [uploadFinshLabel setText:@"现已全部完成，你的照片已上传到虹盘"];
    [uploadFinshLabel setTextColor:[UIColor colorWithRed:57.0/255.0 green:65.0/255.0 blue:92.0/255.0 alpha:1]];
    [uploadFinshLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:uploadFinshLabel];
    
    [self showUploadingView:YES];
    [self showUploadFinshView:YES];
    [self showStartUploadView:NO];
    connection = nil;
    isStop = TRUE;
    photoArray = [[NSMutableArray alloc] init];
    
    photoManger = [[SCBPhotoManager alloc] init];
    [photoManger setNewFoldDelegate:self];
    
    [super viewDidLoad];
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
            isOnce = FALSE;
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
    isOnce = FALSE;
    [photoArray removeAllObjects];
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
            [self getPhotoLibrary];
            isConnection = FALSE;
            [uploadWaitButton setTitle:@"加载中..." forState:UIControlStateNormal];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"isAutoUpload"];
            });
            
            if(!connectionTimer)
            {
                connectionTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(isUPloadImage) userInfo:nil repeats:YES];
            }
            if(!libaryTimer)
            {
                libaryTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(getPhotoLibrary) userInfo:nil repeats:YES];
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
    NSLog(@"判断照片库是否更新");
    if(isStop)
    {
        [self stopAllDo];
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc]init];//生成整个photolibrary句柄的实例
        //    NSMutableArray *mediaArray = [[NSMutableArray alloc]init];//存放media的数组
        __block BOOL first = TRUE;
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {//获取所有group
            if(first)
            {
                first = FALSE;
                __block BOOL isLoad = FALSE;
                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {//从group里面
                    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
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
                        if(!isOnce)
                        {
                            bl = [demo isPhotoExist];
                        }
                        else
                        {
                            bl = [demo isExistOneImage];
                        }
                        if(!bl)
                        {
                            bl = [demo isExistOneImage];
                            if(!bl)
                            {
                                [demo insertTaskTable];
                            }
                            [photoArray addObject:demo];
                            isLoad = TRUE;
                        }
                        [demo release];
                    }
                    [pool release];
                }];
                isOnce = TRUE;
                if(isLoad)
                {
                    if(uploadNumber<[photoArray count] && !isStop)
                    {
                        if(connectionTimer == nil)
                        {
                            isConnection = FALSE;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self isUPloadImage];
                                connectionTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(isUPloadImage) userInfo:nil repeats:YES];
                            });
                        }
                    }
                }
            }
            if([photoArray count]==0)
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self showUploadFinshView:NO];
                });
            }
        } failureBlock:^(NSError *error) {
            if(isOpenLibray)
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self stopAllDo];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"因iOS系统限制，开启照片服务才能上传，传输过程严格加密，不会作其他用途。\n\n\t步骤：设置>隐私>照片>虹盘" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
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
                    isOnce = FALSE;
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
                    isOnce = FALSE;
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
                    isOnce = FALSE;
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
        isOnce = FALSE;
        [photoArray removeAllObjects];
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
        connectionTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(isUPloadImage) userInfo:nil repeats:YES];
        libaryTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(getPhotoLibrary) userInfo:nil repeats:YES];
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
        [self getPhotoLibrary];
        isConnection = FALSE;
        [uploadWaitButton setTitle:@"加载中..." forState:UIControlStateNormal];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"isAutoUpload"];
        });
        
        if(!connectionTimer)
        {
            connectionTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(isUPloadImage) userInfo:nil repeats:YES];
        }
        if(!libaryTimer)
        {
            libaryTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(getPhotoLibrary) userInfo:nil repeats:YES];
        }
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
        return;
    }
    
    NSLog(@"开始请求");
    NSLog(@"------------------uploadNumber:%i;[photoArray count]:%i",uploadNumber,[photoArray count]);
    f_pid = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        TaskDemo *demo = [photoArray objectAtIndex:uploadNumber];
        ALAsset *result = demo.result;
        NSError *error = nil;
        Byte *data = malloc(result.defaultRepresentation.size);
        
        //获得照片图像数据
        [result.defaultRepresentation getBytes:data fromOffset:0 length:result.defaultRepresentation.size error:&error];
        demo.f_data = [NSData dataWithBytesNoCopy:data length:result.defaultRepresentation.size];
        [self showUploadingView:NO];
        UIImage *imageB = [UIImage imageWithData:demo.f_data];
        CGSize imageSize = CGSizeMake(140, 140*imageB.size.height/imageB.size.width);
        if(imageSize.height>210)
        {
            imageSize = CGSizeMake(210*imageSize.width/imageSize.height, 210);
        }
        CGRect uploadImageRect = uploadImageView.frame;
        uploadImageRect.size = imageSize;
        uploadImageRect.origin.x = (320-imageSize.width)/2;
        uploadImageRect.origin.y = (uploadProgressView.frame.origin.y-imageSize.height)/2;
        [uploadImageView setFrame:uploadImageRect];
        [uploadImageView setImage:[UIImage imageWithData:demo.f_data]];
        [uploadProgressView setProgress:0];
        [currFileNameLabel setText:[NSString stringWithFormat:@"正在上传 %@",demo.f_base_name]];
        [uploadFinshPageLabel setText:[NSString stringWithFormat:@"剩下 %i",[photoArray count]-uploadNumber]];
        [uploadWaitButton setTitle:@"开启" forState:UIControlStateNormal];
        [self showUploadingView:NO];
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
                [photoManger requestNewFold:[NSString stringWithFormat:@"来自于-%@",deviceName] FID:f_pid];
            }
        }
        else
        {
            if(bl && f_pid > 0)
            {
                [photoManger requestNewFold:[NSString stringWithFormat:@"来自于-%@",deviceName] FID:f_pid];
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
    NSLog(@"打开成功 dictionary:%@",dictionary);
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
            if([f_name isEqualToString:[NSString stringWithFormat:@"来自于-%@",deviceName]])
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
            [photoManger requestNewFold:[NSString stringWithFormat:@"来自于-%@",deviceName] FID:f_pid];
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
            TaskDemo *demo = [photoArray objectAtIndex:uploadNumber];
            demo.f_state = 1;
            demo.f_lenght = [demo.f_data length];
            [demo updateTaskTableFName];
            
            [uploadProgressView setProgress:1];
            [currFileNameLabel setText:[NSString stringWithFormat:@"正在上传%@",demo.f_base_name]];
            [uploadFinshPageLabel setText:[NSString stringWithFormat:@"剩下%i",[photoArray count]-uploadNumber]];
            
            uploadNumber++;
            
            if(!isStop && uploadNumber<[photoArray count])
            {
                isConnection = FALSE;
                [self isUPloadImage];
            }
            else if(!isStop && uploadNumber >= [photoArray count])
            {
                [self showUploadFinshView:NO];
                
                [photoArray removeAllObjects];
                uploadNumber = 0;
            }
        }
    }
}

-(void)uploadFinish:(NSDictionary *)dictionary
{
    if(connection)
    {
        [connection cancel];
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
    }
    
    NSLog(@"uploadFinishdictionary:%@",dictionary);
    if(!isStop && uploadNumber<[photoArray count])
    {
        if([[dictionary objectForKey:@"code"] intValue] == 0)
        {
            [uploadProgressView setProgress:1 animated:YES];
            TaskDemo *demo = [photoArray objectAtIndex:uploadNumber];
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
        connection = [uploderDemo requestUploadFile:[NSString stringWithFormat:@"%i",f_pid] f_name:demo.f_base_name s_name:finishName skip:[NSString stringWithFormat:@"%i",[demo f_lenght]] f_md5:[self md5:demo.f_data] Image:demo.f_data];
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
    }
    
    if(([[dictionary objectForKey:@"code"] intValue] == 0 || [[dictionary objectForKey:@"code"] intValue] == 5) && uploadNumber < [photoArray count])
    {
        NSInteger fid = [[dictionary objectForKey:@"fid"] intValue];
        TaskDemo *demo = [photoArray objectAtIndex:uploadNumber];
        [currFileNameLabel setText:[NSString stringWithFormat:@"正在上传%@",demo.f_base_name]];
        [uploadFinshPageLabel setText:[NSString stringWithFormat:@"剩下%i",[photoArray count]-uploadNumber]];
        [NSThread sleepForTimeInterval:1.0];
        
        demo.f_id = fid;
        demo.f_state = 1;
        demo.f_lenght = [demo.f_data length];
        [demo updateTaskTableFName];
        NSLog(@"f_id:%i",f_id);
    }
    NSLog(@"uploadNumber:%i;[photoArray count]:%i",uploadNumber,[photoArray count]);
    uploadNumber++;
    if(!isStop && uploadNumber<[photoArray count])
    {
        isConnection = FALSE;
        [self isUPloadImage];
    }
    else if(!isStop && uploadNumber >= [photoArray count])
    {
        [self showUploadFinshView:NO];
        [photoArray removeAllObjects];
        uploadNumber = 0;
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
    isOnce = FALSE;
    isConnection = FALSE;
    if(connectionTimer==nil && !isStop)
    {
        connectionTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(isUPloadImage) userInfo:nil repeats:YES];
    }
}

-(void)uploadFiles:(int)proress
{
    TaskDemo *demo = [photoArray objectAtIndex:uploadNumber];
    float f = (float)proress / (float)[demo.f_data length];
    [uploadProgressView setProgress:f animated:YES];
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
