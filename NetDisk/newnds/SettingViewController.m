//
//  SettingViewController.m
//  NetDisk
//
//  Created by fengyongning on 13-4-28.
//
//

#import "SettingViewController.h"
#import "SCBAccountManager.h"
#import "YNFunctions.h"
#import "AppDelegate.h"
#import "UploadViewController.h"
#import "FavoritesData.h"
#import "DBSqlite3.h"
#import "ReportViewController.h"
#import "AutomicUploadViewController.h"
#import "PConfig.h"
#import "UserInfo.h"
#import "NSString+Format.h"
#import "SCBSession.h"
#import "APService.h"
#import "MASettingViewController.h"

#define OFFButtonHeight 25
#define OFFBorderWidth 20

#define OFFImageWidth 70
#define OFFImageHeight 33
#define OFFCurrWidth OFFImageWidth*OFFButtonHeight/OFFImageHeight
#define OFFCurrX 320-OFFCurrWidth-OFFBorderWidth
#define OFFCurrY (40-OFFButtonHeight)/2
#define OFFButtonRect CGRectMake(OFFCurrX, OFFCurrY, OFFCurrWidth, OFFButtonHeight)

typedef enum{
    kAlertTypeExit,
    kAlertTypeClear,
    kAlertTypeWiFi,
    kAlertTypeAuto,
    kAlertTypeHideFeature,
}kAlertType;
typedef enum{
    kActionSheetTypeExit,
    kActionSheetTypeClear,
    kActionSheetTypeWiFi,
    kActionSheetTypeAuto,
    kActionSheetTypeHideFeature,
}kActionSheetType;
@interface SettingViewController ()
@property (strong,nonatomic) NSString *space_total;
@property (strong,nonatomic) NSString *space_used;
@property (assign,nonatomic) int tempCount;
@property (strong,nonatomic) UILabel *titleLabel;
@property (strong,nonatomic) NSString *nickname;
@end

