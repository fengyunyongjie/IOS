//
//  SelectFileUrlViewController.m
//  NetDisk
//
//  Created by Yangsl on 13-8-13.
//
//

#import "SelectFileUrlViewController.h"
#import "SCBSession.h"
#import "AppDelegate.h"

#define ChangeTabWidth 90
#define RightButtonBoderWidth 0
#define TableViewHeight self.view.frame.size.height-TabBarHeight-44

@interface SelectFileUrlViewController ()

@end

@implementation SelectFileUrlViewController
@synthesize table_view;

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
    
    [self.navigationController setNavigationBarHidden:YES];
    
    space_id = [[SCBSession sharedSession] spaceID];
    
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
    
    CGRect table_rect = CGRectMake(0, 44, 320, TableViewHeight);
	table_view = [[[UITableView alloc] initWithFrame:table_rect style:UITableViewStylePlain] autorelease];
    table_view.dataSource=self;
    table_view.delegate=self;
    [self.view addSubview:table_view];
    [table_view setBackgroundColor:[UIColor whiteColor]];
    [table_view setBackgroundView:nil];
}

-(void)clicked_back
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITableVieDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 3;
            break;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *celleString = @"automicCell";
    UITableViewCell *cell = [table_view dequeueReusableCellWithIdentifier:celleString];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:celleString] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        CGRect rect = cell.imageView.frame;
        rect.origin.x = 40;
        cell.imageView.frame = rect;
    }
    int row = [indexPath row];
    if(row == 0)
    {
        cell.textLabel.text = @"我的空间";
        cell.textLabel.textColor=[UIColor colorWithRed:66/255.0 green:75/255.0 blue:83/255.0 alpha:1.0f];
        [cell.imageView initWithImage:[UIImage imageNamed:@"Bt_PersonspaceDef.png"] highlightedImage:[UIImage imageNamed:@"Bt_PersonspaceCh.png"]];
    }
    else if(row == 1)
    {
        cell.textLabel.text = @"我的共享";
        cell.textLabel.textColor=[UIColor colorWithRed:66/255.0 green:75/255.0 blue:83/255.0 alpha:1.0f];
        [cell.imageView initWithImage:[UIImage imageNamed:@"Bt_MyShareDef.png"] highlightedImage:[UIImage imageNamed:@"Bt_MyShareCh.png"]];
    }
    else if(row == 2)
    {
        cell.textLabel.text = @"参与共享";
        cell.textLabel.textColor=[UIColor colorWithRed:66/255.0 green:75/255.0 blue:83/255.0 alpha:1.0f];
        [cell.imageView initWithImage:[UIImage imageNamed:@"Bt_PartakeshareDef.png"] highlightedImage:[UIImage imageNamed:@"Bt_PartakeshareCh.png"]];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    if(row == 0)
    {
        
    }
    else if(row == 1)
    {
        
    }
    else if(row == 2)
    {
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
