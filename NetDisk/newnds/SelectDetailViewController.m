//
//  SelectDetailViewController.m
//  NetDisk
//
//  Created by Yangsl on 13-8-13.
//
//

#import "SelectDetailViewController.h"
#import "AppDelegate.h"
#import "SCBSession.h"
#import "UserInfo.h"

#define ChangeTabWidth 90
#define RightButtonBoderWidth 0
#define TabBarHeight 60
#define TableViewHeight self.view.frame.size.height-44-TabBarHeight
#define ChangeTabWidth 90
#define RightButtonBoderWidth 0
#define BottonViewHeight self.view.frame.size.height-TabBarHeight

@interface SelectDetailViewController ()

@end

@implementation SelectDetailViewController
@synthesize table_view;
@synthesize space_id;
@synthesize selected_id;
@synthesize table_array;
@synthesize photo_manager;
@synthesize f_id;
@synthesize share_manager;
@synthesize title_string;
@synthesize isAutomatic;
@synthesize delegate;
@synthesize isEdtion;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    table_array = [[NSMutableArray alloc] init];
    
	[self.navigationController setNavigationBarHidden:YES];
    
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
    
    //标题
    UILabel *titleLabel=[[UILabel alloc] init];
    titleLabel.text=title_string;
    titleLabel.font=[UIFont boldSystemFontOfSize:18];
    titleLabel.textAlignment=UITextAlignmentCenter;
    titleLabel.backgroundColor=[UIColor clearColor];
    titleLabel.frame=CGRectMake(60, 0, 200, 44);
    [nbar addSubview:titleLabel];
    
    //返回按钮
    UIImage *back_image = [UIImage imageNamed:@"Bt_Back.png"];
    UIButton *back_button = [[UIButton alloc] initWithFrame:CGRectMake(RightButtonBoderWidth, (44-back_image.size.height/2)/2, back_image.size.width/2, back_image.size.height/2)];
    [back_button addTarget:self action:@selector(clicked_back) forControlEvents:UIControlEventTouchUpInside];
    [back_button setBackgroundImage:imge forState:UIControlStateHighlighted];
    [back_button setImage:back_image forState:UIControlStateNormal];
    [nbar addSubview:back_button];
    
    CGRect table_rect = CGRectMake(0, 44, 320, TableViewHeight);
	table_view = [[[UITableView alloc] initWithFrame:table_rect style:UITableViewStylePlain] autorelease];
    table_view.allowsSelectionDuringEditing = YES;
    table_view.dataSource=self;
    table_view.delegate=self;
    [self.view addSubview:table_view];
    [table_view setBackgroundColor:[UIColor whiteColor]];
    [table_view setBackgroundView:nil];
    //请求文件目录
    photo_manager = [[SCBPhotoManager alloc] init];
    [photo_manager setNewFoldDelegate:self];
    
    share_manager = [[SCBShareManager alloc] init];
    [share_manager setDelegate:self];
    
    if([space_id isEqualToString:@"1"])
    {
        //打开文件目录
        [photo_manager openFinderWithID:f_id space_id:[[SCBSession sharedSession] spaceID]];
        self.space_id = [NSString stringWithFormat:@"%@",[[SCBSession sharedSession] spaceID]];
    }
    else if([space_id isEqualToString:@"2"])
    {
        //打开文件共享目录
        [share_manager openFinderWithID:f_id shareType:@"O"];
    }
    else if([space_id isEqualToString:@"3"])
    {
        //打开文件共享目录
        [share_manager openFinderWithID:f_id shareType:@"M"];
    }
    else
    {
        //打开家庭空间目录
        [photo_manager openFinderWithID:f_id space_id:space_id];
    }
    AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(![app_delegate.myTabBarController IsTabBarHiden])
    {
        [app_delegate.myTabBarController setHidesTabBarWithAnimate:YES];
    }
    
    //添加底部视图
    NSLog(@"BottonViewHeight:%f",BottonViewHeight);
    bottonView = [[UIView alloc] initWithFrame:CGRectMake(0, BottonViewHeight, 320, 60)];
    UIImageView *botton_image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, bottonView.frame.size.width, bottonView.frame.size.height)];
    [botton_image setImage:[UIImage imageNamed:@"Bk_Nav.png"]];
    [bottonView addSubview:botton_image];
    [botton_image release];
    
    UIButton *upload_button = [[UIButton alloc] initWithFrame:CGRectMake((320/2-29)/2, (TabBarHeight-29)/2, 29, 29)];
    [upload_button setBackgroundImage:[UIImage imageNamed:@"Bt_UploadOk.png"] forState:UIControlStateNormal];
    [upload_button setBackgroundImage:[UIImage imageNamed:@"Bt_UploadOkCh.png"] forState:UIControlStateHighlighted];
    [upload_button addTarget:self action:@selector(clicked_changeMyFile) forControlEvents:UIControlEventTouchUpInside];
    [bottonView addSubview:upload_button];
    [upload_button release];
    
    UIButton *upload_back_button = [[UIButton alloc] initWithFrame:CGRectMake(320/2+(320/2-29)/2, (TabBarHeight-29)/2, 29, 29)];
    [upload_back_button setBackgroundImage:[UIImage imageNamed:@"Bt_UploadCancle.png"] forState:UIControlStateNormal];
    [upload_back_button setBackgroundImage:[UIImage imageNamed:@"Bt_UploadCancleCh.png"] forState:UIControlStateHighlighted];
    [upload_back_button addTarget:self action:@selector(clicked_uploadStop) forControlEvents:UIControlEventTouchUpInside];
    [bottonView addSubview:upload_back_button];
    [upload_back_button release];
    
    [self.view addSubview:bottonView];
}

