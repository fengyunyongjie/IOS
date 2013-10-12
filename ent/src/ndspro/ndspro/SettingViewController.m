//
//  SettingViewController.m
//  ndspro
//
//  Created by fengyongning on 13-9-26.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "SettingViewController.h"
#import "AppDelegate.h"
#import "APService.h"
#import "SCBAccountManager.h"
#import "YNFunctions.h"
#import "PConfig.h"
typedef enum{
    kActionSheetTypeExit,
    kActionSheetTypeClear,
    kActionSheetTypeWiFi,
    kActionSheetTypeAuto,
    kActionSheetTypeHideFeature,
}kActionSheetType;
@interface SettingViewController ()<SCBAccountManagerDelegate>
{
    BOOL isHideTabBar;
    float oldTabBarHeight;
}
@property (strong,nonatomic) NSString *nickname;
@property (strong,nonatomic) NSString *space_total;
@property (strong,nonatomic) NSString *space_used;
@end

@implementation SettingViewController

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
    // Do any additional setup after loading the view from its nib.
    self.tableView=[[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.view addSubview:self.tableView];
    self.tableView.frame=CGRectMake(0, 64, self.view.frame.size.width, [[UIScreen mainScreen] bounds].size.height-49-64);
    //[self.tableView setBackgroundColor:[UIColor whiteColor]];
    
    self.space_used=@"";
    self.space_total=@"";
    
    UIButton *exitButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [exitButton setTitle:@"退出登录" forState:UIControlStateNormal];
    [exitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [exitButton setBackgroundColor:[UIColor redColor]];
    //[exitButton setBackgroundImage:[UIImage imageNamed:@"Bt_Filter.png"] forState:UIControlStateNormal];
    //[exitButton setBackgroundImage:[UIImage imageNamed:@"btn_quit_on.png"] forState:UIControlStateHighlighted];
    int y=self.tableView.frame.size.height-30;
    y=608;
    [exitButton setFrame:CGRectMake(10, y, 301, 50)];
    [exitButton addTarget:self action:@selector(exitAccount:) forControlEvents:UIControlEventTouchUpInside];
    [self.tableView addSubview:exitButton];
    [self.tableView bringSubviewToFront:exitButton];

}
-(void)viewDidAppear:(BOOL)animated
{
    [self updateData];
    [self calcCacheSize];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)updateData
{
//    [[SCBAccountManager sharedManager] currentUserSpace];
//    [[SCBAccountManager sharedManager] setDelegate:self];
//    SCBAccountManager *am=[[SCBAccountManager alloc] init];
//    [am setDelegate:self];
//    [am currentProfile];
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
- (IBAction)hideTabBar:(id)sender
{
    isHideTabBar=!isHideTabBar;
    for(UIView *view in self.tabBarController.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            if (isHideTabBar) { //if hidden tabBar
                [view setFrame:CGRectMake(view.frame.origin.x,[[UIScreen mainScreen]bounds].size.height, view.frame.size.width, view.frame.size.height)];
            }else {
                NSLog(@"isHideTabBar %@",NSStringFromCGRect(view.frame));
                [view setFrame:CGRectMake(view.frame.origin.x, [[UIScreen mainScreen]bounds].size.height-49, view.frame.size.width, view.frame.size.height)];
            }
        }else
        {
            if (isHideTabBar) {
                NSLog(@"%@",NSStringFromCGRect(view.frame));
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, [[UIScreen mainScreen]bounds].size.height)];
                NSLog(@"%@",NSStringFromCGRect(view.frame));
            }else {
                NSLog(@"%@",NSStringFromCGRect(view.frame));
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width,[[UIScreen mainScreen]bounds].size.height-49)];
            } 
        }
    }
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
//                if(![self isConnection])
//                {
//                    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//                    [appleDate.autoUpload setIsStopCurrUpload:YES];
//                }
//                
//                if ([YNFunctions networkStatus]==ReachableViaWWAN) {
//                    [[FavoritesData sharedFavoritesData] stopDownloading];
//                }
            }
            NSLog(@"打开或关闭仅Wifi:: %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"switch_flag"]);
        }
            break;
        case 3:
        {
            UISwitch *theSwith = (UISwitch *)sender;
            NSString *onStr = [NSString stringWithFormat:@"%d",theSwith.on];
            if (![YNFunctions isOnlyWifi] && ![YNFunctions isAutoUpload]) {
                //                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                //                                                                    message:@"这可能会产生流量费用，您是否要继续？"
                //                                                                   delegate:self
                //                                                          cancelButtonTitle:@"取消"
                //                                                          otherButtonTitles:@"继续", nil];
                //                alertView.tag=kAlertTypeAuto;
                //                [alertView show];
                //                [alertView release];
                UIActionSheet *actionSheet=[[UIActionSheet alloc]  initWithTitle:@"这可能会产生流量费用，您是否要继续？" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"继续" otherButtonTitles: nil];
                [actionSheet setTag:kActionSheetTypeAuto];
                [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
                [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
            }else
            {
                [[NSUserDefaults standardUserDefaults]setObject:onStr forKey:@"isAutoUpload"];
                AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                if([onStr isEqualToString:@"0"])
                {
//                    [appleDate.maticUpload colseAutomaticUpload];
                }
                else
                {
//                    [appleDate.maticUpload startAutomaticUpload];
                }
            }
            NSLog(@"打开或关闭自动上传:: %@ ",[[NSUserDefaults standardUserDefaults] objectForKey:@"isAutoUpload"]);
        }
            break;
        default:
            break;
    }
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
- (IBAction)exitAccount:(id)sender
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
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 3;
            break;
        case 1:
            return 4;
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *itemTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 12, 280, 20)];
        itemTitleLabel.tag = 1;
        itemTitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        [cell.contentView addSubview:itemTitleLabel];
        itemTitleLabel.backgroundColor= [UIColor clearColor];
        
        UILabel *descTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 12, 280, 20)];
        descTitleLabel.textAlignment = UITextAlignmentRight;
        descTitleLabel.tag = 2;
        descTitleLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
        [cell.contentView addSubview:descTitleLabel];
        descTitleLabel.backgroundColor= [UIColor clearColor];
        
        
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
            
            
            descLabel.hidden = YES;
            titleLabel.textAlignment = UITextAlignmentLeft;
            switch (row) {
                case 3:
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
                    
                    m_switch.hidden = YES;
                    NSString *switchFlag = [[NSUserDefaults standardUserDefaults] objectForKey:@"isAutoUpload"];
                    if (switchFlag==nil) {
                        m_switch.on = NO;
                    }
                    else{
                        m_switch.on = [switchFlag boolValue];
                    }
                }
                    break;
                case 0:
                {
                    titleLabel.text = @"仅在Wi-Fi下上传/下载";
                    NSString *switchFlag = [[NSUserDefaults standardUserDefaults] objectForKey:@"switch_flag"];
                    automicOff_button.hidden = NO;
                    if (switchFlag==nil) {
//                        UserInfo *info = [[[UserInfo alloc] init] autorelease];
//                        info.user_name = [[SCBSession sharedSession] userName];
//                        NSMutableArray *array = [info selectAllUserinfo];
//                        if([array count]>0)
//                        {
//                            UserInfo *userInfo = [array objectAtIndex:0];
//                            m_switch.on = userInfo.is_oneWiFi;
//                        }
//                        else
//                        {
//                            m_switch.on = YES;
//                        }
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
            cell.hidden = YES;
            break;
        default:
            break;
    }
    
    
    
    return cell;
}
#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch ([actionSheet tag]) {
        case kActionSheetTypeExit:
            if (buttonIndex == 0) {
                //scBox.UserLogout(callBackLogoutFunc,self);

                
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"usr_name"];
                [[NSUserDefaults standardUserDefaults] setObject:nil  forKey:@"usr_pwd"];
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"switch_flag"];
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"isAutoUpload"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [APService setTags:nil alias:nil];
                
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate finishLogout];
            }
            break;
        case kActionSheetTypeClear:
            break;
        case kActionSheetTypeWiFi:
            break;
        case kActionSheetTypeAuto:
            break;
        case kActionSheetTypeHideFeature:
            break;
        default:
            break;
    }
    
}

@end
