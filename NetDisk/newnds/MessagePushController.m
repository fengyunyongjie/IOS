//
//  MessagePushController.m
//  NetDisk
//
//  Created by Yangsl on 13-8-5.
//
//

#import "MessagePushController.h"
#import "MessagePushCell.h"
#import "MBProgressHUD.h"

#define TableViewHeight self.view.frame.size.height-60-44
#define ChangeTabWidth 90
#define hilighted_color [UIColor colorWithRed:255.0/255.0 green:180.0/255.0 blue:94.0/255.0 alpha:1.0]
#define RightButtonBoderWidth 0
#define AcceptTag 10000
#define RefusedTag 20000

@interface MessagePushController ()

@end

@implementation MessagePushController
@synthesize topView;
@synthesize table_view;
@synthesize table_array;
@synthesize messageManager;
@synthesize friendManager;
@synthesize group_id;

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
    //添加头部试图
    [self.navigationController setNavigationBarHidden:YES];
    topView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
    UIImageView *images = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [images setImage:[UIImage imageNamed:@"Bk_Title.png"]];
    [topView addSubview:images];
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
    [back_button addTarget:self action:@selector(back_clicked:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:back_button];
    [back_button release];
    //标题
    UILabel *title_label = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 320-120, 44)];
    [title_label setText:@"消息"];
    [title_label setBackgroundColor:[UIColor clearColor]];
    [title_label setTextAlignment:NSTextAlignmentCenter];
    [title_label setTextColor:[UIColor blackColor]];
    [title_label setFont:[UIFont systemFontOfSize:18]];
    [topView addSubview:title_label];
    [title_label release];
    
    [self.view addSubview:topView];
    
    //添加视图列表
    CGRect rect = CGRectMake(0, 44, 320, TableViewHeight);
    self.table_view = [[UITableView alloc] initWithFrame:rect];
    [self.table_view setDataSource:self];
    [self.table_view setDelegate:self];
//    self.table_view.showsVerticalScrollIndicator = NO;
//    self.table_view.alwaysBounceVertical = YES;
//    self.table_view.alwaysBounceHorizontal = NO;
    [self.view addSubview:self.table_view];
    
    //请求消息
    messageManager = [[SCBMessageManager alloc] init];
    [messageManager setDelegate:self];
    [messageManager selectMessages:1 cursor:0 offset:-1 unread:0];
    
    //好友管理
    friendManager = [[SCBFriendManager alloc] init];
    [friendManager setDelegate:self];
    
    //共享管理
    shareManager = [[SCBShareManager alloc] init];
    [shareManager setDelegate:self];
    
}

