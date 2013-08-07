//
//  MessagePushController.m
//  NetDisk
//
//  Created by Yangsl on 13-8-5.
//
//

#import "MessagePushController.h"
#import "MessagePushCell.h"

#define TableViewHeight self.view.frame.size.height
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
        cell = [[MessagePushCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellString];
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
    int type = [[diction objectForKey:@"msg_type"] intValue];
    if(type == 1)
    {
        
    }
    else if(type == 2)
    {
        
    }
    else if(type == 3)
    {
        
    }
    else if(type == 4)
    {
        
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
    int type = [[diction objectForKey:@"msg_type"] intValue];
    if(type == 1)
    {
        
    }
    else if(type == 2)
    {
        
    }
    else if(type == 3)
    {
        
    }
    else if(type == 4)
    {
        
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

-(void)dealloc
{
    [topView release];
    [super dealloc];
}

@end
