//
//  SearchViewController.m
//  NetDisk
//
//  Created by Yangsl on 13-9-5.
//
//

#import "SearchViewController.h"
#import "AppDelegate.h"
#define ChangeTabWidth 70
#define RightButtonBoderWidth 0
#define TableViewHeight self.view.frame.size.height-TabBarHeight-44

@interface SearchViewController ()

@end

@implementation SearchViewController
@synthesize fileTableView,topView,searchView,hud;

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
    
    [self.navigationController setNavigationBarHidden:YES];
    self.view.backgroundColor = [UIColor whiteColor];
    //添加头部试图
    topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [imageV setImage:[UIImage imageNamed:@"Bk_Title.png"]];
    [topView addSubview:imageV];
    [imageV release];
    
    //标题
    UILabel *titleLabel=[[UILabel alloc] init];
    titleLabel.text=@"搜索";
    titleLabel.font=[UIFont boldSystemFontOfSize:18];
    titleLabel.textAlignment=UITextAlignmentCenter;
    titleLabel.backgroundColor=[UIColor clearColor];
    titleLabel.frame=CGRectMake(80, 0, 160, 44);
    [topView addSubview:titleLabel];
    [titleLabel release];
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
    [back_button addTarget:self action:@selector(clickedBack) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:back_button];
    [back_button release];
    [self.view addSubview:topView];
    
    //搜索视图
    searchView=[[UIView alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, 36)];
    UIImageView *searchBg=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Bk_Seach.png"]];
    searchBg.frame=CGRectMake(0, 0, self.view.frame.size.width, 36);
    [searchView addSubview:searchBg];
    [self.view addSubview:searchView];
    tfdSearch=[[UITextField alloc] initWithFrame:CGRectMake(10, 3, 265, 30)];
    tfdSearch.placeholder=@"搜索你的文件";
    tfdSearch.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
    tfdSearch.borderStyle=UITextBorderStyleNone;
    tfdSearch.delegate=self;
    [searchView addSubview:tfdSearch];
    UIButton *btnSearchOk=[UIButton buttonWithType:UIButtonTypeCustom];
    btnSearchOk.frame=CGRectMake(283, 2, 32, 32);
    [btnSearchOk setImage:[UIImage imageNamed:@"Bt_Seach.png"] forState:UIControlStateNormal];
    [btnSearchOk addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
    [searchView addSubview:btnSearchOk];
    //初始化文件列表
    CGRect rect = CGRectMake(0, 44+36, 320, TableViewHeight-36);
    fileTableView = [[FileTableView alloc] initWithFrame:rect];
    fileTableView.useType = 1;
    [fileTableView setAllHeight:self.view.frame.size.height];
    [fileTableView setFile_delegate:self];
    [self.view addSubview:fileTableView];
}

-(void)searchAction:(id)sender
{
    [tfdSearch endEditing:YES];
    if ([tfdSearch.text isEqualToString:@""]||tfdSearch.text==nil) {
        if (self.hud) {
            [self.hud removeFromSuperview];
        }
        self.hud=nil;
        self.hud=[[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:self.hud];
        [self.hud show:NO];
        self.hud.labelText=@"查询条件不能为空";
        self.hud.mode=MBProgressHUDModeText;
        self.hud.margin=10.f;
        [self.hud show:YES];
        [self.hud hide:YES afterDelay:1.0f];
        return;
    }
    fileTableView.searchText = tfdSearch.text;
    [fileTableView searchFameily];
}

//返回按钮
-(void)clickedBack
{
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma delegate

-(void)showFile:(int)index array:(NSMutableArray *)tableArray{}

-(void)showAllFile:(NSMutableArray *)tableArray{}

-(void)downController:(NSString *)fid{}

-(void)showController:(NSString *)f_id titleString:(NSString *)f_name{}

-(void)messageShare:(NSString *)content
{
    NSString *text=[NSString stringWithFormat:@"%@想和您分享虹盘的文件，链接地址：%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"usr_name"],content];
    
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
        picker.messageComposeDelegate = self;
        
        [picker setBody:text];
        [self presentModalViewController:picker animated:YES];
        [picker release];
    }
}

#pragma mark messageComposeDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
	NSString *resultValue=@"";
	switch (result)
	{
		case MessageComposeResultCancelled:
			resultValue = @"Result: SMS sending canceled";
			break;
		case MessageComposeResultSent:
			resultValue = @"Result: SMS sent";
			break;
		case MessageComposeResultFailed:
			resultValue = @"Result: SMS sending failed";
			break;
		default:
			resultValue = @"Result: SMS not sent";
			break;
	}
    NSLog(@"%@",resultValue);
	[self dismissModalViewControllerAnimated:YES];
}

-(void)mailShare:(NSString *)content
{
    NSString *text=[NSString stringWithFormat:@"%@想和您分享虹盘的文件，链接地址：%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"usr_name"],content];
    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        
        [picker setSubject:text];
        
        NSString *emailBody = text;
        [picker setMessageBody:emailBody isHTML:NO];
        
        [self presentModalViewController:picker animated:YES];
        [picker release];
    }
}

-(void)setMemberArray:(NSArray *)memberArray{}

-(void)haveData{}

-(void)nullData{}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [fileTableView release];
    [topView release];
    [tfdSearch release];
    [super dealloc];
}

@end
