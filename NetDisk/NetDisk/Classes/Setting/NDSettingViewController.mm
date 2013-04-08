//
//  NDSettingViewController.m
//  NetDisk
//
//  Created by jiangwei on 12-11-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NDSettingViewController.h"
void callBackUserSpaceFunc(Value &jsonValue,void *s_pv);
void callBackUserProfileFunc(Value &jsonValue,void *s_pv);
void callBackLogoutFunc(Value &jsonValue,void *s_pv);

@implementation NDSettingViewController
@synthesize m_tableView,m_exitButton;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        m_storeStr = nil;
    }
    return self;
}
- (void)dealloc
{
    [m_storeStr release];
    [super dealloc];
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"账户设置";
    
    m_exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [m_exitButton setTitle:@"退出登录" forState:UIControlStateNormal];
    [m_exitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [m_exitButton setBackgroundImage:[UIImage imageNamed:@"btn_quit"] forState:UIControlStateNormal];
 //   [m_exitButton setImage:[UIImage imageNamed:@"btn_quit"] forState:UIControlStateNormal];
 //   [m_exitButton setImage:[UIImage imageNamed:@"btn_quit_on"] forState:UIControlEventTouchDown];
    m_exitButton.frame = CGRectMake(10, 470, 301, 50);
    [m_exitButton addTarget:self action:@selector(exitAccount:) forControlEvents:UIControlEventTouchUpInside];
    [m_tableView addSubview:m_exitButton];
    [m_tableView bringSubviewToFront:m_exitButton];
    
    m_hud = [[ATMHud alloc] initWithDelegate:self];
	[self.view addSubview:m_hud.view];
    
    [m_hud setCaption:@"正在查询空间容量..."];
    [m_hud setActivity:YES];
    [m_hud show];

    [self performSelectorInBackground:@selector(getUserSpaceOp) withObject:nil];
}
- (void)getUserSpaceOp
{
    scBox.GetUsrSpace(callBackUserSpaceFunc,self);
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    

}
- (IBAction)comeBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)exitAccount:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"警告"
                                                        message:@"确定要退出登录" 
                                                       delegate:self 
                                              cancelButtonTitle:@"取消" 
                                              otherButtonTitles:@"退出", nil];
    [alertView show];
    [alertView release];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
  //  return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return NO;
}
#pragma mark - UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        scBox.UserLogout(callBackLogoutFunc,self);
    }
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [m_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section==1) {
        if (indexPath.row==2) {
            [m_hud setCaption:@"正在为您释放缓存"];
            [m_hud setActivity:YES];
            [m_hud show];
            [self clearCache];
            [self performSelector:@selector(hiddenHUD) withObject:nil afterDelay:0.5f];
            [m_tableView reloadData];
        }
    }
    if (indexPath.section==2)
    {
        if (indexPath.row==1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/hong-pan/id618660630?ls=1&mt=8"]];
        }
    }
}
- (void)hiddenHUD
{
    [m_hud setActivity:NO];
    [m_hud setCaption:@"释放完成"];
    [m_hud setImage:[UIImage imageNamed:@"19-check"]];
    [m_hud update];
    [m_hud hideAfter:1.3f];
}
- (void)clearCache
{
    [[NSFileManager defaultManager] removeItemAtPath:[Function getImgCachePath] error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:[Function getTempCachePath] error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:[Function getUploadTempPath] error:nil];
    NSString *_cachePath = [Function getImgCachePath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:_cachePath]) 
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:_cachePath 
                                  withIntermediateDirectories:YES 
                                                   attributes:nil 
                                                        error:nil];       
    }
    _cachePath = [Function getTempCachePath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:_cachePath]) 
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:_cachePath 
                                  withIntermediateDirectories:YES 
                                                   attributes:nil 
                                                        error:nil];       
    }
    _cachePath = [Function getUploadTempPath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:_cachePath]) 
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:_cachePath 
                                  withIntermediateDirectories:YES 
                                                   attributes:nil 
                                                        error:nil];       
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma mark - UITableViewDataSource Methods

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
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 2;
            break;
        case 1:
            return 3;
            break;
        case 2:
            return 2;
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
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
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
                    titleLabel.text = @"网盘用量";
                    descLabel.text = m_storeStr;
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
            
            
            UISwitch *m_switch = [[UISwitch alloc] initWithFrame:CGRectMake(210, 10, 40, 29)];
            [m_switch addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
            m_switch.on = YES;
            m_switch.tag = row;
            [cell.contentView addSubview:m_switch];
            [m_switch release];
            
            descLabel.hidden = YES;
            titleLabel.textAlignment = UITextAlignmentLeft;
            switch (row) {
                case 0:
                {
                    titleLabel.text = @"仅在连接WIFI时上传";
                    NSString *switchFlag = [[NSUserDefaults standardUserDefaults] objectForKey:@"switch_flag"];
                    if (switchFlag==nil) {
                        m_switch.on = YES;
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
                    NSArray*paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
                    NSString *cachePath=[paths objectAtIndex:0]; 
                    
                    double locationCacheSize = 0.0f;// [Function getDirectorySizeForPath:cachePath];
                    cachePath = [Function getImgCachePath];
                    locationCacheSize += [Function getDirectorySizeForPath:cachePath];
                    cachePath = [Function getTempCachePath];
                    locationCacheSize += [Function getDirectorySizeForPath:cachePath];
                    cachePath = [Function getKeepCachePath];
                    locationCacheSize += [Function getDirectorySizeForPath:cachePath];
                    cachePath = [Function getUploadTempPath];
                    locationCacheSize += [Function getDirectorySizeForPath:cachePath];
                    
                    
                    NSString *sizeStr = [NSString stringWithFormat:@"%f",locationCacheSize];
                    descLabel.text = [Function convertSize:sizeStr];
                    descLabel.textColor = [UIColor grayColor];
                    
                    m_switch.hidden = YES;
                }
                    
                    break;
                case 2:
                    
                    
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
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
                    descLabel.text = @"V1.0.2";
                    break;
                case 1:
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    descLabel.hidden = YES;
                    titleLabel.text = @"评分";
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
- (void)switchChange:(id)sender
{
    UISwitch *theSwith = (UISwitch *)sender;
    NSString *onStr = [NSString stringWithFormat:@"%d",theSwith.on];
    [[NSUserDefaults standardUserDefaults]setObject:onStr forKey:@"switch_flag"];
}


#pragma mark - callBack Methods
void callBackUserSpaceFunc(Value &jsonValue,void *s_pv)
{
    string vall = jsonValue.toStyledString().c_str();
    NSString *vallStr = [NSString stringWithCString:vall.c_str() encoding:NSUTF8StringEncoding];
    [s_pv showUserSpaceView:vallStr];
    /*
    int code = jsonValue["code"].asInt();
    if (code == 0) {
        string totalStr = jsonValue["space_total"].asCString();
        string usedStr = jsonValue["space_used"].asCString();
        [((NDSettingViewController *)s_pv).m_tableView reloadData];
    }
    else
    {
        
    }*/
}
void callBackUserProfileFunc(Value &jsonValue,void *s_pv)
{
    string vall = jsonValue.toStyledString().c_str();
    NSString *vallStr = [NSString stringWithCString:vall.c_str() encoding:NSUTF8StringEncoding];
    [s_pv showUserProfileView:vallStr];
}
void callBackLogoutFunc(Value &jsonValue,void *s_pv)
{
    int a = jsonValue["code"].asInt();
    [s_pv logoutForView:a];
}

#pragma mark - Pri Methods
- (void)showUserSpaceView:(NSString *)theData
{
    NSDictionary *valueDic = [theData JSONValue];
    
    int code = [[valueDic objectForKey:@"code"]intValue];
    if (code==0) {
        double totalStr = [[valueDic objectForKey:@"space_total"] doubleValue]/1024/1024/1024;
        double usedStr = [[valueDic objectForKey:@"space_used"] doubleValue]/1024/1024/1024;
        
        m_storeStr = [[NSString stringWithFormat:@"%.2fG / %.0fG",usedStr,totalStr] retain];
        [m_tableView reloadData];
    }
    else{
        [m_hud setActivity:NO];
        [m_hud setCaption:@"查询空间失败"];
        [m_hud setImage:[UIImage imageNamed:@"11-x"]];
        [m_hud update];
    }
    
    [self performSelectorOnMainThread:@selector(hiddenHub) withObject:nil waitUntilDone:NO];
}
- (void)hiddenHub
{
    [m_hud hideAfter:1.2f];
}
- (void)showUserProfileView:(NSString *)theData
{
    NSDictionary *valueDic = [theData JSONValue];
    
    int code = [[valueDic objectForKey:@"code"]intValue];
    if (code==0) {
        
        [m_tableView reloadData];
    }
    else{
        [m_hud setCaption:@"查询用户信息失败"];
        [m_hud setImage:[UIImage imageNamed:@"11-x"]];
        [m_hud update];
    }
 
    [self performSelectorOnMainThread:@selector(hiddenHub) withObject:nil waitUntilDone:NO];
}
- (void)logoutForView:(int)success
{
    if (success == 0) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"usr_name"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"usr_pwd"];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else{
        [m_hud setCaption:@"退出失败"];
        [m_hud setImage:[UIImage imageNamed:@"11-x"]];
        [m_hud show];
        [m_hud hideAfter:0.8];
    }

}
@end
