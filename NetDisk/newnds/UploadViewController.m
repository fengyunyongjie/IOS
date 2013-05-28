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

@interface UploadViewController ()

@end

@implementation UploadViewController
@synthesize photoArray;

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
    allHeight = self.view.frame.size.height - 49;
    
//    CGRect rect =  _uploadNumberLabel.frame;
//    rect.origin.y =  (allHeight-(519-rect.origin.y));
//    [_uploadNumberLabel setFrame:rect];
//    
//    rect =  _stateImageview.frame;
//    rect.origin.y =  (allHeight-(519-rect.origin.y));
//    [_stateImageview setFrame:rect];
//    
//    rect =  _nameLabel.frame;
//    rect.origin.y =  (allHeight-(519-rect.origin.y));
//    [_nameLabel setFrame:rect];
//    
//    rect =  _diyUploadButton.frame;
//    rect.origin.y =  (allHeight-(519-rect.origin.y));
//    [_diyUploadButton setFrame:rect];
//    
//    rect =  _basePhotoLabel.frame;
//    rect.origin.y =  (allHeight-(519-rect.origin.y));
//    [_basePhotoLabel setFrame:rect];
//    
//    rect =  _formatLabel.frame;
//    rect.origin.y =  (allHeight-(519-rect.origin.y));
//    [_formatLabel setFrame:rect];
//    
//    rect = _uploadTypeButton.frame;
//    rect.origin.y = (allHeight-(519-rect.origin.y));
//    [_uploadTypeButton setFrame:rect];
//    [_uploadNumberLabel setTextColor:[UIColor blueColor]];
    isStop = FALSE;
    photoArray = [[NSMutableArray alloc] init];
    
    [self getPhotoLibrary];
    
    photoManger = [[SCBPhotoManager alloc] init];
    [photoManger setNewFoldDelegate:self];
    //判断文件是否存在
    NSLog(@"1:打开文件目录");
    [photoManger openFinderWithID:@"1"];
    
    
    
