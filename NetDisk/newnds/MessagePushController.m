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

#define TableViewHeight self.view.frame.size.height-44
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
@synthesize isHiddenTabbar;
@synthesize isPushMessage;
@synthesize null_imageview;

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
    UIApplication *app = [UIApplication sharedApplication];
    app.applicationIconBadgeNumber = 0;
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
    
    CGFloat height = TableViewHeight;
    if(isHiddenTabbar)
    {
        height = TableViewHeight - 60;
    }
    CGRect rect = CGRectMake(0, 44, 320, height);
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
    unreadBL = 1;
    
    //好友管理
    friendManager = [[SCBFriendManager alloc] init];
    [friendManager setDelegate:self];
    
    //共享管理
    shareManager = [[SCBShareManager alloc] init];
    [shareManager setDelegate:self];
    
    null_imageview = [[UIImageView alloc] initWithFrame:rect];
    [null_imageview setImage:[UIImage imageNamed:@"pop.png"]];
    [self.view addSubview:null_imageview];
    [null_imageview setHidden:YES];
    //刷新数据
    [self reloadMessageData];
}

-(void)reloadMessageData
{
    [messageManager selectMessages:-1 cursor:0 offset:-1 unread:-1];
}

-(void)back_clicked:(id)sender
{
    if(isPushMessage)
    {
        [self dismissModalViewControllerAnimated:YES];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark tableviewdelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([table_array count] == 0)
    {
        return 1;
    }
    return [table_array count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([table_array count] == 0)
    {
        return 50;
    }
    else
    {
        NSDictionary *diction = [table_array objectAtIndex:[indexPath row]];
        NSString *text = [self getCellShowText:diction];
        CGFloat height = [self getCellHight:diction withForText:text];
        return height;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if([table_array count] == 0)
    {
        MessagePushCell *cell = [[[MessagePushCell alloc] init] autorelease];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.textLabel.text = @"等待中...";
        return cell;
    }
    if(indexPath.row<[table_array count])
    {
        NSDictionary *diction = [table_array objectAtIndex:[indexPath row]];
        return [self showMessageCellWithDictionary:diction withForIndexPath:indexPath];
    }
    else
    {
        return nil;
    }
}

-(void)accept_button_cilicked:(id)sender
{
    UIButton *button = sender;
    NSLog(@"button.tag:%i",button.tag);
    int row = button.tag-AcceptTag;
    NSMutableDictionary *diction = [table_array objectAtIndex:row];
    int sort_type = [[diction objectForKey:@"msg_sort"] intValue];
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
            [friendManager setDelegate:self];
            [friendManager getFriendshipsFriendsCreate:friendId group_id:[self.group_id intValue] friend_remark:mark];
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
    int sort_type = [[diction objectForKey:@"msg_sort"] intValue];
    if(sort_type == 1) //拒绝共享用户
    {
        NSString *msg_sender_id = [diction objectForKey:@"msg_sender_id"];
        NSString *file_id = [diction objectForKey:@"file_id"];
        [shareManager shareInvitationRemove:file_id friend_id:msg_sender_id];
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
        NSLog(@"得到消息：%@",array);
        [table_array removeAllObjects];
        for (NSDictionary *diction in array) {
            NSMutableDictionary *tableD = [[NSMutableDictionary alloc] initWithDictionary:diction];
            [table_array addObject:tableD];
            [tableD release];
        }
        
        if([table_array count]>0)
        {
            [self.table_view reloadData];
            [friendManager getFriendshipsGroups:0 offset:-1];
            isSelect = FALSE;
        }
        else
        {
            [null_imageview setHidden:NO];
        }
    }
    NSLog(@"dictioinary:%@",table_array);
}

-(void)finishMessage:(NSDictionary *)dictioinary
{
    NSLog(@"dictioinary:%@",dictioinary);
    //刷新数据
    [self reloadMessageData];
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
    
    //刷新数据
    [self reloadMessageData];
    
//    [self.table_view reloadData];
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
    
    
    //刷新数据
    [self reloadMessageData];
}

-(void)searchSucess:(NSDictionary *)datadic
{

}

-(void)openFinderSucess:(NSDictionary *)datadic
{

}

#pragma mark 计算出应该显示的文字
-(NSString *)getCellShowText:(NSDictionary *)dictionary
{
    NSString *title = nil;

    int msg_sort = [[dictionary objectForKey:@"msg_sort"] intValue];
    NSString *text = [dictionary objectForKey:@"msg_content"];
    NSString *msg_sender_remark = [dictionary objectForKey:@"msg_sender_remark"];
    
    if(msg_sort == 1) //添加共享用户
    {
        title = [NSString stringWithFormat:AddShared,msg_sender_remark,text];
    }
    else if(msg_sort == 2) //踢出共享用户
    {
        title = [NSString stringWithFormat:GetOutShared,msg_sender_remark,text];
    }
    else if(msg_sort == 3) //取消共享
    {
        title = [NSString stringWithFormat:EscShared,msg_sender_remark,text];
    }
    else if(msg_sort == 4) //用户退出共享
    {
        title = [NSString stringWithFormat:AccoutSelfEsc,msg_sender_remark,text];
    }
    else if(msg_sort == 5) //共享文件夹重命名
    {
        NSArray *fname=[text componentsSeparatedByString:@"|"];
        title = [NSString stringWithFormat:UpdateNameShared,msg_sender_remark,fname[0],fname[1]];
    }
    else if(msg_sort == 6) //添加好友
    {
        title = [NSString stringWithFormat:AddFirendToMe,msg_sender_remark];
    }
    else if(msg_sort == 7) //自定义短消息
    {
        title = [NSString stringWithFormat:@"%@向你说:%@",msg_sender_remark,text];
    }
    else if(msg_sort == 8) //添加家庭成员
    {
        title = [NSString stringWithFormat:AddFamilyToMe,msg_sender_remark];
    }
    else if(msg_sort == 9) //上传文件
    {
        title=[NSString stringWithFormat:@"%@上传文件：%@",msg_sender_remark,text];
    }
    else if(msg_sort == 10) //删除文件
    {
        title=[NSString stringWithFormat:@"%@删除了文件:%@",msg_sender_remark,text];
    }
    else if(msg_sort == 11) //新建文件夹
    {
        NSArray *fname=[text componentsSeparatedByString:@"|"];
        title=[NSString stringWithFormat:@"%@新建了文件夹:%@至%@",msg_sender_remark,fname[0],fname[1]];
    }
    else if(msg_sort == 12) //新增图片和视频
    {
        title=[NSString stringWithFormat:@"%@在%@中加入了新内容(家庭空间）",msg_sender_remark,text];
    }
    
    return title;
}

#pragma mark 计算出应该显示的button
-(void)setShowMesscellButton:(MessagePushCell *)cell withForDictionary:(NSDictionary *)dictionary
{
    int msg_sort = [[dictionary objectForKey:@"msg_sort"] intValue];
    
    if(msg_sort == 1) //添加共享用户
    {
        BOOL bl = [[dictionary objectForKey:@"is_accept"] boolValue];
        if(bl)
        {
            cell.accept_button.hidden = YES;
            cell.refused_button.hidden = YES;
            
            CGRect title_rect = cell.title_label.frame;
            title_rect.size.width = 320-boderWidth*2;
            cell.title_label.frame = title_rect;
            CGRect time_rect = cell.time_label.frame;
            time_rect.size.width = 320-boderWidth*2;
            cell.time_label.frame = time_rect;
        }
        else
        {
            CGRect rect = cell.accept_button.frame;
            rect.size.width = 50;
            cell.accept_button.frame = rect;
            [cell.accept_button setTitle:@"接受" forState:UIControlStateNormal];
            
            cell.accept_button.hidden = NO;
            cell.refused_button.hidden = NO;
            
            CGRect title_rect = cell.title_label.frame;
            title_rect.size.width = navbarWidth-boderWidth;
            cell.title_label.frame = title_rect;
            CGRect time_rect = cell.time_label.frame;
            time_rect.size.width = navbarWidth-boderWidth;
            cell.time_label.frame = time_rect;
        }
    }
    else if(msg_sort == 6) //添加好友
    {
        BOOL bl = [[dictionary objectForKey:@"is_accept"] boolValue];
        if(bl)
        {
            cell.accept_button.hidden = YES;
            cell.refused_button.hidden = YES;
            
            CGRect title_rect = cell.title_label.frame;
            title_rect.size.width = 320-boderWidth*2;
            cell.title_label.frame = title_rect;
            CGRect time_rect = cell.time_label.frame;
            time_rect.size.width = 320-boderWidth*2;
            cell.time_label.frame = time_rect;
        }
        else
        {
            CGRect rect = cell.accept_button.frame;
            rect.size.width = 50*2+5;
            cell.accept_button.frame = rect;
            cell.accept_button.hidden = NO;
            [cell.accept_button setTitle:@"添加Ta为好友" forState:UIControlStateNormal];
            cell.refused_button.hidden = YES;
            
            CGRect title_rect = cell.title_label.frame;
            title_rect.size.width = navbarWidth-boderWidth;
            cell.title_label.frame = title_rect;
            CGRect time_rect = cell.time_label.frame;
            time_rect.size.width = navbarWidth-boderWidth;
            cell.time_label.frame = time_rect;
        }
    }
    else
    {
        cell.accept_button.hidden = YES;
        cell.refused_button.hidden = YES;
        
        CGRect title_rect = cell.title_label.frame;
        title_rect.size.width = 320-boderWidth*2;
        cell.title_label.frame = title_rect;
        CGRect time_rect = cell.time_label.frame;
        time_rect.size.width = 320-boderWidth*2;
        cell.time_label.frame = time_rect;
    }
}

#pragma mark 计算cell的高度

-(CGFloat)getCellHight:(NSDictionary *)dictionary withForText:(NSString *)text;
{
    CGFloat height = 0;
    int msg_sort = [[dictionary objectForKey:@"msg_sort"] intValue];
    if(msg_sort == 1) //添加共享用户
    {
        BOOL bl = [[dictionary objectForKey:@"is_accept"] boolValue];
        if(bl)
        {
            height = [self withForText:text andWithWidth:320-boderWidth*2];
        }
        else
        {
            height = [self withForText:text andWithWidth:navbarWidth-boderWidth];
        }
    }
    else if(msg_sort == 6) //添加好友
    {
        BOOL bl = [[dictionary objectForKey:@"is_accept"] boolValue];
        if(bl)
        {
            height = [self withForText:text andWithWidth:320-boderWidth*2];
        }
        else
        {
            height = [self withForText:text andWithWidth:navbarWidth-boderWidth];
        }
    }
    else
    {
        height = [self withForText:text andWithWidth:320-boderWidth*2];
    }
    return height;
}

-(CGFloat)withForText:(NSString *)text andWithWidth:(CGFloat)width
{
    //计算高度
    UILabel *title_label = [[[UILabel alloc] init] autorelease];
    [title_label setFont:[UIFont systemFontOfSize:16]];
    title_label.numberOfLines=0;
    [title_label setText:text];
    CGSize size = [title_label sizeThatFits:CGSizeMake(width, 0)];//假定label_1设置的固定宽度为100，自适应高
    [title_label.text sizeWithFont:title_label.font
                 constrainedToSize:size
                     lineBreakMode:UILineBreakModeWordWrap];  //这句加上才能自适应
    NSLog(@"字符在宽度不变，自适应高：%f",size.height);
    return size.height+37.0;
}

#pragma mark 判定cell的样式的方法

-(MessagePushCell *)showMessageCellWithDictionary:(NSDictionary *)dictionary withForIndexPath:(NSIndexPath *)indexPath
{
    MessagePushCell *cell = [[[MessagePushCell alloc] init] autorelease];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    //获取常用数据
    NSDictionary *diction = [table_array objectAtIndex:[indexPath row]];
    NSString *text = [self getCellShowText:diction];
    NSString *time = [diction objectForKey:@"msg_sendtime"];
    //cell的高度
    CGFloat height = [self getCellHight:diction withForText:text];
    //初始化数据
    [cell firstLoad:height];
    //添加tag
    [cell.accept_button setTag:AcceptTag+[indexPath row]];
    [cell.refused_button setTag:RefusedTag+[indexPath row]];
    [cell.accept_button addTarget:self action:@selector(accept_button_cilicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.refused_button addTarget:self action:@selector(refused_button_cilicked:) forControlEvents:UIControlEventTouchUpInside];
    //判定需要显示的视图
    [self setShowMesscellButton:cell withForDictionary:diction];
    //显示内容
    [cell.title_label setText:text];
    
    cell.title_label.numberOfLines=0;
    CGSize size = [cell.title_label sizeThatFits:CGSizeMake(cell.title_label.frame.size.width, 0)];
    [cell.title_label.text sizeWithFont:cell.title_label.font
                 constrainedToSize:size
                     lineBreakMode:UILineBreakModeWordWrap];
    [cell.time_label setText:time];
    return cell;
}

-(void)dealloc
{
    [null_imageview release];
    [topView release];
    [super dealloc];
}

@end
