//
//  OtherBrowserViewController.m
//  NetDisk
//
//  Created by fengyongning on 13-5-27.
//
//

#import "OtherBrowserViewController.h"
#import "SCBDownloader.h"
#import "YNFunctions.h"

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
#pragma mark - SCBDownloaderDelegate Methods
-(void)fileDidDownload:(int)index
{
    [self.downloadProgress setHidden:YES];
    [self.downloadLabel setText:@"下载完成"];
    UIDocumentInteractionController *docIC=[[UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:self.savePath]] autorelease];
    docIC.delegate=self;
    [docIC presentPreviewAnimated:YES];
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
@end