-(void)clicked_back
{
    [self.navigationController popViewControllerAnimated:YES];
    AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app_delegate.title_string removeLastObject];
}

-(void)clicked_changeMyFile
{
    AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(isAutomatic)
    {
        app_delegate.maticUpload.space_id = self.space_id;
        if([app_delegate.title_string count] > 0)
        {
            NSMutableString *table_str = [[[NSMutableString alloc] init] autorelease];
            for(NSString *name in app_delegate.title_string)
            {
                if([table_str length]>0)
                {
                    [table_str appendString:@"/"];
                }
                [table_str appendFormat:@"%@",name];
            }
            NSLog(@"app_delegate:%@",table_str);
            UserInfo *info = [[UserInfo alloc] init];
            info.keyString = @"自动备份目录";
            info.f_id = [self.f_id intValue];
            info.descript = [[[NSString alloc] initWithString:table_str] autorelease];
            [info updateUserinfo];
            [info release];
        }
        
        if([self.navigationController.viewControllers count]>1)
        {
            SelectDetailViewController *delailview = [self.navigationController.viewControllers objectAtIndex:1];
            if(delailview)
            {
                [self.navigationController popToViewController:delailview animated:YES];
            }
        }
        [app_delegate.myTabBarController setHidesTabBarWithAnimate:NO];
    }
    else
    {
        if(self.delegate)
        {
            [self.delegate setFileSpace:space_id withFileFID:self.f_id];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
    
    
}

-(void)clicked_uploadStop
{
    AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if([app_delegate.title_string count])
    {
        [app_delegate.title_string removeAllObjects];
    }
    if([self.navigationController.viewControllers count]>1)
    {
        SelectDetailViewController *delailview = [self.navigationController.viewControllers objectAtIndex:1];
        if(delailview)
        {
            [self.navigationController popToViewController:delailview animated:YES];
        }
    }
    [app_delegate.myTabBarController setHidesTabBarWithAnimate:NO];
}

#pragma mark UITableVieDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [table_array count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellString = @"selectDetailCell";
    UITableViewCell *cell = [table_view dequeueReusableCellWithIdentifier:cellString];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellString];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.imageView.image = [UIImage imageNamed:@""];
    }
    int row = [indexPath row];
    if(row < [table_array count])
    {
        NSDictionary *this=(NSDictionary *)[table_array objectAtIndex:row];
        NSString *name= [this objectForKey:@"f_name"];
        NSString *f_modify=[this objectForKey:@"f_modify"];
        cell.textLabel.text=name;
        cell.detailTextLabel.text=f_modify;
        cell.imageView.image = [UIImage imageNamed:@"Ico_FolderF.png"];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    if(row < [table_array count])
    {
        NSDictionary *this=(NSDictionary *)[table_array objectAtIndex:row];
        NSString *fid = [this objectForKey:@"f_id"];
        NSString *f_name = [this objectForKey:@"f_name"];
        AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app_delegate.title_string addObject:f_name];
        SelectDetailViewController *select_detailview = [[SelectDetailViewController alloc] init];
        select_detailview.space_id = self.space_id;
        select_detailview.isAutomatic = isAutomatic;
        select_detailview.f_id = [NSString stringWithFormat:@"%@",fid];
        select_detailview.title_string = [NSString stringWithFormat:@"%@",f_name];
        select_detailview.delegate = self;
        [self.navigationController pushViewController:select_detailview animated:YES];
        [select_detailview release];
    }
    
}

-(void)newFold:(NSDictionary *)dictionary
{
    
}

-(void)openFile:(NSDictionary *)dictionary
{
    NSLog(@"openFinderSucess datadic:%@",dictionary);
    [table_array removeAllObjects];
    NSString *UserName = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"usr_name"]];
    int index = [[dictionary objectForKey:@"code"] intValue];
    if(index == 0)
    {
        NSArray *array = [dictionary objectForKey:@"files"];
        for (NSDictionary *diction in array) {
            NSString *directory = [diction objectForKey:@"f_mime"];
            NSString *f_owner_name = [NSString stringWithFormat:@"%@",[diction objectForKey:@"f_owner_name"]];
            if([directory isEqualToString:@"directory"] && [f_owner_name isEqualToString:UserName])
            {
                [table_array addObject:diction];
            }
        }
    }
    [table_view reloadData];
}

#pragma mark ----------- SCBShareManagerDelegate
-(void)openFinderSucess:(NSDictionary *)dictionary
{
    NSLog(@"openFinderSucess datadic:%@",dictionary);
    [table_array removeAllObjects];
    
    int index = [[dictionary objectForKey:@"code"] intValue];
    if(index == 0)
    {
        NSArray *array = [dictionary objectForKey:@"files"];
        for (NSDictionary *diction in array) {
            NSString *directory = [diction objectForKey:@"f_mime"];
            if([directory isEqualToString:@"directory"])
            {
                [table_array addObject:diction];
            }
        }
    }
    [table_view reloadData];
}

-(void)setFileSpace:(NSString *)spaceID withFileFID:(NSString *)fID
{
    if(self.delegate)
    {
        [self.delegate setFileSpace:spaceID withFileFID:fID];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