@implementation SettingViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIView *nbar=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    UIImageView *niv=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Bk_Title.png"]];
    niv.frame=nbar.frame;
    [nbar addSubview:niv];
    [self.view addSubview: nbar];
    
    //标题
    self.titleLabel=[[UILabel alloc] init];
    self.titleLabel.text=self.title;
    self.titleLabel.font=[UIFont boldSystemFontOfSize:18];
    self.titleLabel.textAlignment=UITextAlignmentCenter;
    self.titleLabel.backgroundColor=[UIColor clearColor];
    self.titleLabel.frame=CGRectMake(60, 0, 200, 44);
    [nbar addSubview:self.titleLabel];

    self.tableView=[[[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped] autorelease];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    [self.view addSubview:self.tableView];
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    [self.tableView setBackgroundView:nil];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.space_used=@"";
    self.space_total=@"";
    UIButton *exitButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [exitButton setTitle:@"退出登录" forState:UIControlStateNormal];
    [exitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //[exitButton setBackgroundColor:[UIColor redColor]];
    [exitButton setBackgroundImage:[UIImage imageNamed:@"Bt_Filter.png"] forState:UIControlStateNormal];
    //[exitButton setBackgroundImage:[UIImage imageNamed:@"btn_quit_on.png"] forState:UIControlStateHighlighted];
    int y=self.tableView.frame.size.height-30;
    y=608;
    [exitButton setFrame:CGRectMake(10, y, 301, 50)];
    [exitButton addTarget:self action:@selector(exitAccount:) forControlEvents:UIControlEventTouchUpInside];
    [exitButton setTag:10000];
    [self.tableView addSubview:exitButton];
    [self.tableView bringSubviewToFront:exitButton];
}
-(void)viewWillAppear:(BOOL)animated
{
    self.titleLabel.text=self.title;
    self.tempCount=0;
    CGRect r=self.view.frame;
    r.origin.y=44;
    r.size.height=self.view.frame.size.height-44-60;
    self.tableView.frame=r;
}
-(void)viewWillDisappear:(BOOL)animated
{
    self.tempCount=0;
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateData];
    [self calcCacheSize];
}
-(void)updateData
{
    [[SCBAccountManager sharedManager] currentUserSpace];
    [[SCBAccountManager sharedManager] setDelegate:self];
    SCBAccountManager *am=[[SCBAccountManager alloc] init];
    [am setDelegate:self];
    [am currentProfile];
}
-(void)spaceSucceedUsed:(NSString *)space_used total:(NSString *)space_total
{
    self.space_total=[YNFunctions convertSize:space_total];
    self.space_used=[YNFunctions convertSize:space_used];
    [self.tableView reloadData];
}
-(void)nicknameSucessed:(NSString *)nickname
{
    self.nickname=nickname;
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)switchChange:(id)sender
{
    int tag=[(UISwitch*)sender tag];
    switch (tag) {
        case 0:
        {
            UISwitch *theSwith = (UISwitch *)sender;
            NSString *onStr = [NSString stringWithFormat:@"%d",theSwith.on];
            if ([YNFunctions isOnlyWifi]) {
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
//                                                                    message:@"这可能会产生流量费用，您是否要继续？"
//                                                                   delegate:self
//                                                          cancelButtonTitle:@"取消"
//                                                          otherButtonTitles:@"继续", nil];
//                alertView.tag=kAlertTypeWiFi;
//                [alertView show];
//                [alertView release];
                UIActionSheet *actionSheet=[[UIActionSheet alloc]  initWithTitle:@"这可能会产生流量费用，您是否要继续？" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"继续" otherButtonTitles: nil];
                [actionSheet setTag:kActionSheetTypeWiFi];
                [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
                [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
            }else
            {
                [YNFunctions setIsOnlyWifi:YES];
                if(![self isConnection])
                {
                    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    [appleDate.autoUpload setIsStopCurrUpload:YES];
                }
               
                if ([YNFunctions networkStatus]==ReachableViaWWAN) {
                    [[FavoritesData sharedFavoritesData] stopDownloading];
                }
            }
            NSLog(@"打开或关闭仅Wifi:: %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"switch_flag"]);
        }
            break;
        case 3:
        {
            UISwitch *theSwith = (UISwitch *)sender;
            if (theSwith.on) {
                //开启消息提醒
                NSLog(@"开启消息提醒");
            }else
            {
                NSLog(@"关闭消息提醒");
            }
            [YNFunctions setIsAlertMessage:theSwith.on];
            if ([YNFunctions isAlertMessage]) {
                // Required
                [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                               UIRemoteNotificationTypeSound |
                                                               UIRemoteNotificationTypeAlert)];
                
                NSString *alias=[NSString stringWithFormat:@"%@",[[SCBSession sharedSession] spaceID]];
                NSSet *tags=[NSSet setWithArray:[YNFunctions selectFamily]];
                
                [APService setTags:tags alias:alias];
                NSLog(@"设置标签和别名成功,\n别名：%@\n标签：%@",alias,tags);
            }else
            {
                [APService setTags:nil alias:nil];
                [[UIApplication sharedApplication] unregisterForRemoteNotifications];
            }
        }
            break;
//        case 3:
//        {
//            UISwitch *theSwith = (UISwitch *)sender;
//            NSString *onStr = [NSString stringWithFormat:@"%d",theSwith.on];
//            if (![YNFunctions isOnlyWifi] && ![YNFunctions isAutoUpload]) {
////                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
////                                                                    message:@"这可能会产生流量费用，您是否要继续？"
////                                                                   delegate:self
////                                                          cancelButtonTitle:@"取消"
////                                                          otherButtonTitles:@"继续", nil];
////                alertView.tag=kAlertTypeAuto;
////                [alertView show];
////                [alertView release];
//                UIActionSheet *actionSheet=[[UIActionSheet alloc]  initWithTitle:@"这可能会产生流量费用，您是否要继续？" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"继续" otherButtonTitles: nil];
//                [actionSheet setTag:kActionSheetTypeAuto];
//                [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
//                [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
//            }else
//            {
//                [[NSUserDefaults standardUserDefaults]setObject:onStr forKey:@"isAutoUpload"];
//                AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//                if([onStr isEqualToString:@"0"])
//                {
//                    [appleDate.maticUpload colseAutomaticUpload];
//                }
//                else
//                {
//                    [appleDate.maticUpload startAutomaticUpload];
//                }
//            }
//            NSLog(@"打开或关闭自动上传:: %@ ",[[NSUserDefaults standardUserDefaults] objectForKey:@"isAutoUpload"]);
//        }
//            break;
        default:
            break;
    }
}
- (void)exitAccount:(id)sender
{
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
//                                                        message:@"确定要退出登录"
//                                                       delegate:self
//                                              cancelButtonTitle:@"取消"
//                                              otherButtonTitles:@"退出", nil];
//    [alertView show];
//    [alertView setTag:kAlertTypeExit];
//    [alertView release];
    UIActionSheet *actionSheet=[[UIActionSheet alloc]  initWithTitle:@"确定要退出登录" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"退出" otherButtonTitles: nil];
    [actionSheet setTag:kActionSheetTypeExit];
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
}
- (void)clearCache
{
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
//                                                        message:@"确定要清除缓存"
//                                                       delegate:self
//                                              cancelButtonTitle:@"取消"
//                                              otherButtonTitles:@"确定", nil];
//    [alertView show];
//    [alertView setTag:kAlertTypeClear];
//    [alertView release];
    UIActionSheet *actionSheet=[[UIActionSheet alloc]  initWithTitle:@"确定要清除缓存" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"清除" otherButtonTitles: nil];
    [actionSheet setTag:kActionSheetTypeClear];
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
}
#pragma mark - UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case kAlertTypeExit:
            if (buttonIndex == 1) {
                //scBox.UserLogout(callBackLogoutFunc,self);
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"usr_name"];
                [[NSUserDefaults standardUserDefaults] setObject:nil  forKey:@"usr_pwd"];
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"switch_flag"];
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"isAutoUpload"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appleDate.maticUpload colseAutomaticUpload];
//                [DBSqlite3 cleanSql];
                [[FavoritesData sharedFavoritesData] stopDownloading];
                
                [self.rootViewController presendLoginViewController];
            }
            break;
        case kAlertTypeClear:
            if (buttonIndex==1) {
                [[NSFileManager defaultManager] removeItemAtPath:[YNFunctions getFMCachePath] error:nil];
                [[NSFileManager defaultManager] removeItemAtPath:[YNFunctions getIconCachePath] error:nil];
                [[NSFileManager defaultManager] removeItemAtPath:[YNFunctions getKeepCachePath] error:nil];
                [[NSFileManager defaultManager] removeItemAtPath:[YNFunctions getTempCachePath] error:nil];
                [[NSFileManager defaultManager] removeItemAtPath:[YNFunctions getProviewCachePath] error:nil];
                [self.tableView reloadData];
            }
            break;
        case kAlertTypeWiFi:
            if (buttonIndex==1) {
                [YNFunctions setIsOnlyWifi:NO];
                AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                if([YNFunctions isAutoUpload])
                {
                    [appleDate.maticUpload isHaveData];
                }
            }else
            {
                [YNFunctions setIsOnlyWifi:YES];
                AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appleDate.maticUpload colseAutomaticUpload];
            }
            [self.tableView reloadData];
            break;
        case kAlertTypeAuto:
            if (buttonIndex==1) {
                [YNFunctions setIsAutoUpload:YES];
                AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appleDate.maticUpload isHaveData];
            }else
            {
                [YNFunctions setIsAutoUpload:NO];
                AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appleDate.maticUpload colseAutomaticUpload];
            }
            [self.tableView reloadData];
            break;
        case kAlertTypeHideFeature:
        {
            if (buttonIndex==1) {
                [YNFunctions setIsOpenHideFeature:![YNFunctions isOpenHideFeature]];
            }
        }
            break;
        default:
            break;
    }
    
}
#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch ([actionSheet tag]) {
        case kActionSheetTypeExit:
            if (buttonIndex == 0) {
                
                [APService setTags:nil alias:nil];
                [[UIApplication sharedApplication] unregisterForRemoteNotifications];
                
                //scBox.UserLogout(callBackLogoutFunc,self);
                UserInfo *info = [[[UserInfo alloc] init] autorelease];
                info.user_name = [NSString formatNSStringForOjbect:[[SCBSession sharedSession] userName]];
                NSMutableArray *tableArray = [info selectAllUserinfo];
                if([tableArray count]>0)
                {
                    UserInfo *userInfo = [tableArray objectAtIndex:0];
                    info.f_id = userInfo.f_id;
                    info.auto_url = userInfo.auto_url;
                    info.space_id = userInfo.space_id;
                }
                else
                {
                    info.f_id = -1;
                    info.auto_url = [NSString stringWithFormat:@"手机照片/来自于-%@",[AppDelegate deviceString]];
                    info.space_id = [NSString formatNSStringForOjbect:[[SCBSession sharedSession] spaceID]];
                }
                info.is_autoUpload = [YNFunctions isAutoUpload];
                info.is_oneWiFi = [YNFunctions isOnlyWifi];
                
                [info insertUserinfo];
                [info cleanSql];
                [YNFunctions setIsAutoUpload:NO];
                AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [app_delegate.autoUpload stopAllUpload];
                [app_delegate.moveUpload stopAllUpload];
                
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"usr_name"];
                [[NSUserDefaults standardUserDefaults] setObject:nil  forKey:@"usr_pwd"];
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"switch_flag"];
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"isAutoUpload"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                UINavigationController *NavigationController = [[appleDate.myTabBarController viewControllers] objectAtIndex:2];
                ChangeUploadViewController *uploadView = (ChangeUploadViewController *)[NavigationController.viewControllers objectAtIndex:0];
                if([uploadView isKindOfClass:[ChangeUploadViewController class]])
                {
                    [uploadView escLoginList];
                }
                [[FavoritesData sharedFavoritesData] stopDownloading];
                [appleDate finishLogout];
            }
            break;
        case kActionSheetTypeClear:
            if (buttonIndex==0) {
                [[NSFileManager defaultManager] removeItemAtPath:[YNFunctions getFMCachePath] error:nil];
                [[NSFileManager defaultManager] removeItemAtPath:[YNFunctions getIconCachePath] error:nil];
                [[NSFileManager defaultManager] removeItemAtPath:[YNFunctions getKeepCachePath] error:nil];
                [[NSFileManager defaultManager] removeItemAtPath:[YNFunctions getTempCachePath] error:nil];
                [[NSFileManager defaultManager] removeItemAtPath:[YNFunctions getProviewCachePath] error:nil];
                [self calcCacheSize];
                [self.tableView reloadData];
            }
            break;
        case kActionSheetTypeWiFi:
            if (buttonIndex==0) {
                [YNFunctions setIsOnlyWifi:NO];
            }
            else
            {
                [YNFunctions setIsOnlyWifi:YES];
            }
            
            if([self isConnection] && [YNFunctions isAutoUpload])
            {
                AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appleDate.autoUpload start];
            }
            [self.tableView reloadData];
            break;
        case kActionSheetTypeAuto:
            if (buttonIndex==0) {
                [YNFunctions setIsAutoUpload:YES];
                AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appleDate.maticUpload isHaveData];
            }else
            {
                [YNFunctions setIsAutoUpload:NO];
                AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appleDate.maticUpload colseAutomaticUpload];
            }
            [self.tableView reloadData];
            break;
        case kActionSheetTypeHideFeature:
        {
            if (buttonIndex==0) {
                [YNFunctions setIsOpenHideFeature:![YNFunctions isOpenHideFeature]];
            }
        }
            break;
        default:
            break;
    }
    
}
#pragma mark - Table view data source
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	
    switch (section) {
        case 0:
            return @"账号信息";
            break;
        case 1:
            return @"设置";
            break;
        case 2:
            return @"关于";
            break;
        default:
            break;
    }
	return nil;
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 3;
            break;
        case 1:
            return 5;
            break;
        case 2:
            return 3;
            break;
        case 3:
            return 1;
            break;
            
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    // Configure the cell...
//    
//    return cell;
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *itemTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 12, 280, 20)];
        itemTitleLabel.tag = 1;
        itemTitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        [cell.contentView addSubview:itemTitleLabel];
        itemTitleLabel.backgroundColor= [UIColor clearColor];
        [itemTitleLabel release];
        
        UILabel *descTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 12, 280, 20)];
        descTitleLabel.textAlignment = UITextAlignmentRight;
        descTitleLabel.tag = 2;
        descTitleLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
        [cell.contentView addSubview:descTitleLabel];
        descTitleLabel.backgroundColor= [UIColor clearColor];
        [descTitleLabel release];
        
        
    }
    [cell setBackgroundColor:[UIColor colorWithRed:225/255.0f green:225/255.0f blue:225/255.0f alpha:1.0f]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    UILabel *titleLabel = (UILabel *)[cell.contentView  viewWithTag:1];
    UILabel *descLabel  = (UILabel *)[cell.contentView  viewWithTag:2];
    descLabel.hidden = NO;
    for(UIView *view in cell.contentView.subviews)
    {
        if ([view isKindOfClass:[UISwitch class]]) {
            [view removeFromSuperview];
        }
    }
    switch (section) {
        case 0:
        {
            titleLabel.textAlignment = UITextAlignmentLeft;
            switch (row) {
                case 0:
                {
                    titleLabel.text = @"当前用户";
                    descLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"usr_name"];
                    descLabel.textColor = [UIColor colorWithRed:0.0 green:0.4 blue:0.0 alpha:1.0];
                }
                    break;
                case 1:
                {
                    titleLabel.text = @"昵称";
//                    NSString *spaceInfo;
//                    if ([self.space_total isEqualToString:@""]) {
//                        spaceInfo=@"获取中...";
//                    }else
//                    {
//                        spaceInfo=[NSString stringWithFormat:@"%@/%@",self.space_used,self.space_total];
//                    }
//                    descLabel.text=spaceInfo;
//                    
                    descLabel.text=self.nickname;
                    descLabel.textColor = [UIColor grayColor];
                }
                    break;
                case 2:
                {
                    titleLabel.text = @"网盘用量";
                    NSString *spaceInfo;
                    if ([self.space_total isEqualToString:@""]) {
                        spaceInfo=@"获取中...";
                    }else
                    {
                        spaceInfo=[NSString stringWithFormat:@"%@/%@",self.space_used,self.space_total];
                    }
                    descLabel.text=spaceInfo;
                    descLabel.textColor = [UIColor grayColor];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            UISwitch *m_switch = [[UISwitch alloc] initWithFrame:CGRectMake(220, 10, 40, 29)];
            [m_switch setOnTintColor:[UIColor colorWithRed:255.0/255.0 green:180.0/255.0 blue:94.0/255.0 alpha:1.0]];
            [m_switch addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
            m_switch.on = YES;
            switchTag = row;
            m_switch.tag = row;
            [cell.contentView addSubview:m_switch];
            [m_switch release];
            
            
            descLabel.hidden = YES;
            titleLabel.textAlignment = UITextAlignmentLeft;
            switch (row) {
                case 4:
                {
                    //titleLabel.text = @"自动备份照片(Wi-Fi下,节省流量)";
                    //titleLabel.hidden=YES;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.textLabel.text=@"照片自动备份";
                    [cell.textLabel setFont:titleLabel.font];
                    cell.detailTextLabel.text=@"仅Wi-Fi下进行,节省流量";
                    [cell.detailTextLabel setFont:[UIFont fontWithName:cell.detailTextLabel.font.fontName size:9.0f]];
                    
                    CGRect label_rect = CGRectMake(240, 12, 40, 20);
                    UILabel *label = [[UILabel alloc] initWithFrame:label_rect];
                    label.font = cell.textLabel.font;
                    label.textColor = cell.textLabel.textColor;
                    label.textAlignment = NSTextAlignmentCenter;
                    label.backgroundColor = cell.textLabel.backgroundColor;
                    if([YNFunctions isAutoUpload])
                    {
                        label.text = @"开启";
                    }
                    else
                    {
                        label.text = @"关闭";
                    }
                    [cell addSubview:label];
                    [label release];
                    
                    m_switch.hidden = YES;
                    m_switch.on=[YNFunctions isAutoUpload];
                }
                    break;
                case 3:
                {
                    //titleLabel.text = @"自动备份照片(Wi-Fi下,节省流量)";
                    //titleLabel.hidden=YES;
                    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.textLabel.text=@"消息提醒设置";
                    [cell.textLabel setFont:titleLabel.font];
                    cell.detailTextLabel.text=@"";
                    [cell.detailTextLabel setFont:[UIFont fontWithName:cell.detailTextLabel.font.fontName size:9.0f]];
                    
                    CGRect label_rect = CGRectMake(240, 12, 40, 20);
                    UILabel *label = [[UILabel alloc] initWithFrame:label_rect];
                    label.font = cell.textLabel.font;
                    label.textColor = cell.textLabel.textColor;
                    label.textAlignment = NSTextAlignmentCenter;
                    label.backgroundColor = cell.textLabel.backgroundColor;
                    [label setHidden:YES];
                    automicOff_button.hidden = NO;
                    m_switch.on=[YNFunctions isAlertMessage];
                    [cell addSubview:label];
                    [label release];
                    
                    m_switch.hidden = NO;
                    m_switch.on=[YNFunctions isAlertMessage];
                }
                    break;
                case 0:
                {
                    titleLabel.text = @"仅在Wi-Fi下上传/下载";
                    NSString *switchFlag = [[NSUserDefaults standardUserDefaults] objectForKey:@"switch_flag"];
                    automicOff_button.hidden = NO;
                    if (switchFlag==nil) {
                        UserInfo *info = [[[UserInfo alloc] init] autorelease];
                        info.user_name = [[SCBSession sharedSession] userName];
                        NSMutableArray *array = [info selectAllUserinfo];
                        if([array count]>0)
                        {
                            UserInfo *userInfo = [array objectAtIndex:0];
                            m_switch.on = userInfo.is_oneWiFi;
                        }
                        else
                        {
                            m_switch.on = YES;
                        }
                    }
                    else{
                        m_switch.on = [switchFlag boolValue];
                    }
                    
                }
                    break;
                case 1:
                {
                    titleLabel.text = @"缓存占用";
                    descLabel.hidden = NO;
                    NSString *sizeStr = [NSString stringWithFormat:@"%f",locationCacheSize];
                    descLabel.text = [YNFunctions convertSize:sizeStr];
                    descLabel.textColor = [UIColor grayColor];
                    
                    m_switch.hidden = YES;
                }
                    
                    break;
                case 2:
                    
                    
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    descLabel.hidden = YES;
                    m_switch.hidden = YES;
                    titleLabel.text = @"清除缓存";
                    break;
                    /*       case 1:
                     titleLabel.text = @"更新照片时自动上传";
                     break;
                     case 2:
                     titleLabel.text = @"自动共享";
                     m_switch.on = NO;
                     break;
                     case 3:
                     cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                     cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                     titleLabel.text = @"选择自动共享目录";
                     m_switch.hidden = YES;
                     break;
                     */
                default:
                    break;
            }
        }
            break;
            /*        case 2:
             {
             cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
             cell.selectionStyle = UITableViewCellSelectionStyleBlue;
             descLabel.hidden = YES;
             titleLabel.textAlignment = UITextAlignmentLeft;
             titleLabel.text = @"传输管理";
             }
             break;
             */
        case 2:
        {
            
            titleLabel.textAlignment = UITextAlignmentLeft;
            switch (row) {
                case 0:
                    descLabel.hidden = NO;
                    titleLabel.text = @"版本";
                    descLabel.text = VERSION;
                    break;
                case 1:
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    descLabel.hidden = YES;
                    titleLabel.text = @"评分";
                    break;
                case 2:
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    descLabel.hidden = YES;
                    titleLabel.text = @"意见反馈";
                    break;
                default:
                    break;
            }
        }
            break;
        case 3:
        {
            cell.hidden = YES;
            //重设退出安钮位置
            UIButton *exitButton=(UIButton *)[self.tableView viewWithTag:10000];
            CGRect r=exitButton.frame;
            r.origin.y=self.tableView.contentSize.height-80;
            exitButton.frame=r;
        }
            break;
        default:
            break;
    }
    
    
    
    return cell;
}
-(void)calcCacheSize
{
    NSArray*paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *cachePath=[paths objectAtIndex:0];
    
    double cacheSize = 0.0f;// [Function getDirectorySizeForPath:cachePath];
    cachePath = [YNFunctions getFMCachePath];
    cacheSize += [YNFunctions getDirectorySizeForPath:cachePath];
    cachePath = [YNFunctions getIconCachePath];
    cacheSize += [YNFunctions getDirectorySizeForPath:cachePath];
    cachePath = [YNFunctions getKeepCachePath];
    cacheSize += [YNFunctions getDirectorySizeForPath:cachePath];
    cachePath = [YNFunctions getTempCachePath];
    cacheSize += [YNFunctions getDirectorySizeForPath:cachePath];
    cachePath = [YNFunctions getProviewCachePath];
    cacheSize += [YNFunctions getDirectorySizeForPath:cachePath];
    locationCacheSize=cacheSize;
}
-(void)closeSwitch
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(switchTag>0)
        {
            UISwitch *m_switch = (UISwitch *)[self.view viewWithTag:switchTag];
            if(!m_switch.isOn)
            {
                m_switch.on = YES;
                [self updateData];
            }
        }
    });
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    switch (section) {
            
        case 0:     //账号信息
        {
            switch (row) {
                case 0:
                {
                    //当前用户
                }
                    break;
                case 1:
                {
                    //网盘用量
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case 1:     //设置
        {
            switch (row) {
                case 0:
                {
                    
                }
                    break;
                case 1:
                {
                    //缓存占用
                }
                    
                    break;
                case 2:
                    //清除缓存
                    [self clearCache];
                    break;
                case 3:
                {
                    //占击消息设置
                    MASettingViewController *masViewCtrl=[[MASettingViewController alloc] init];
                    [self.navigationController pushViewController:masViewCtrl animated:YES];
                }
                case 4:
                {
                    //点击照片自动备份
                    AutomicUploadViewController *uploadview = [[AutomicUploadViewController alloc] init];
                    //                    ReportViewController *viewController=[[ReportViewController alloc] initWithNibName:@"ReportViewController" bundle:nil];
                    [self.navigationController pushViewController:uploadview animated:YES];
                }
                    break;
                default:
                    break;
            }
        }
            break;
            
        case 2:     //关于
        {
            
            switch (row) {
                case 0:
                    //版本
//                    self.tempCount++;
//                    if (self.tempCount>=6) {
//                        self.tempCount=0;
//                        if ([YNFunctions isOpenHideFeature]) {
//                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
//                                                                                message:@"是否关闭隐藏功能？"
//                                                                               delegate:self
//                                                                      cancelButtonTitle:@"取消"
//                                                                      otherButtonTitles:@"确定", nil];
//                            alertView.tag=kAlertTypeHideFeature;
//                            [alertView show];
//                            [alertView release];
//                        }else
//                        {
//                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
//                                                                                message:@"是否打开隐藏功能？"
//                                                                               delegate:self
//                                                                      cancelButtonTitle:@"取消"
//                                                                      otherButtonTitles:@"确定", nil];
//                            alertView.tag=kAlertTypeHideFeature;
//                            [alertView show];
//                            [alertView release];
//                        }
//                        
//                    }
                    break;
                case 1:
                    //评分
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/hong-pan/id618660630?ls=1&mt=8"]];
                    break;
                case 2:
                    //意见反馈
                {
//                    UIViewController *viewController=[[UIViewController alloc] init];
//                    [self.navigationController pushViewController:viewController animated:YES];
                    ReportViewController *viewController=[[ReportViewController alloc] initWithNibName:@"ReportViewController" bundle:nil];
                    [self.navigationController pushViewController:viewController animated:YES];
                }
                    break;
                default:
                    break;
            }
        }
            break;
            
        case 3:
            break;
        default:
            break;
    }
}



//判断当前的网络是3g还是wifi
-(BOOL) isConnection
{
    __block BOOL bl;
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    Reachability *hostReach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    switch ([hostReach currentReachabilityStatus]) {
        case NotReachable:
        {
//            netWorkState = 3;
            //"没有网络链接"
            bl = NO;
        }
            break;
        case ReachableViaWiFi:
        {
            // "WIFI";
//            netWorkState = 1;
            bl = YES;
        }
            break;
        case ReachableViaWWAN:
        {
            // @"WLAN";
//            netWorkState = 2;
            if([YNFunctions isOnlyWifi])
            {
                bl = NO;
            }
            else
            {
                bl = YES;
            }
        }
            break;
        default:
            break;
    }
    //    });
    return bl;
}


@end
