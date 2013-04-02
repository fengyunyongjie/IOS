//
//  NDShareViewController.m
//  NetDisk
//
//  Created by jiangwei on 12-11-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NDShareViewController.h"
void callBackShareFunc(Value &jsonValue,void *s_pv);

@implementation NDShareViewController
@synthesize m_tableView;
@synthesize m_listArray;
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
    
    [m_listArray release];
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
    self.navigationItem.title = @"我的共享";
    
    string pid = "1";
 //   scBox.OpenShareFolder(pid,0,-1,callBackShareFunc,self);
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark - CallBackFunc Methods
void callBackShareFunc(Value &jsonValue,void *s_pv)
{
    string vall = jsonValue.toStyledString().c_str();
    NSString *vallStr = [NSString stringWithCString:vall.c_str() encoding:NSUTF8StringEncoding];
    
    [s_pv showShareRootView:vallStr];
}
- (void)showShareRootView:(NSString *)theData
{
    NSDictionary *valueDic = [theData JSONValue];
    int code = [[valueDic objectForKey:@"code"]intValue];
    int total = [[valueDic objectForKey:@"total"]intValue];
    if (code==0&&total>0) {
        m_listArray = [valueDic objectForKey:@"files"];
    }
    else
        m_listArray = nil;
    [m_tableView reloadData];
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
#pragma mark - UITableViewDataSource Methods
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return  nil;
	
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_listArray==nil?0:[m_listArray count];
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    static NSString *CellIdentifier = @"Cell";
    
    NDMainCell *cell = (NDMainCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell ==nil){
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NDMainCell" owner:self options:nil];
		cell = [nib objectAtIndex:0];
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
	}
    
    NSDictionary *cellDic = [m_listArray objectAtIndex:row];
    [cell setDataForSubPath:indexPath dataDic:cellDic];

    return cell;
}


@end
