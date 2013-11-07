//
//  MASettingViewController.m
//  NetDisk
//
//  Created by fengyongning on 13-11-7.
//
//

#import "MASettingViewController.h"
#import "APService.h"
#import "YNFunctions.h"
#import "SCBFileManager.h"
#import "SCBSession.h"

#define hilighted_color [UIColor colorWithRed:255.0/255.0 green:180.0/255.0 blue:94.0/255.0 alpha:1.0]
#define ChangeTabWidth 90
#define RightButtonBoderWidth 0

@interface MASettingViewController ()<SCBFileManagerDelegate>
@property (strong,nonatomic) SCBFileManager *fm;
@end

@implementation MASettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    CGRect r=self.view.frame;
    r.origin.y=44;
    r.size.height=self.view.frame.size.height-44-60;
    self.tableView.frame=r;
    [self updateList];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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
    titleLabel.text=@"消息提醒设置";
    titleLabel.font=[UIFont boldSystemFontOfSize:18];
    titleLabel.textAlignment=UITextAlignmentCenter;
    titleLabel.backgroundColor=[UIColor clearColor];
    titleLabel.frame=CGRectMake(60, 0, 200, 44);
    [nbar addSubview:titleLabel];
    
    self.tableView=[[[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped] autorelease];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    [self.view addSubview:self.tableView];
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    [self.tableView setBackgroundView:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 操作方法
- (void)updateList
{
    self.fm=[[SCBFileManager alloc] init];
    self.fm.delegate=self;
    [self.fm requestOpenFamily:@""];
}
- (void)switchChange:(id)sender
{
    int tag=[(UISwitch*)sender tag];
    switch (tag) {
        case -1:
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
                [[UIApplication sharedApplication] unregisterForRemoteNotifications];
            }

        }
            break;
        default:
        {
            NSDictionary *dic =[self.listArray objectAtIndex:tag];
            NSString *space_id=[dic objectForKey:@"space_id"];
            UISwitch *theSwith = (UISwitch *)sender;
            if (theSwith.on) {
                [YNFunctions removeItemToUnselectFamilyWithStringValue:space_id];
            }else
            {
                [YNFunctions addItemToUnselectFamilyWithStringValue:space_id];
            }
            if ([YNFunctions isAlertMessage]) {
                // Required
                [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                               UIRemoteNotificationTypeSound |
                                                               UIRemoteNotificationTypeAlert)];
                
                NSString *alias=[NSString stringWithFormat:@"%@",[[SCBSession sharedSession] spaceID]];
                NSSet *tags=[NSSet setWithArray:[YNFunctions selectFamily]];
                
                [APService setTags:tags alias:alias];
                NSLog(@"设置标签和别名成功,\n别名：%@\n标签：%@",alias,tags);
            }
        }
            break;
    }
}
-(void)clicked_back
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            if (self.listArray) {
                return self.listArray.count;
            }
            break;
    }
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *itemTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 12, 200, 20)];
        itemTitleLabel.tag = 1;
        itemTitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        [cell.contentView addSubview:itemTitleLabel];
        itemTitleLabel.backgroundColor= [UIColor clearColor];
        [itemTitleLabel release];
    }
    [cell setBackgroundColor:[UIColor colorWithRed:225/255.0f green:225/255.0f blue:225/255.0f alpha:1.0f]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    UILabel *titleLabel = (UILabel *)[cell.contentView  viewWithTag:1];
    for(UIView *view in cell.contentView.subviews)
    {
        if ([view isKindOfClass:[UISwitch class]]) {
            [view removeFromSuperview];
        }
    }
    UISwitch *m_switch = [[UISwitch alloc] initWithFrame:CGRectMake(220, 10, 40, 29)];
    [m_switch setOnTintColor:[UIColor colorWithRed:255.0/255.0 green:180.0/255.0 blue:94.0/255.0 alpha:1.0]];
    [m_switch addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
    m_switch.on = YES;
    m_switch.tag = row;
    [cell.contentView addSubview:m_switch];
    [m_switch release];
    
    switch (section) {
        case 0:
            m_switch.tag=-1;
            m_switch.on=[YNFunctions isAlertMessage];
            titleLabel.text=@"接收消息通知";
            break;
        case 1:
        {
            if (self.listArray) {
                NSDictionary *dic=[self.listArray objectAtIndex:row];
                if ([[dic objectForKey:@"userId"] intValue]==[[SCBSession sharedSession].spaceID intValue]) {
                    titleLabel.text=@"我的家庭空间";
                }else
                {
                    titleLabel.text=[NSString stringWithFormat:@"家庭空间:%@",[dic objectForKey:@"space_comment"]];
                }
                NSString *space_id=[dic objectForKey:@"space_id"];
                if (space_id) {
                    if ([YNFunctions isInUnselectFamilyValue:space_id]) {
                        m_switch.on=NO;
                    }
                }else
                {
                    m_switch.on=YES;
                }
            }
        }
            break;
        default:
            break;
    }
    
    return cell;
}
#pragma mark - SCBFileManagerDelegate
//打开家庭成员
-(void)getOpenFamily:(NSDictionary *)dictionary
{
    NSLog(@"dictionary:%@",dictionary);
    NSArray *array = [dictionary objectForKey:@"spaces"];
    if([array count] > 0)
    {
        self.listArray=array;
        NSMutableArray *marray=[NSMutableArray array];
        for (NSDictionary *dic in array) {
            NSString *str=[dic objectForKey:@"space_id"];
            if (str) {
                [marray addObject:str];
            }
        }
        [YNFunctions setAllFamily:marray];
    }
    [self.tableView reloadData];
}
@end
