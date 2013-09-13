//
//  AutomicUploadViewController.m
//  NetDisk
//
//  Created by Yangsl on 13-8-13.
//
//

#import "AutomicUploadViewController.h"
#import "AppDelegate.h"
#import "YNFunctions.h"
#import "SCBSession.h"
#import "SelectFileUrlViewController.h"
#import "UserInfo.h"

#define TableViewHeight self.view.frame.size.height-TabBarHeight-44
#define OFFButtonHeight 25
#define OFFBorderWidth 20

#define OFFImageWidth 70
#define OFFImageHeight 33
#define OFFCurrWidth OFFImageWidth*OFFButtonHeight/OFFImageHeight
#define OFFCurrX 320-OFFCurrWidth-OFFBorderWidth
#define OFFCurrY (40-OFFButtonHeight)/2
#define OFFButtonRect CGRectMake(OFFCurrX, OFFCurrY, OFFCurrWidth, OFFButtonHeight)

@interface AutomicUploadViewController ()

@end

@implementation AutomicUploadViewController
@synthesize table_view,table_array,table_string;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#define ChangeTabWidth 90
#define RightButtonBoderWidth 0

-(void)viewWillAppear:(BOOL)animated
{
    AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(app_delegate.myTabBarController.IsTabBarHiden)
    {
        [app_delegate.myTabBarController setHidesTabBarWithAnimate:NO];
    }
    UserInfo *info = [[UserInfo alloc] init];
    info.keyString = @"自动备份目录";
    NSMutableArray *array = [info selectAllUserinfo];
    if([array count] == 0)
    {
        info.f_id = -1;
        info.descript = [NSString stringWithFormat:@"我的文件/手机照片/%@",[AppDelegate deviceString]];
        [info insertUserinfo];
        self.table_string = info.descript;
        app_delegate.maticUpload.f_id = @"-1";
    }
    else
    {
        UserInfo *info = [array lastObject];
        app_delegate.maticUpload.f_id = [NSString stringWithFormat:@"%i",info.f_id];
        self.table_string = [[[NSString alloc] initWithString:info.descript] autorelease];
    }
    if(table_view)
    {
        UITableViewCell *cell = [table_view cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        cell.detailTextLabel.text = self.table_string;
    }
    NSLog(@"app_delegate.maticUpload.f_id:%@",app_delegate.maticUpload.f_id);
    [info release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    
    space_id = [[SCBSession sharedSession] spaceID];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIView *nbar=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    UIImageView *niv=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Bk_Title.png"]];
    niv.frame=nbar.frame;
    [nbar addSubview:niv];
    [self.view addSubview:nbar];
    
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
    UIImage *back_image = [UIImage imageNamed:@"Bt_Back.png"];
    UIButton *back_button = [[UIButton alloc] initWithFrame:CGRectMake(RightButtonBoderWidth, (44-back_image.size.height/2)/2, back_image.size.width/2, back_image.size.height/2)];
    [back_button addTarget:self action:@selector(clicked_back) forControlEvents:UIControlEventTouchUpInside];
    [back_button setBackgroundImage:imge forState:UIControlStateHighlighted];
    [back_button setImage:back_image forState:UIControlStateNormal];
    [nbar addSubview:back_button];
    
    //标题
    UILabel *titleLabel=[[UILabel alloc] init];
    titleLabel.text=@"相册自动备份";
    titleLabel.font=[UIFont boldSystemFontOfSize:18];
    titleLabel.textAlignment=UITextAlignmentCenter;
    titleLabel.backgroundColor=[UIColor clearColor];
    titleLabel.frame=CGRectMake(60, 0, 200, 44);
    [nbar addSubview:titleLabel];
    
    CGRect table_rect = CGRectMake(0, 44, 320, TableViewHeight);
	table_view = [[[UITableView alloc] initWithFrame:table_rect style:UITableViewStyleGrouped] autorelease];
    table_view.dataSource=self;
    table_view.delegate=self;
    [self.view addSubview:table_view];
    [table_view setBackgroundColor:[UIColor whiteColor]];
    [table_view setBackgroundView:nil];
}

-(void)clicked_back
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 3;
            break;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *celleString = @"automicCell";
    UITableViewCell *cell = [table_view dequeueReusableCellWithIdentifier:celleString];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:celleString] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.detailTextLabel setFont:[UIFont systemFontOfSize:12]];
        CGRect rect = cell.frame;
        rect.size.width = 280;
        cell.frame = rect;
    }
    int row = [indexPath row];
    if(row == 0)
    {
        cell.textLabel.text = @"相册自动备份";
        cell.detailTextLabel.text = @"指定目录自动备份到云端";
        if(automicOff_button == nil)
        {
            automicOff_button = [[UIButton alloc] initWithFrame:OFFButtonRect];
            if([YNFunctions isAutoUpload])
            {
                [automicOff_button setImage:[UIImage imageNamed:@"OFF.png"] forState:UIControlStateNormal];
            }
            else
            {
                [automicOff_button setImage:[UIImage imageNamed:@"ON.png"] forState:UIControlStateNormal];
            }
            [automicOff_button addTarget:self action:@selector(openOrClose:) forControlEvents:UIControlEventTouchUpInside];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        [cell addSubview:automicOff_button];
    }
    if(row == 1)
    {
        cell.textLabel.text = @"选择自动备份目录";
    }
    if(row == 2)
    {
        cell.textLabel.text = @"照片备份至";
        if(self.table_string)
        {
            NSLog(@"table_string:%@",self.table_string);
            cell.detailTextLabel.text = self.table_string;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    if (row == 0) {
        [self openOrClose:automicOff_button];
    }
    else if(row == 1)
    {
        AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if(app_delegate.title_string == nil)
        {
            app_delegate.title_string = [[NSMutableArray alloc] init];
        }
        else
        {
            [app_delegate.title_string removeAllObjects];
        }
        SelectFileUrlViewController *selectFileView = [[SelectFileUrlViewController alloc] init];
        selectFileView.isAutomatic = YES;
        [app_delegate.title_string removeLastObject];
        [app_delegate.myTabBarController setHidesTabBarWithAnimate:YES];
        [self.navigationController pushViewController:selectFileView animated:YES];
        [selectFileView release];
    }
}

-(void)openOrClose:(id)sender
{
    if(automicOff_button)
    {
        if([YNFunctions isAutoUpload])
        {
            [automicOff_button setImage:[UIImage imageNamed:@"ON.png"] forState:UIControlStateNormal];
//            [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(closeUpload) userInfo:nil repeats:NO];
            [NSThread detachNewThreadSelector:@selector(closeUpload) toTarget:self withObject:nil];
        }
        else
        {
            [automicOff_button setImage:[UIImage imageNamed:@"OFF.png"] forState:UIControlStateNormal];
//            [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(startAutoUpload) userInfo:nil repeats:NO];
            [NSThread detachNewThreadSelector:@selector(startAutoUpload) toTarget:self withObject:nil];
        }
    }
}

-(void)closeUpload
{
    [YNFunctions setIsAutoUpload:NO];
    AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app_delegate.maticUpload colseAutomaticUpload];
}

-(void)startAutoUpload
{
    [YNFunctions setIsAutoUpload:YES];
    AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app_delegate.maticUpload isHaveData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
