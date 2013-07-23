//
//  MainViewController.m
//  NetDisk
//
//  Created by fengyongning on 13-7-22.
//
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIView *nbar=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 73/2)];
    UIImageView *niv=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
    [nbar addSubview:niv];
    [self.view addSubview: nbar];
    CGRect r=self.view.frame;
    r.size.height=343/2;
    UIImageView *headerView=[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Bk_MySpace.png"]] autorelease];
    headerView.frame=r;
    [self.view addSubview:headerView];
    self.tableView=[[[UITableView alloc] init] autorelease];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.view addSubview:self.tableView];
    r=self.view.frame;
    r.origin.y=343/2;
    r.size.height=r.size.height-r.origin.y;
    self.tableView.frame=r;
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
    //[self.navigationController.navigationBar
     //setBackgroundColor:[UIColor orangeColor]];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    cell.selectedBackgroundView=[[[UIView alloc] initWithFrame:cell.frame] autorelease];
    cell.selectedBackgroundView.backgroundColor=[UIColor colorWithRed:255/255.0f green:181/255.0f blue:94/255.0f alpha:1];
    UILabel *tlabel;
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text=@"个人空间";
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
@end
