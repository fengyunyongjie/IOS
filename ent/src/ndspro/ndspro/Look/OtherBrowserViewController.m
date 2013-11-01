//
//  OtherBrowserViewController.m
//  NetDisk
//
//  Created by fengyongning on 13-5-27.
//
//

#import "OtherBrowserViewController.h"
#import "QLBrowserViewController.h"
#import "YNFunctions.h"
#import "AppDelegate.h"

#define TabBarHeight 60
#define ChangeTabWidth 90
#define RightButtonBoderWidth 0
#define hilighted_color [UIColor colorWithRed:255.0/255.0 green:180.0/255.0 blue:94.0/255.0 alpha:1.0]
@interface OtherBrowserViewController ()
@property (strong,nonatomic) DwonFile *downImage;
@end

@implementation OtherBrowserViewController

//<ios 6.0
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

//>ios 6.0
- (BOOL)shouldAutorotate{
    return NO;
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
//    [self.view setBackgroundColor:[UIColor colorWithWhite:1 alpha:1]];
    [self.shareItem setEnabled:NO];
    [self.openItem setEnabled:NO];
    self.isFinished=NO;
	// Do any additional setup after loading the view.
    //顶视图
    float topHeigth = 20;
    if([[[UIDevice currentDevice] systemVersion] floatValue]<7.0)
    {
        topHeigth = 0;
    }
    UIView *nbar=[[UIView alloc] initWithFrame:CGRectMake(0, topHeigth, self.view.frame.size.width, 44)];
    UIImageView *niv=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Bk_Title.png"]];
    niv.frame=nbar.frame;
    [nbar addSubview:niv];
    [self.view addSubview: nbar];
//    //标题按钮
//    UIButton *btnTitle=[UIButton buttonWithType:UIButtonTypeCustom];
//    btnTitle.frame=CGRectMake(60, 0, 200, 44);
//    [btnTitle setBackgroundImage:[UIImage imageNamed:@"Bt_Title.png"] forState:UIControlStateNormal];
//    [btnTitle addTarget:self action:@selector(showTitleMenu:) forControlEvents:UIControlEventTouchUpInside];
//    [nbar addSubview:btnTitle];
    //标题
    self.titleLabel=[[UILabel alloc] init];
    self.titleLabel.text=self.title;
    self.titleLabel.font=[UIFont boldSystemFontOfSize:18];
    self.titleLabel.textAlignment=UITextAlignmentCenter;
    self.titleLabel.backgroundColor=[UIColor clearColor];
    self.titleLabel.frame=CGRectMake(80, topHeigth, 160, 44);
    [nbar addSubview:self.titleLabel];
    //把色值转换成图片
    CGRect rect_image = CGRectMake(0, 0, ChangeTabWidth, 44);
    UIGraphicsBeginImageContext(rect_image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,
                                   [hilighted_color CGColor]);
    CGContextFillRect(context, rect_image);
    UIImage * imge = [[UIImage alloc] init];
    imge = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //返回按钮
    if(1)
    {
        UIImage *back_image = [UIImage imageNamed:@"Bt_Back.png"];
        UIButton *back_button = [[UIButton alloc] initWithFrame:CGRectMake(RightButtonBoderWidth, topHeigth+(44-back_image.size.height/2)/2, back_image.size.width/2, back_image.size.height/2)];
        [back_button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
        [back_button setBackgroundImage:imge forState:UIControlStateHighlighted];
        [back_button setImage:back_image forState:UIControlStateNormal];
        [nbar addSubview:back_button];
    }
//    //更多按钮
//    self.more_button = [[UIButton alloc] init];
//    UIImage *moreImage = [UIImage imageNamed:@"Bt_More.png"];
//    [self.more_button setFrame:CGRectMake(320-RightButtonBoderWidth-moreImage.size.width/2, (44-moreImage.size.height/2)/2, moreImage.size.width/2, moreImage.size.height/2)];
//    [self.more_button setImage:moreImage forState:UIControlStateNormal];
//    [self.more_button setBackgroundImage:imge forState:UIControlStateHighlighted];
//    [self.more_button addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
//    [nbar addSubview:self.more_button];
//    [self.more_button release];
//    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(showDoc) userInfo:nil repeats:NO];
    [self showDoc];
}

-(void)showDoc
{
    NSString *file_id=[self.dataDic objectForKey:@"fid"];
    NSString *f_name=[self.dataDic objectForKey:@"fname"];
    NSString *documentDir = [YNFunctions getFMCachePath];
    NSArray *array=[f_name componentsSeparatedByString:@"/"];
    NSString *createPath = [NSString stringWithFormat:@"%@/%@",documentDir,file_id];
    [NSString CreatePath:createPath];
    self.savePath = [NSString stringWithFormat:@"%@/%@",createPath,[array lastObject]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.savePath]) {
        [self.downloadProgress setHidden:YES];
        [self.downloadLabel setText:@"下载完成"];
        [self.downloadLabel setHidden:NO];
        [self.downloadBtn setHidden:YES];
        [self.alertLabel setHidden:YES];
        [self.openItem setEnabled:YES];
        [self performSelector:@selector(showNewView) withObject:self afterDelay:1];
    }
}

