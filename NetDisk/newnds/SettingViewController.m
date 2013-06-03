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

typedef enum{
    kAlertTypeExit,
    kAlertTypeClear,
}kAlertType;

@interface SettingViewController ()
@property (strong,nonatomic) NSString *space_total;
@property (strong,nonatomic) NSString *space_used;
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
    [self setTableView:[[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped]];

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
    [exitButton setBackgroundImage:[UIImage imageNamed:@"btn_quit.png"] forState:UIControlStateNormal];
    [exitButton setBackgroundImage:[UIImage imageNamed:@"btn_quit_on.png"] forState:UIControlStateHighlighted];
    [exitButton setFrame:CGRectMake(10, 470, 301, 50)];
    [exitButton addTarget:self action:@selector(exitAccount:) forControlEvents:UIControlEventTouchUpInside];
    [self.tableView addSubview:exitButton];
    [self.tableView bringSubviewToFront:exitButton];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateData];
}
-(void)updateData
{
    [[SCBAccountManager sharedManager] currentUserSpace];
    [[SCBAccountManager sharedManager] setDelegate:self];
}
-(void)spaceSucceedUsed:(NSString *)space_used total:(NSString *)space_total
{
    self.space_total=[YNFunctions convertSize:space_total];
    self.space_used=[YNFunctions convertSize:space_used];
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)switchChange:(id)sender
{
    UISwitch *theSwith = (UISwitch *)sender;
    NSString *onStr = [NSString stringWithFormat:@"%d",theSwith.on];
    [[NSUserDefaults standardUserDefaults]setObject:onStr forKey:@"switch_flag"];
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
- (void)clearCache
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"警告"
                                                        message:@"确定要清除缓存"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
    [alertView show];
    [alertView release];
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
                [[NSUserDefaults standardUserDefaults] synchronize];
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
                    cachePath = [YNFunctions getFMCachePath];
                    locationCacheSize += [YNFunctions getDirectorySizeForPath:cachePath];
                    cachePath = [YNFunctions getIconCachePath];
                    locationCacheSize += [YNFunctions getDirectorySizeForPath:cachePath];
                    cachePath = [YNFunctions getKeepCachePath];
                    locationCacheSize += [YNFunctions getDirectorySizeForPath:cachePath];
                    cachePath = [YNFunctions getTempCachePath];
                    locationCacheSize += [YNFunctions getDirectorySizeForPath:cachePath];
                    cachePath = [YNFunctions getProviewCachePath];
                    locationCacheSize += [YNFunctions getDirectorySizeForPath:cachePath];
                    
                    
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
                    descLabel.text = @"V1.1.0";
                    break;
                case 1:
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
                    //仅在连接WIFI时上传
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
                    break;
                case 1:
                    //评分
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/hong-pan/id618660630?ls=1&mt=8"]];
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

@end