-(void)back_clicked:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark tableviewdelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [table_array count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellString = @"cellString";
    MessagePushCell *cell = [self.table_view dequeueReusableCellWithIdentifier:cellString];
    if(cell==nil)
    {
        cell = [[[MessagePushCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellString] autorelease];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell firstLoad:70];
    }
    
    NSDictionary *diction = [table_array objectAtIndex:[indexPath row]];
    NSString *text = [diction objectForKey:@"msg_content"];
    NSString *time = [diction objectForKey:@"msg_sendtime"];
    
    [cell.accept_button setTag:AcceptTag+[indexPath row]];
    [cell.accept_button addTarget:self action:@selector(accept_button_cilicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.refused_button setTag:RefusedTag+[indexPath row]];
    [cell.refused_button addTarget:self action:@selector(refused_button_cilicked:) forControlEvents:UIControlEventTouchUpInside];
    NSString *msg_type = [diction objectForKey:@"msg_type"];
    NSString *msg_sort = [diction objectForKey:@"msg_sort"];
    NSString *msg_sender_remark = [diction objectForKey:@"msg_sender_remark"];
    [cell setUpdate:text timeString:time msg_type:msg_type msg_sender_remark:msg_sender_remark msg_sort:msg_sort];
    return cell;
}

-(void)accept_button_cilicked:(id)sender
{
    UIButton *button = sender;
    int row = button.tag-AcceptTag;
    NSDictionary *diction = [table_array objectAtIndex:row];
    int msg_type = [[diction objectForKey:@"msg_type"] intValue];
    int sort_type = [[diction objectForKey:@"msg_sort"] intValue];
    if(msg_type == 1)
    {
        if(sort_type == 1) //添加共享用户
        {
            NSString *msg_sender_id = [diction objectForKey:@"msg_sender_id"];
            NSString *file_id = [diction objectForKey:@"file_id"];
            NSLog(@"shareManager:%@",shareManager);
            [shareManager shareInvitationAdd:file_id friend_id:msg_sender_id];
        }
        
        if(sort_type == 6) //添加好友
        {
            //添加好友请求
            NSString *friendId = [diction objectForKey:@"account"];
            NSString *mark = [diction objectForKey:@"msg_sender_remark"];
            NSLog(@"groupId:%@",self.group_id);
            if(self.group_id != nil)
            {
                [friendManager getFriendshipsFriendsCreate:friendId group_id:[self.group_id intValue] friend_remark:mark];
            }
            
        }
    }
}

-(void)deleteMessage:(int)row
{
    if(row<[table_array count])
    {
        NSDictionary *diction = [table_array objectAtIndex:row];
        NSString *message_id = [diction objectForKey:@"msg_id"];
        [messageManager deleteMessage:[NSArray arrayWithObjects:message_id, nil]];
    }
}

-(void)refused_button_cilicked:(id)sender
{
    UIButton *button = sender;
    int row = button.tag-RefusedTag;
    NSDictionary *diction = [table_array objectAtIndex:row];
    int msg_type = [[diction objectForKey:@"msg_type"] intValue];
    int sort_type = [[diction objectForKey:@"msg_sort"] intValue];
    
    if(msg_type == 1)
    {
        if(sort_type == 1) //拒绝共享用户
        {
            NSString *msg_sender_id = [diction objectForKey:@"msg_sender_id"];
            NSString *file_id = [diction objectForKey:@"file_id"];
            [shareManager shareInvitationRemove:file_id friend_id:msg_sender_id];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark ------- SCBMessageManagerDelegate

-(void)getSelectMessges:(NSDictionary *)dictioinary
{
    int code = [[dictioinary objectForKey:@"code"] intValue];
    if(code == 0)
    {
        NSArray *array = [dictioinary objectForKey:@"msgs"];
        [table_array addObjectsFromArray:array];
        [self.table_view reloadData];
        if([array count] == 0)
        {
            if(!isSelect)
            {
                isSelect = TRUE;
                [messageManager selectMessages:1 cursor:0 offset:-1 unread:1];
            }
        }
        else
        {
            [friendManager getFriendshipsGroups:0 offset:-1];
        }
    }
    NSLog(@"dictioinary:%@",table_array);
}

-(void)finishMessage:(NSDictionary *)dictioinary
{
    NSLog(@"dictioinary:%@",dictioinary);
}

-(void)error
{
    NSLog(@"error---------------------");
}

#pragma mark -----  SCBFriendManagerDelegate

//获取群组列表
-(void)getFriendshipsGroups:(NSDictionary *)dictionary
{
    BOOL bl = [[dictionary objectForKey:@"code"] boolValue];
    if(!bl)
    {
        NSArray *array = [dictionary objectForKey:@"groups"];
        if([array count]>0)
        {
            NSDictionary *dict = [array lastObject];
            self.group_id = [dict objectForKey:@"group_id"];
        }
    }
    NSLog(@"dictionary:%@",dictionary);
}

//获取所有群组及好友列表/friendships/groups/deep
-(void)getFriendshipsGroupsDeep:(NSDictionary *)dictionary
{

}

//创建群组/friendships/group/create
-(void)getFriendshipsGroupsCreate:(NSDictionary *)dictionary
{

}

//修改群组/friendships/group/update
-(void)getFriendshipsGroupsUpdate:(NSDictionary *)dictionary
{

}

//删除群组/friendships/group/del
-(void)getFriendshipsGroupDel:(NSDictionary *)dictionary
{

}

//获取好友列表/friendships/friends
-(void)getFriendshipsFriends:(NSDictionary *)dictionary
{

}

//添加好友/friendships/friend/create
-(void)getFriendshipsFriendsCreate:(NSDictionary *)dictionary
{
    NSLog(@"dationary:%@",dictionary);
    int code = [[dictionary objectForKey:@"code"] intValue];
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    if(code==0)
    {
        hud.labelText=@"操作成功";
    }
    else if(code==1)
    {
        hud.labelText=@"服务端异常";
    }
    else if(code==2)
    {
        hud.labelText=@"无效的好友账号";
    }
    else if(code==3)
    {
        hud.labelText=@"好友已存在";
    }
    else if(code==4)
    {
        hud.labelText=@"用户与组不匹配";
    }
    else if(code==5)
    {
        hud.labelText=@"不能添加自己";
    }
    else if(code==6)
    {
        hud.labelText=@"好友名不能为空";
    }
    hud.mode=MBProgressHUDModeText;
    [hud show:YES];
    [hud hide:YES afterDelay:0.8f];
    [hud release];
}

//移动好友/friendships/friend/move
-(void)getFriendshipsFriendMove:(NSDictionary *)dictionary
{

}

//修改好友备注/friendships/friend/remark/update
-(void)getFriendshipsFriendRemarkUpdate:(NSDictionary *)dictionary
{

}

//删除好友/friendships/friend/del
-(void)getFriendshipsFriendDel:(NSDictionary *)dictionary
{

}

#pragma mark ---------- shareManager

-(void)InvitationAdd:(NSDictionary *)dationary
{
    NSLog(@"dationary:%@",dationary);
    int code = [[dationary objectForKey:@"code"] intValue];
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    if(code==0)
    {
        hud.labelText=@"操作成功";
    }
    else if(code==1)
    {
        hud.labelText=@"服务端异常";
    }
    else if(code==2)
    {
        hud.labelText=@"不是文件拥有者";
    }
    hud.mode=MBProgressHUDModeText;
    [hud show:YES];
    [hud hide:YES afterDelay:0.8f];
    [hud release];
}

-(void)searchSucess:(NSDictionary *)datadic
{

}

-(void)openFinderSucess:(NSDictionary *)datadic
{

}

-(void)dealloc
{
    [topView release];
    [super dealloc];
}

@end