-(void)showNewView
{
    QLBrowserViewController *previewController=[[QLBrowserViewController alloc] init];
    previewController.dataSource=self;
    previewController.delegate=self;
    previewController.currentPreviewItemIndex=0;
    [previewController setHidesBottomBarWhenPushed:YES];
    [self presentViewController:previewController animated:YES completion:^(void){
        NSLog(@"%@",previewController);
    }];
}

-(IBAction)openWithOthersApp:(id)sender
{
    NSString *file_id=[self.dataDic objectForKey:@"fid"];
    NSString *f_name=[self.dataDic objectForKey:@"fname"];
    NSString *documentDir = [YNFunctions getFMCachePath];
    NSArray *array=[f_name componentsSeparatedByString:@"/"];
    NSString *createPath = [NSString stringWithFormat:@"%@/%@",documentDir,file_id];
    [NSString CreatePath:createPath];
    self.savePath = [NSString stringWithFormat:@"%@/%@",createPath,[array lastObject]];
}
-(IBAction)shared:(id)sender
{
    
}
-(IBAction)download:(id)sender
{
    [self.downloadBtn setHidden:YES];
    [self.alertLabel setHidden:YES];
    [self.downloadProgress setHidden:NO];
    [self.downloadLabel setHidden:NO];
    [self.downloadProgress setProgress:0.01f];
    [self.downloadLabel setText:@"正在下载...(0M/29M)"];
    [self toDownloading];
}
-(void)toDownloading
{
    if (self.downImage==nil) {
        NSString *file_id = [self.dataDic objectForKey:@"fid"];
        NSString *f_name = [self.dataDic objectForKey:@"fname"];
        NSInteger size = [[self.dataDic objectForKey:@"fsize"] integerValue];
        self.downImage = [[DwonFile alloc] init];
        [self.downImage setFile_id:file_id];
        [self.downImage setFileName:f_name];
        [self.downImage setFileSize:size];
        [self.downImage setDelegate:self];
        [self.downImage startDownload];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)back:(id)sender
{
    [self.downImage cancelDownload];
    [self dismissModalViewControllerAnimated:YES];
}
#pragma mark - SCBDownloaderDelegate Methods
-(void)appImageDidLoad:(NSInteger)indexTag urlImage:(NSString *)path index:(NSIndexPath *)indexPath
{
    [self.downloadProgress setHidden:YES];
    [self.downloadLabel setText:@"下载完成"];
    QLBrowserViewController *previewController=[[QLBrowserViewController alloc] init];
    previewController.dataSource=self;
    previewController.delegate=self;
    
    previewController.currentPreviewItemIndex=0;
    [previewController setHidesBottomBarWhenPushed:YES];
    [self presentViewController:previewController animated:YES completion:^(void){
        NSLog(@"%@",previewController);
    }];
    [self.openItem setEnabled:YES];
}
-(void)downFile:(NSInteger)downSize totalSize:(NSInteger)sudu
{
    long t_size=[[self.dataDic objectForKey:@"fsize"] intValue];
    [self.downloadProgress setProgress:(float)downSize/t_size];
    NSString *s_size=[YNFunctions convertSize:[NSString stringWithFormat:@"%i",downSize]];
    NSString *s_tsize=[YNFunctions convertSize:[NSString stringWithFormat:@"%ld",t_size]];
    NSString *text=[NSString stringWithFormat:@"正在下载...(%@/%@)",s_size,s_tsize];
    [self.downloadLabel setText:text];
}
#pragma mark - UIDocumentInteractionControllerDelegate
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)interactionController
{
    return self;
}
#pragma mark - QLPreviewControllerDataSource
// Returns the number of items that the preview controller should preview
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)previewController
{
    return 1;
}
- (void)previewControllerDidDismiss:(QLPreviewController *)controller
{
    
}
// returns the item that the preview controller should preview
- (id)previewController:(QLPreviewController *)previewController previewItemAtIndex:(NSInteger)idx
{
    DDLogCInfo(@"previewController ----------");
    NSURL *fileURL = nil;
    fileURL=[NSURL fileURLWithPath:self.savePath];
    return fileURL;
}

- (void)downFinish:(NSString *)baseUrl
{
    [self showDoc];
}

-(void)didFailWithError
{
    
}
//上传失败
-(void)upError{}
//服务器异常
-(void)webServiceFail{}
//上传无权限
-(void)upNotUpload{}
//用户存储空间不足
-(void)upUserSpaceLass{}
//等待WiFi
-(void)upWaitWiFi{}
//网络失败
-(void)upNetworkStop{}

@end
