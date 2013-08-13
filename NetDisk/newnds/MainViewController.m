//
//  MainViewController.m
//  NetDisk
//
//  Created by fengyongning on 13-7-22.
//
//

#import "MainViewController.h"
#import "MyndsViewController.h"
#import "MessagePushController.h"

#define TabBarHeight 60
#define ChangeTabWidth 90
#define RightButtonBoderWidth 0
#define hilighted_color [UIColor colorWithRed:255.0/255.0 green:180.0/255.0 blue:94.0/255.0 alpha:1.0]
@interface MainViewController ()
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UIView *ctrlView;
@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
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
    //更多按钮
    UIButton *more_button = [[UIButton alloc] init];
    UIImage *moreImage = [UIImage imageNamed:@"Bt_More.png"];
    [more_button setFrame:CGRectMake(320-RightButtonBoderWidth-moreImage.size.width/2, (44-moreImage.size.height/2)/2, moreImage.size.width/2, moreImage.size.height/2)];
    [more_button setImage:moreImage forState:UIControlStateNormal];
    [more_button setBackgroundImage:imge forState:UIControlStateHighlighted];
    [more_button addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
    [nbar addSubview:more_button];
    [more_button release];
    
    
        
    CGRect r=self.view.frame;
    r.origin.y=44;
    r.size.height=343/2;
    UIImageView *headerView=[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Bk_MySpace.png"]] autorelease];
    headerView.frame=r;
    [self.view addSubview:headerView];
    self.tableView=[[[UITableView alloc] init] autorelease];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.view addSubview:self.tableView];
    r=self.view.frame;
    r.origin.y=343/2+44;
    r.size.height=r.size.height-r.origin.y;
    self.tableView.frame=r;
    
    //操作菜单
    self.ctrlView=[[UIControl alloc] init];
    self.ctrlView.frame=self.view.frame;
    [self.ctrlView addTarget:self action:@selector(touchView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.ctrlView];
    [self.ctrlView setHidden:YES];
    UIImageView *bg=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Bk_na.png"]];
    //bg.frame=CGRectMake(25, 44, 270, 175);
    bg.frame=CGRectMake(25+(90*2), 44, 90, 87);
    [self.ctrlView addSubview:bg];
    //按钮－新建文件夹 0，2
    UIButton *btnNewFinder02= [UIButton buttonWithType:UIButtonTypeCustom];
    btnNewFinder02.frame=CGRectMake(25+(90*2), 44, 90, 87);
    [btnNewFinder02 setImage:[UIImage imageNamed:@"Bt_naNews.png"] forState:UIControlStateNormal];
    [btnNewFinder02 setBackgroundImage:[UIImage imageNamed:@"Bk_naChecked.png"] forState:UIControlStateHighlighted];
    [btnNewFinder02 addTarget:self action:@selector(goMessage:) forControlEvents:UIControlEventTouchUpInside];
    [self.ctrlView addSubview:btnNewFinder02];
    UILabel *lblNewFinder02=[[[UILabel alloc] init] autorelease];
    lblNewFinder02.text=@"消息";
    lblNewFinder02.textAlignment=UITextAlignmentCenter;
    lblNewFinder02.font=[UIFont systemFontOfSize:12];
    lblNewFinder02.textColor=[UIColor whiteColor];
    lblNewFinder02.backgroundColor=[UIColor clearColor];
    lblNewFinder02.frame=CGRectMake(25+(90*2), 59+44, 90, 21);
    [self.ctrlView addSubview:lblNewFinder02];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
    self.titleLabel.text=self.title;
    [self.tableView reloadData];
    self.ctrlView.frame=self.view.frame;
    //[self.navigationController.navigationBar
     //setBackgroundColor:[UIColor orangeColor]];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)showMenu:(id)sender
{
//    if (self.selectedIndexPath) {
//        //[self.tableView deleteRowsAtIndexPaths:@[self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//        [self hideOptionCell];
//    }
    [self.ctrlView setHidden:!self.ctrlView.hidden];
}
-(void)goMessage:(id)sender
{
    MessagePushController *messagePush = [[MessagePushController alloc] init];
    [self.navigationController pushViewController:messagePush animated:YES];
    [messagePush release];
    [self.ctrlView setHidden:YES];
    NSLog(@"点击消息");
}
-(void)touchView:(id)sender
{
    if (!self.ctrlView.isHidden) {
        [self.ctrlView setHidden:YES];
    }
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Option Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:CellIdentifier] autorelease];
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }
    //cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.selectedBackgroundView=[[[UIView alloc] initWithFrame:cell.frame] autorelease];
    cell.selectedBackgroundView.backgroundColor=[UIColor colorWithRed:255/255.0f green:181/255.0f blue:94/255.0f alpha:1];
    UILabel *tlabel;
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text=@"我的空间";
            cell.textLabel.textColor=[UIColor colorWithRed:66/255.0 green:75/255.0 blue:83/255.0 alpha:1.0f];
            cell.imageView.image=[UIImage imageNamed:@"space.png"];
            UIImageView *imageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Bt_PersonspaceDef.png"] highlightedImage:[UIImage imageNamed:@"Bt_PersonspaceCh.png"]];
            imageView.frame=CGRectMake(25, 15, 35, 35);
            [cell.contentView addSubview:imageView];
            [cell.contentView bringSubviewToFront:imageView];
            
            //cell.imageView.frame=CGRectMake(15, 15, 27, 27);
            break;
        case 1:
            cell.textLabel.text=@"我的共享";
            cell.textLabel.textColor=[UIColor colorWithRed:66/255.0 green:75/255.0 blue:83/255.0 alpha:1.0f];
            //cell.imageView.image=[UIImage imageNamed:@"Bt_MyShareDef.png"];
            cell.imageView.image=[UIImage imageNamed:@"space.png"];
            imageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Bt_MyShareDef.png"] highlightedImage:[UIImage imageNamed:@"Bt_MyShareCh.png"]];
            imageView.frame=CGRectMake(25, 15, 35, 35);
            [cell.contentView addSubview:imageView];
            [cell.contentView bringSubviewToFront:imageView];
            //cell.imageView.frame=CGRectMake(15, 15, 27, 27);
            break;
        case 2:
            cell.textLabel.text=@"参与共享";
            cell.textLabel.textColor=[UIColor colorWithRed:66/255.0 green:75/255.0 blue:83/255.0 alpha:1.0f];
            //cell.imageView.image=[UIImage imageNamed:@"Bt_PartakeshareDef.png"];
            cell.imageView.image=[UIImage imageNamed:@"space.png"];
            imageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Bt_PartakeshareDef.png"] highlightedImage:[UIImage imageNamed:@"Bt_PartakeshareCh.png"]];
            imageView.frame=CGRectMake(25, 15, 35, 35);
            [cell.contentView addSubview:imageView];
            [cell.contentView bringSubviewToFront:imageView];
            //cell.imageView.frame=CGRectMake(15, 15, 27, 27);
            break;
        default:
            break;
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    switch (indexPath.row) {
//        case 0:
//            return 343/2;
//            break;
//        default:
//            break;
//    }
    return 60;
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            MyndsViewController *viewController=[[[MyndsViewController alloc] init] autorelease];
            viewController.f_id=@"1";
            viewController.myndsType=kMyndsTypeDefault;
            viewController.title=@"我的空间";
            [self.navigationController pushViewController:viewController animated:YES];
        }
            break;
        case 1:
        {
            MyndsViewController *viewController=[[[MyndsViewController alloc] init] autorelease];
            viewController.f_id=@"1";
            viewController.myndsType=kMyndsTypeMyShare;
            viewController.title=@"我的共享";
            [self.navigationController pushViewController:viewController animated:YES];
        }
            break;
        case 2:
        {
            MyndsViewController *viewController=[[[MyndsViewController alloc] init] autorelease];
            viewController.f_id=@"1";
            viewController.myndsType=kMyndsTypeShare;
            viewController.title=@"参与共享";
            [self.navigationController pushViewController:viewController animated:YES];
        }
            break;
        default:
            break;
    }
}
@end
