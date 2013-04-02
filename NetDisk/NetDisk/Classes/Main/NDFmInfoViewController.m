//
//  NDFmInfoViewController.m
//  NetDisk
//
//  Created by jiangwei on 13-1-15.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "NDFmInfoViewController.h"

@implementation NDFmInfoViewController
@synthesize m_tableView,m_myInfoDic;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [m_tableView release];
    [m_myInfoDic release];
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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [m_tableView reloadData];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (IBAction)comeBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIRenameViewController *rv=[[UIRenameViewController alloc]initWithNibName:@"UIRenameViewController" bundle:nil];
    rv.m_reanmeDic = self.m_myInfoDic;
    [self.navigationController pushViewController:rv animated:YES];
    [rv release];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#pragma mark - UITableViewDataSource Methods

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	
    switch (section) {
        case 0:
            return @"信息";
            break;
        case 1:
            return @"";
            break;
            
        default:
            break;
    }
	return nil;
    
}
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
        case 1:
            return 0;
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
    static NSString *CellIdentifier = @"NDFmInfoCell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell ==nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
    }   
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    switch (section) {
        case 0:
        {
            switch (row) {
                case 0:
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    cell.textLabel.text = @"文件夹名称";
                    cell.detailTextLabel.text = [m_myInfoDic objectForKey:@"f_name"];
                    break;
                case 1:
                {
                    cell.textLabel.text = @"占用空间大小";
                    NSString *fileSize = [Function convertSize:[m_myInfoDic objectForKey:@"f_size"]];
                    cell.detailTextLabel.text = fileSize;
                }
                    
                    break;
       /*         case 2:
                    cell.textLabel.text = @"文件数量";
                    cell.detailTextLabel.text = @"0";
                    break;
                case 3:
                    cell.textLabel.text = @"路径";
                    cell.detailTextLabel.text = @"";
                    break;
        */
                case 2:
                    cell.textLabel.text = @"创建时间";
                    cell.detailTextLabel.text = [m_myInfoDic objectForKey:@"f_create"];
                    break;
                default:
                    break;
            }
            
        }
            break;
        case 1:    
            
            break;
        default:
            break;
    }

    return cell;
}
@end
