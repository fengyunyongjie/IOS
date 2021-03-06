//
//  OtherBrowserViewController.m
//  NetDisk
//
//  Created by fengyongning on 13-5-27.
//
//

#import "OtherBrowserViewController.h"
#import "QLBrowserViewController.h"
#import "SCBDownloader.h"
#import "YNFunctions.h"
#define TabBarHeight 60
#define ChangeTabWidth 90
#define RightButtonBoderWidth 0
#define hilighted_color [UIColor colorWithRed:255.0/255.0 green:180.0/255.0 blue:94.0/255.0 alpha:1.0]
@interface OtherBrowserViewController ()
@property (strong,nonatomic) SCBDownloader *downloader;
@end

@implementation OtherBrowserViewController

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
    [self performSelector:@selector(showDoc) withObject:self afterDelay:0.01f];
    //顶视图
    UIView *nbar=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
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
    self.titleLabel.frame=CGRectMake(80, 0, 160, 44);
    [nbar addSubview:self.titleLabel];
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
    if(1)
    {
        UIImage *back_image = [UIImage imageNamed:@"Bt_Back.png"];
        UIButton *back_button = [[UIButton alloc] initWithFrame:CGRectMake(RightButtonBoderWidth, (44-back_image.size.height/2)/2, back_image.size.width/2, back_image.size.height/2)];
        [back_button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
        [back_button setBackgroundImage:imge forState:UIControlStateHighlighted];
        [back_button setImage:back_image forState:UIControlStateNormal];
        [nbar addSubview:back_button];
        [back_button release];
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

}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSString *f_name=[self.dataDic objectForKey:@"f_name"];
    NSString *savedPath=[YNFunctions getFMCachePath];
    savedPath=[savedPath stringByAppendingPathComponent:f_name];
    self.savePath=savedPath;
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.savePath]) {
        [self.downloadProgress setHidden:YES];
        [self.downloadLabel setText:@"下载完成"];
        [self.downloadLabel setHidden:NO];
        [self.downloadBtn setHidden:YES];
        [self.alertLabel setHidden:YES];
        [self.openItem setEnabled:YES];
    }
}
-(void)showDoc
{
    NSString *f_name=[self.dataDic objectForKey:@"f_name"];
    NSString *savedPath=[YNFunctions getFMCachePath];
    savedPath=[savedPath stringByAppendingPathComponent:f_name];
    self.savePath=savedPath;
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.savePath]) {
        [self.downloadProgress setHidden:YES];
        [self.downloadLabel setText:@"下载完成"];
        [self.downloadLabel setHidden:NO];
        [self.downloadBtn setHidden:YES];
        [self.alertLabel setHidden:YES];
        [self.openItem setEnabled:YES];
        UIDocumentInteractionController *docIC=[[UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:self.savePath]] autorelease];
        docIC.delegate=self;
        [docIC presentPreviewAnimated:YES];
    }
}
-(IBAction)openWithOthersApp:(id)sender
{
    NSString *f_name=[self.dataDic objectForKey:@"f_name"];
    NSString *savedPath=[YNFunctions getFMCachePath];
    savedPath=[savedPath stringByAppendingPathComponent:f_name];
    self.savePath=savedPath;
    UIDocumentInteractionController *docIC=[[UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:self.savePath]] autorelease];
    docIC.delegate=self;
    [docIC presentPreviewAnimated:YES];
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
    if (self.downloader==nil) {
        NSString *f_id=[self.dataDic objectForKey:@"f_id"];
        NSString *f_name=[self.dataDic objectForKey:@"f_name"];
        NSString *savedPath=[YNFunctions getFMCachePath];
        savedPath=[savedPath stringByAppendingPathComponent:f_name];
        self.downloader=[[[SCBDownloader alloc] init] autorelease];
        self.downloader.index=0;
        self.downloader.fileId=f_id;
        self.downloader.savedPath=savedPath;
        self.savePath=savedPath;
        self.downloader.delegate=self;
        [self.downloader startDownload];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)back:(id)sender
{
    [self.downloader cancelDownload];
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - SCBDownloaderDelegate Methods
-(void)fileDidDownload:(int)index
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
//    UIDocumentInteractionController *docIC=[[UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:self.savePath]] autorelease];
//    docIC.delegate=self;
//    [docIC presentPreviewAnimated:YES];
    [self.openItem setEnabled:YES];
}
-(void)updateProgress:(long)size index:(int)index
{
    long t_size=[[self.dataDic objectForKey:@"f_size"] intValue];
    [self.downloadProgress setProgress:(float)size/t_size];
    NSString *s_size=[YNFunctions convertSize:[NSString stringWithFormat:@"%ld",size]];
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
    NSInteger numToPreview = 0;
    //
    //    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    //    if (selectedIndexPath.section == 0)
    //        numToPreview = NUM_DOCS;
    //    else
    //        numToPreview = self.documentURLs.count;
    //
    //    return numToPreview;
    //numToPreview=[self.tableView numberOfRowsInSection:0];
    //return numToPreview;
    return 1;
}
- (void)previewControllerDidDismiss:(QLPreviewController *)controller
{
    // if the preview dismissed (done button touched), use this method to post-process previews
}
// returns the item that the preview controller should preview
- (id)previewController:(QLPreviewController *)previewController previewItemAtIndex:(NSInteger)idx
{
    NSURL *fileURL = nil;
    
//    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
//    NSDictionary *dic=[self.listArray objectAtIndex:selectedIndexPath.row];
//    NSString *fileName=[dic objectForKey:@"f_name"];
//    NSString *filePath=[YNFunctions getFMCachePath];
//    filePath=[filePath stringByAppendingPathComponent:fileName];
//    fileURL=[NSURL fileURLWithPath:filePath];
    fileURL=[NSURL fileURLWithPath:self.savePath];
    return fileURL;
}

@end
