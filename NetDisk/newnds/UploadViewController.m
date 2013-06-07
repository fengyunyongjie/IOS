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

@synthesize photoArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    [super dealloc];
}

- (void)viewDidLoad
{
    
    allHeight = self.view.frame.size.height - 49;
    int defHeight = (allHeight-260)/2;
    CGRect rect = CGRectMake((320-184)/2, defHeight, 184, 124);
    stateImageview = [[UIImageView alloc] initWithFrame:rect];
    [stateImageview setImage:[UIImage imageNamed:@"upload_bg.png"]];
    [self.view addSubview:stateImageview];
    
    rect = CGRectMake(78, rect.origin.y+92, 150, 25);
    uploadNumberLabel = [[UILabel alloc] initWithFrame:rect];
    [uploadNumberLabel setBackgroundColor:[UIColor clearColor]];
    [uploadNumberLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:uploadNumberLabel];
    
    rect = CGRectMake((320-180)/2, rect.origin.y+40, 180, 25);
    nameLabel = [[UILabel alloc] initWithFrame:rect];
    [nameLabel setText:@"自动上传功能"];
    [self.view addSubview:nameLabel];
    
    rect = CGRectMake(180, rect.origin.y-4, 82, 33);
    uploadTypeButton = [[UIButton alloc] initWithFrame:rect];
    [uploadTypeButton setBackgroundImage:[UIImage imageNamed:@"upload_btn_lock.png"] forState:UIControlStateNormal];
    [uploadTypeButton addTarget:self action:@selector(updateTypeClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:uploadTypeButton];
    
    rect = CGRectMake((320-180)/2, rect.origin.y+4+40, 180, 25);
    basePhotoLabel = [[UILabel alloc] initWithFrame:rect];
    [basePhotoLabel setText:@"本地图片: "];
    [self.view addSubview:basePhotoLabel];
    
    rect = CGRectMake((320-180)/2, rect.origin.y+40, 180, 25);
    formatLabel = [[UILabel alloc] initWithFrame:rect];
    [formatLabel setText:@"已上传图片: "];
    [self.view addSubview:formatLabel];
    
    isStop = TRUE;
    photoArray = [[NSMutableArray alloc] init];
    
    photoManger = [[SCBPhotoManager alloc] init];
    [photoManger setNewFoldDelegate:self];
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 获取照片库信息
-(void)getPhotoLibrary
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc]init];//生成整个photolibrary句柄的实例
        //    NSMutableArray *mediaArray = [[NSMutableArray alloc]init];//存放media的数组
        __block BOOL first = TRUE;
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {//获取所有group
            if(first)
            {
                first = FALSE;
                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {//从group里面
                    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
                    NSString* assetType = [result valueForProperty:ALAssetPropertyType];
                    if ([assetType isEqualToString:ALAssetTypePhoto]) {
//                        NSError *error = nil;
//                        Byte *data = malloc(result.defaultRepresentation.size);
//                        //获得照片图像数据
//                        [result.defaultRepresentation getBytes:data fromOffset:0 length:result.defaultRepresentation.size error:&error];
//                        demo.f_data = [NSData dataWithBytesNoCopy:data length:result.defaultRepresentation.size];
                        
                        TaskDemo *demo = [[TaskDemo alloc] init];
                        demo.f_state = 0;
                        demo.f_data = nil;
                        demo.f_lenght = 0;
                        //获取照片名称
                        demo.f_base_name = [[result defaultRepresentation] filename];
                        demo.result = [result retain];
                        BOOL bl = [demo isPhotoExist];
                        if(!bl)
                        {
                            [demo insertTaskTable];
                            [photoArray addObject:demo];
                        }
                        [demo release];
                    }
                    [pool release];
                }];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if(!isStop && uploadNumber<[photoArray count])
                    {
                        [self upLoad];
                    }
                    else if(!isStop)
                    {
                        [uploadNumberLabel setText:[NSString stringWithFormat:@"没有新照片"]];
                        [uploadNumberLabel setTextAlignment:NSTextAlignmentCenter];
                    }
                });
            }
        } failureBlock:^(NSError *error) {
            NSLog(@"Enumerate the asset groups failed.");
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

#pragma mark 判断上传
-(void)updateTypeClick:(id)sender
{
    NSLog(@"个数：%i",[photoArray count]);
    UIButton *button = sender;
    if(isSelected)
    {
        [button setBackgroundImage:[UIImage imageNamed:@"upload_btn_lock.png"] forState:UIControlStateNormal];
        [uploadNumberLabel setText:[NSString stringWithFormat:@""]];
        [basePhotoLabel setText:[NSString stringWithFormat:@"本地图片："]];
        [formatLabel setText:[NSString stringWithFormat:@"已上传图片："]];
        [uploadNumberLabel setTextAlignment:NSTextAlignmentCenter];
        [photoArray removeAllObjects];
        NSLog(@"删除了数据");
        isSelected = FALSE;
        isStop = YES;
        uploadNumber = 0;
    }
    else
    {
        if([photoArray count] == 0)
        {
            [uploadNumberLabel setText:[NSString stringWithFormat:@"正在扫描"]];
            [uploadNumberLabel setTextAlignment:NSTextAlignmentCenter];
        }
        [button setBackgroundImage:[UIImage imageNamed:@"upload_btn_unlock.png"] forState:UIControlStateNormal];
        isStop = NO;
        isSelected = TRUE;
        if([photoArray count]==0)
        {
            [self getPhotoLibrary];
        }
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//            isStop = NO;
//            TaskDemo *demo = [[[TaskDemo alloc] init] autorelease];
//            NSArray *array = [demo selectAllTaskTable];
//            if([array count]>0 && [photoArray count] == 0)
//            {
//                [photoArray addObjectsFromArray:array];
//            }
//            dispatch_sync(dispatch_get_main_queue(), ^{
//                if([photoArray count]>0 && uploadNumber<[photoArray count])
//                {
//                   [self upLoad];
//                }
//                if([photoArray count] == 0)
//                {
//                    [uploadNumberLabel setText:[NSString stringWithFormat:@"没有新照片"]];
//                    [uploadNumberLabel setTextAlignment:NSTextAlignmentCenter];
//                }
//            });
//        });
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    if([[SCBSession sharedSession] userId] != user_id || [[SCBSession sharedSession] userToken] != user_token)
    {
        [uploadTypeButton setBackgroundImage:[UIImage imageNamed:@"upload_btn_lock.png"] forState:UIControlStateNormal];
        isSelected = FALSE;
        [uploadNumberLabel setText:@""];
        [basePhotoLabel setText:[NSString stringWithFormat:@"本地图片："]];
        [formatLabel setText:[NSString stringWithFormat:@"已上传图片："]];
        [uploadNumberLabel setTextAlignment:NSTextAlignmentCenter];
        uploadNumber = 0;
        isStop = YES;
        [photoArray removeAllObjects];
        user_id = [[SCBSession sharedSession] userId];
        user_token = [[SCBSession sharedSession] userToken];
    }
    if(!isStop && [photoArray count] ==0)
    {
        [self getPhotoLibrary];
    }
}

#pragma mark 上传校验
-(void)upLoad
{
    //紧紧在wifi下上传
    NSString *switchFlag = [[NSUserDefaults standardUserDefaults] objectForKey:@"switch_flag"];
    if([switchFlag boolValue] || !switchFlag)
    {
        //wifi
        if([[self GetCurrntNet] isEqualToString:@"WIFI"])
        {
            NSLog(@"------------------uploadNumber:%i;[photoArray count]:%i",uploadNumber,[photoArray count]);
            if(uploadNumber==0)
            {
                [uploadNumberLabel setText:[NSString stringWithFormat:@"开始上传"]];
            }
            int page = (float)uploadNumber/(float)[photoArray count]*100;
            if(page == 0)
            {
                [uploadNumberLabel setText:[NSString stringWithFormat:@"开始上传"]];
            }
            else
            {
                [uploadNumberLabel setText:[NSString stringWithFormat:@"%i％",page]];
            }
            [basePhotoLabel setText:[NSString stringWithFormat:@"本地图片：%i",[photoArray count]]];
            [formatLabel setText:[NSString stringWithFormat:@"已上传图片：%i",uploadNumber]];
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
            [uploadNumberLabel setTextAlignment:NSTextAlignmentCenter];
        }
        else
        {
            [uploadNumberLabel setText:[NSString stringWithFormat:@""]];
            [uploadNumberLabel setTextAlignment:NSTextAlignmentCenter];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"WiFi没有打开，请打开后再上传" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
        }
    }
    else
    {
        NSLog(@"------------------uploadNumber:%i;[photoArray count]:%i",uploadNumber,[photoArray count]);
        int page = (float)uploadNumber/(float)[photoArray count]*100;
        if(page == 0)
        {
            [uploadNumberLabel setText:[NSString stringWithFormat:@"开始上传"]];
        }
        else
        {
            [uploadNumberLabel setText:[NSString stringWithFormat:@"%i％",page]];
        }
        [basePhotoLabel setText:[NSString stringWithFormat:@"本地图片：%i",[photoArray count]]];
        [formatLabel setText:[NSString stringWithFormat:@"已上传图片：%i",uploadNumber]];
        [uploadNumberLabel setTextAlignment:NSTextAlignmentCenter];
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
            connectionKind = @"没有网络链接";
            break;
        case ReachableViaWiFi:
            connectionKind = @"WIFI";
            break;
        case ReachableViaWWAN:
            connectionKind = @"WLAN";
            break;  
        default:
            break;
    }
    return connectionKind;
}



-(void)newFold:(NSDictionary *)dictionary
{
    NSLog(@"newFold dictionary:%@",dictionary);
    
    if(!isStop && uploadNumber<[photoArray count])
    {
        if([[dictionary objectForKey:@"code"] intValue] == 0)
        {
            f_pid = [[dictionary objectForKey:@"f_id"] intValue];
            [self requestVerify];
        }
        else
        {
            [photoManger requestNewFold:@"手机照片" FID:1];
        }
    }
}

-(void)openFile:(NSDictionary *)dictionary
{
    NSLog(@"打开成功 dictionary:%@",dictionary);
    if([[dictionary objectForKey:@"code"] intValue] == 0 && !isStop && uploadNumber<[photoArray count])
    {
        NSArray *array = [dictionary objectForKey:@"files"];
        for(int i=0;i<[array count];i++)
        {
            NSString *f_name = [[array objectAtIndex:i] objectForKey:@"f_name"];
            if([f_name isEqualToString:@"手机照片"])
            {
                f_pid = [[[array objectAtIndex:i] objectForKey:@"f_id"] intValue];
                [self requestVerify];
                break;
            }
        }
        if(f_pid==0)
        {
            [photoManger requestNewFold:@"手机照片" FID:1];
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
        [uploder requestUploadVerify:f_pid f_name:demo.f_base_name f_size:[NSString stringWithFormat:@"%i",[demo.f_data length]] f_md5:uploadData];
    }
    else if(!isStop && uploadNumber >= [photoArray count])
    {
        [uploadNumberLabel setText:@"已完成"];
        [uploadNumberLabel setTextAlignment:NSTextAlignmentCenter];
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
            uploadNumber++;
            [self upLoad];
        }
    }
}

-(void)uploadFinish:(NSDictionary *)dictionary
{
    NSLog(@"uploadFinishdictionary:%@",dictionary);
    if(!isStop && uploadNumber<[photoArray count])
    {
        if([[dictionary objectForKey:@"code"] intValue] == 0)
        {
            TaskDemo *demo = [photoArray objectAtIndex:uploadNumber];
            SCBUploader *uploder = [[[SCBUploader alloc] init] autorelease];
            [uploder setUpLoadDelegate:self];
            NSLog(@"4:提交上传表单:%@",finishName);
            [uploder requestUploadCommit:[NSString stringWithFormat:@"%i",f_pid] f_name:demo.f_base_name s_name:finishName device:@"" skip:@"" f_md5:uploadData img_createtime:@""];
        }
        else
        {
            NSLog(@"3:重新上传");
            [self upLoad];
        }
    }
}

-(void)requestUploadState:(NSDictionary *)dictionary
{
    NSLog(@"dictionary:%@",dictionary);
    if(!isStop && [[dictionary objectForKey:@"code"] intValue] == 0 && uploadNumber < [photoArray count])
    {
        TaskDemo *demo = [photoArray objectAtIndex:uploadNumber];
        SCBUploader *uploder = [[[SCBUploader alloc] init] autorelease];
        [uploder setUpLoadDelegate:self];
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
        [uploder requestUploadFile:[NSString stringWithFormat:@"%i",f_pid] f_name:demo.f_base_name s_name:finishName skip:[NSString stringWithFormat:@"%i",[demo f_lenght]] f_md5:[self md5:demo.f_data] Image:demo.f_data];
    }
}

-(void)uploadCommit:(NSDictionary *)dictionary
{
    NSLog(@"dictionary:%@",dictionary);
    NSLog(@"5:完成");
    if([[dictionary objectForKey:@"code"] intValue] == 0 & uploadNumber < [photoArray count])
    {
        NSInteger f_id = [[dictionary objectForKey:@"fid"] intValue];
        TaskDemo *demo = [photoArray objectAtIndex:uploadNumber];
        demo.f_id = f_id;
        demo.f_state = 1;
        demo.f_lenght = [demo.f_data length];
        [demo updateTaskTableFName];
        NSLog(@"f_id:%i",f_id); 
    }
    NSLog(@"uploadNumber:%i;[photoArray count]:%i",uploadNumber,[photoArray count]);
    uploadNumber++;
    if(!isStop && uploadNumber<[photoArray count])
    {
        [self upLoad];
    }
    else if(!isStop && uploadNumber >= [photoArray count])
    {
        [basePhotoLabel setText:[NSString stringWithFormat:@"本地图片：%i",[photoArray count]]];
        [formatLabel setText:[NSString stringWithFormat:@"已上传图片：%i",uploadNumber]];
        [uploadNumberLabel setText:@"已完成"];
        [uploadNumberLabel setTextAlignment:NSTextAlignmentCenter];
        [photoArray removeAllObjects];
        uploadNumber = 0;
    }
}

-(void)uploadFiles:(NSDictionary *)dictionary
{
    
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
