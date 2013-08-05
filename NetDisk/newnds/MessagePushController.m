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

@interface MessagePushController ()

@end

@implementation MessagePushController
@synthesize topView;
@synthesize table_view;
@synthesize table_array;

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
    [topView addSubview:back_button];
    [back_button release];
    //标题
    UILabel *title_label = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 320-120, 44)];
    [title_label setText:@"消息"];
    [title_label setTextAlignment:NSTextAlignmentCenter];
    [title_label setTextColor:[UIColor blackColor]];
    [title_label setFont:[UIFont systemFontOfSize:14]];
    [topView addSubview:title_label];
    [title_label release];
    
    [self.view addSubview:topView];
    
    //添加视图列表
    CGRect rect = CGRectMake(0, 44, 320, TableViewHeight);
    self.table_view = [[UITableView alloc] initWithFrame:rect];
    [self.table_view setDataSource:self];
    [self.table_view setDelegate:self];
    self.table_view.showsVerticalScrollIndicator = NO;
    self.table_view.alwaysBounceVertical = YES;
    self.table_view.alwaysBounceHorizontal = NO;
    [self.view addSubview:self.table_view];
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
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellString = @"cellString";
    MessagePushCell *cell = [self.table_view dequeueReusableCellWithIdentifier:cellString];
    if(cell==nil)
    {
        cell = [[MessagePushCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellString];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [topView release];
    [super dealloc];
}

@end
