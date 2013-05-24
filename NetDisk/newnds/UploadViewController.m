//
//  UploadViewController.m
//  NetDisk
//
//  Created by fengyongning on 13-5-21.
//
//

#import "UploadViewController.h"
#import "ALAsset+AGIPC.h"

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
    CGRect rect =  _uploadNumber.frame;
    rect.origin.y =  (allHeight-(519-rect.origin.y));
    [_uploadNumber setFrame:rect];
    
    rect =  self.stateImageview.frame;
    rect.origin.y =  (allHeight-(519-rect.origin.y));
    [self.stateImageview setFrame:rect];
    
    rect =  self.nameLabel.frame;
    rect.origin.y =  (allHeight-(519-rect.origin.y));
    [self.nameLabel setFrame:rect];
    
    rect =  self.diyUploadButton.frame;
    rect.origin.y =  (allHeight-(519-rect.origin.y));
    [self.diyUploadButton setFrame:rect];
    
    rect =  self.basePhotoLabel.frame;
    rect.origin.y =  (allHeight-(519-rect.origin.y));
    [self.basePhotoLabel setFrame:rect];
    
    rect =  self.formatLabel.frame;
    rect.origin.y =  (allHeight-(519-rect.origin.y));
    [self.formatLabel setFrame:rect];
    
    photoManger = [[SCBPhotoManager alloc] init];
    [photoManger setNewFoldDelegate:self];
    //判断文件是否存在
    [photoManger openFinderWithID:@"1"];
    
    photoArray = [[NSMutableArray alloc] init];
    [self getPhotoLibrary];
    
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
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {//获取所有group
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {//从group里面
            NSString* assetType = [result valueForProperty:ALAssetPropertyType];
            if ([assetType isEqualToString:ALAssetTypePhoto]) {
                UIImage *imge = [UIImage imageWithCGImage:[result aspectRatioThumbnail]];
                photoImage *p_image = [[photoImage alloc] init];
                p_image.image = imge;
                p_image.name = [[result defaultRepresentation] filename]; //获取照片名称
                [photoArray addObject:p_image];
                [p_image release];
                                    //[[result defaultRepresentation] metadata] 获取图片详细信息（）()
            }
//            else if([assetType isEqualToString:ALAssetTypeVideo]){
//                NSLog(@"Video");
//            }else if([assetType isEqualToString:ALAssetTypeUnknown]){
//                NSLog(@"Unknow AssetType");
//            }
        }];
    } failureBlock:^(NSError *error) {
        NSLog(@"Enumerate the asset groups failed.");
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo NS_DEPRECATED_IOS(2_0, 3_0)
{
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
}

#pragma mark 创建上传集合
-(void)createUploadArray
{
    for(int i=0;i<[photoArray count];i++)
    {
        
    }
}

#pragma mark 上传校验

-(void)upLoad
{
    photoImage *p_image = [photoArray objectAtIndex:0];
    SCBUploader *uploder = [[[SCBUploader alloc] init] autorelease];
    [uploder setUpLoadDelegate:self];
    NSData *data = UIImagePNGRepresentation(p_image.image);
    [uploder requestUploadVerify:f_pid f_name:p_image.name f_size:[NSString stringWithFormat:@"%i",[data length]]];
//    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
//    NSString *path=[paths    objectAtIndex:0];
//    NSString *filename=[path stringByAppendingPathComponent:@"0.gif"];
//    
//    if ([[NSFileManager defaultManager] fileExistsAtPath:filename])
//    {
//        NSLog(@"it is -------- ");
//    }
//    NSURL * url = [NSURL URLWithString:@""];
//    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
//    [request setUseKeychainPersistence:YES];
//    NSData *zipFileData = [NSData dataWithContentsOfFile:filename];
//    [request setPostValue:@"Ben" forKey:@"t1"];
//    [request setPostValue:@"1" forKey:@"filecount"];
//    [request setData:zipFileData withFileName:filename andContentType:@"multipart/form-data" forKey:@"myfile0"];
//    [request setRequestMethod:@"POST"];
//    [request startSynchronous];
    
    //NSData * myResponseData = [request responseData];
    //NSLog(@"data:%@",myResponseData);
}

-(IBAction)updateTypeClick:(id)sender
{
    UIButton *button = sender;
    if(isSelected)
    {
        [button setImage:[UIImage imageNamed:@"upload_btn_lock.png"] forState:UIControlStateNormal];
        isSelected = FALSE;
    }
    else
    {
        [button setImage:[UIImage imageNamed:@"upload_btn_unlock.png"] forState:UIControlStateNormal];
        isSelected = TRUE;
        if(f_pid>0)
        {
            [self upLoad];
        }
    }
}

-(void)newFold:(NSDictionary *)dictionary
{
    NSLog(@"dictionary:%@",dictionary);
    if([[dictionary objectForKey:@"code"] intValue] == 0)
    {
        f_pid = [[dictionary objectForKey:@"f_id"] intValue];
    }
    else
    {
        [photoManger requestNewFold:@"照片" FID:1];
    }
    
    
}

-(void)openFile:(NSDictionary *)dictionary
{
    NSLog(@"dictionary:%@",dictionary);
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
    }
}

#pragma mark 上传代理

-(void)uploadVerify:(NSDictionary *)dictionary
{
    NSLog(@"upload:%@",dictionary);
    if([[dictionary objectForKey:@"code"] intValue] == 0)
    {
        SCBUploader *uploder = [[[SCBUploader alloc] init] autorelease];
        [uploder setUpLoadDelegate:self];
        [uploder requestUploadState:@""];
    }
}

-(void)uploadFinish:(NSDictionary *)dictionary
{
    NSLog(@"uploadFinishdictionary:%@",dictionary);
}

-(void)requestUploadState:(NSDictionary *)dictionary
{
    NSLog(@"dictionary:%@",dictionary);
    if([[dictionary objectForKey:@"code"] intValue] == 0)
    {
        photoImage *p_image = [photoArray objectAtIndex:0];
        SCBUploader *uploder = [[[SCBUploader alloc] init] autorelease];
        [uploder setUpLoadDelegate:self];
        NSData *data = UIImagePNGRepresentation(p_image.image);
        
        [uploder requestUploadFile:@"1" f_name:p_image.name s_name:[NSString stringWithFormat:@"%@",[dictionary objectForKey:@"sname"]] skip:@"0" f_md5:[self md5:data] Image:data];
    }
}

- (void)dealloc {
    [_uploadNumber release];
    [_basePhotoLabel release];
    [_formatLabel release];
    [_uploadTypeButton release];
    [_stateImageview release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setUploadNumber:nil];
    [super viewDidUnload];
}

-(NSString *)md5:(NSData *)concat {
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(concat, concat.length, result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}



@end

@implementation photoImage
@synthesize image,name,imageData;

-(void)dealloc
{
    [imageData release];
    [name release];
    [name release];
    [super dealloc];
}


@end