//    [self presentModalViewController:imagePicker animated:YES];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 获取照片库信息
-(void)getPhotoLibrary
{
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc]init];//生成整个photolibrary句柄的实例
//    NSMutableArray *mediaArray = [[NSMutableArray alloc]init];//存放media的数组
    __block BOOL first = TRUE;
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {//获取所有group
        if(first)
        {
            first = FALSE;
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {//从group里面
                NSString* assetType = [result valueForProperty:ALAssetPropertyType];
                if ([assetType isEqualToString:ALAssetTypePhoto]) {
                    UIImage *imge = [UIImage imageWithCGImage:[result aspectRatioThumbnail]];
                    TaskDemo *demo = [[TaskDemo alloc] init];
                    demo.f_state = 0;
                    //获取照片
                    demo.f_data = UIImagePNGRepresentation(imge);
                    //获取照片名称
                    demo.f_base_name = [[result defaultRepresentation] filename];
//                    demo.f_lenght = [demo.f_data length];
                    BOOL bl = [demo isPhotoExist];
                    if(!bl)
                    {
                        [demo insertTaskTable];
                        [photoArray addObject:demo];
                    }
                    [demo release];
                    //                NSLog(@"%@----%@",[[result defaultRepresentation] metadata],demo.f_base_name);
                    //获取图片时间
                    NSString *dateString = [result valueForProperty:ALAssetPropertyDate];
                    if([dateString isKindOfClass:[NSString class]])
                    {
                        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
                        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
                        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
                        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                        NSDate *date = [dateFormatter dateFromString:dateString];
                        dateString = [dateFormatter stringFromDate:date];
                        NSLog(@"dateString:%@",dateString);
                    }
                }
            }];
        }
        if(!isStop && uploadNumber<[photoArray count])
        {
            [self upLoad];
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"Enumerate the asset groups failed.");
    }];
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
-(IBAction)updateTypeClick:(id)sender
{
    NSLog(@"个数：%i",[photoArray count]);
    UIButton *button = sender;
    if(isSelected)
    {
        [button setBackgroundImage:[UIImage imageNamed:@"upload_btn_lock.png"] forState:UIControlStateNormal];
        isSelected = FALSE;
        isStop = YES;
    }
    else
    {
        [button setBackgroundImage:[UIImage imageNamed:@"upload_btn_unlock.png"] forState:UIControlStateNormal];
        isSelected = TRUE;
        if(f_pid>0)
        {
            isStop = NO;
            TaskDemo *demo = [[TaskDemo alloc] init];
            NSArray *array = [demo selectAllTaskTable];
            if([array count]>0 && [photoArray count] == 0)
            {
                [photoArray addObjectsFromArray:array];
            }
            if([photoArray count]>0 && uploadNumber<[photoArray count])
            {
                [self upLoad];
            }
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    if([photoArray count] ==0 && !isStop)
    {
        [self getPhotoLibrary];
    }
}

#pragma mark 上传校验
-(void)upLoad
{
    TaskDemo *demo = [photoArray objectAtIndex:uploadNumber];
    SCBUploader *uploder = [[[SCBUploader alloc] init] autorelease];
    [uploder setUpLoadDelegate:self];
    NSLog(@"1:申请效验");
    uploadData = [[NSString alloc] initWithString:[self md5:demo.f_data]];
    [uploder requestUploadVerify:f_pid f_name:demo.f_base_name f_size:[NSString stringWithFormat:@"%i",[demo.f_data length]] f_md5:uploadData];
}

-(void)newFold:(NSDictionary *)dictionary
{
    NSLog(@"newFold dictionary:%@",dictionary);
    if([[dictionary objectForKey:@"code"] intValue] == 0)
    {
        f_pid = [[dictionary objectForKey:@"f_id"] intValue];
    }
    else
    {
        [photoManger requestNewFold:@"照片F" FID:1];
    }
}

-(void)openFile:(NSDictionary *)dictionary
{
    NSLog(@"打开成功 dictionary:%@",dictionary);
    if([[dictionary objectForKey:@"code"] intValue] == 0)
    {
        NSArray *array = [dictionary objectForKey:@"files"];
        for(int i=0;i<[array count];i++)
        {
            NSString *f_name = [[array objectAtIndex:i] objectForKey:@"f_name"];
            if([f_name isEqualToString:@"照片"])
            {
                f_pid = [[[array objectAtIndex:i] objectForKey:@"f_id"] intValue];
            }
        }
        if(f_pid==0 && !isStop)
        {
            [photoManger requestNewFold:@"照片" FID:1];
        }
    }
}

#pragma mark 上传代理

-(void)uploadVerify:(NSDictionary *)dictionary
{
    NSLog(@"upload:%@",dictionary);
    if([[dictionary objectForKey:@"code"] intValue] == 0)
    {
        TaskDemo *demo = [photoArray objectAtIndex:uploadNumber];
        SCBUploader *uploder = [[[SCBUploader alloc] init] autorelease];
        [uploder setUpLoadDelegate:self];
        NSLog(@"2:申请效验");
        [uploder requestUploadState:demo.f_base_name];
    }
    else if([[dictionary objectForKey:@"code"] intValue] == 5)
    {
        TaskDemo *demo = [photoArray objectAtIndex:uploadNumber];
        demo.f_state = 1;
        demo.f_lenght = [demo.f_data length];
        [demo updateTaskTableFName];
        uploadNumber++;
        int page = (float)uploadNumber/(float)[photoArray count]*100;
        [_uploadNumberLabel setText:[NSString stringWithFormat:@"%％",page]];
        [_basePhotoLabel setText:[NSString stringWithFormat:@"本地图片：%i",[photoArray count]]];
        [_uploadNumberLabel setTextAlignment:NSTextAlignmentCenter];
        if(!isStop && uploadNumber<[photoArray count])
        {
            [self upLoad];
        }
        else
        {
            [_uploadNumberLabel setText:@"已完成"];
            [photoArray removeAllObjects];
            uploadNumber = 0;
        }
    }
}

-(void)uploadFinish:(NSDictionary *)dictionary
{
    NSLog(@"uploadFinishdictionary:%@",dictionary);
    if([[dictionary objectForKey:@"code"] intValue] == 0)
    {
        TaskDemo *demo = [photoArray objectAtIndex:uploadNumber];
        SCBUploader *uploder = [[[SCBUploader alloc] init] autorelease];
        [uploder setUpLoadDelegate:self];
        NSLog(@"4:提交上传表单");
        [uploder requestUploadCommit:[NSString stringWithFormat:@"%i",f_pid] f_name:demo.f_base_name s_name:finishName device:@"" skip:@"" f_md5:uploadData img_createtime:@""];
    }
    else
    {
        uploadNumber++;
        int page = (float)uploadNumber/(float)[photoArray count]*100;
        [_uploadNumberLabel setText:[NSString stringWithFormat:@"%i％",page]];
        [_basePhotoLabel setText:[NSString stringWithFormat:@"本地图片：%i",[photoArray count]]];
        [_formatLabel setText:[NSString stringWithFormat:@"已上传图片：%i",uploadNumber]];
        [_uploadNumberLabel setTextAlignment:NSTextAlignmentCenter];
        if(!isStop && uploadNumber<[photoArray count])
        {
            [self upLoad];
        }
        else
        {
            [_uploadNumberLabel setText:@"已完成"];
            [photoArray removeAllObjects];
            uploadNumber = 0;
        }
    }
}

-(void)requestUploadState:(NSDictionary *)dictionary
{
    NSLog(@"dictionary:%@",dictionary);
    if([[dictionary objectForKey:@"code"] intValue] == 0 && uploadNumber < [photoArray count])
    {
        TaskDemo *demo = [photoArray objectAtIndex:uploadNumber];
        SCBUploader *uploder = [[[SCBUploader alloc] init] autorelease];
        [uploder setUpLoadDelegate:self];
        finishName = [dictionary objectForKey:@"sname"];
        NSLog(@"3:开始上传");
        if(!isStop)
        {
            [uploder requestUploadFile:[NSString stringWithFormat:@"%i",f_pid] f_name:demo.f_base_name s_name:finishName skip:[NSString stringWithFormat:@"%i",[demo f_lenght]] f_md5:[self md5:demo.f_data] Image:demo.f_data];
        }
    }
}

-(void)uploadCommit:(NSDictionary *)dictionary
{
    NSLog(@"dictionary:%@",dictionary);
    NSLog(@"5:完成");
    if([[dictionary objectForKey:@"code"] intValue] == 0)
    {
        NSInteger f_id = [[dictionary objectForKey:@"fid"] intValue];
        TaskDemo *demo = [photoArray objectAtIndex:uploadNumber];
        demo.f_id = f_id;
        demo.f_state = 1;
        demo.f_lenght = [demo.f_data length];
        [demo updateTaskTable];
        NSLog(@"f_id:%i",f_id); 
    }
    NSLog(@"uploadNumber:%i;[photoArray count]:%i",uploadNumber,[photoArray count]);
    uploadNumber++;
    int page = (float)uploadNumber/(float)[photoArray count]*100;
    [_uploadNumberLabel setText:[NSString stringWithFormat:@"%i％",page]];
    [_basePhotoLabel setText:[NSString stringWithFormat:@"本地图片：%i",[photoArray count]]];
    [_formatLabel setText:[NSString stringWithFormat:@"已上传图片：%i",uploadNumber]];
    [_uploadNumberLabel setTextAlignment:NSTextAlignmentCenter];
    if(!isStop && uploadNumber<[photoArray count])
    {
        [self upLoad];
    }
    else
    {
        [_uploadNumberLabel setText:@"已完成"];
        [photoArray removeAllObjects];
        uploadNumber = 0;
    }
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

- (void)dealloc {
    [_uploadNumberLabel release];
    [_basePhotoLabel release];
    [_formatLabel release];
    [_uploadTypeButton release];
    [_stateImageview release];
    [super dealloc];
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
