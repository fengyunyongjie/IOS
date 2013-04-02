//
//  NDActivityViewController.m
//  NetDisk
//
//  Created by jiangwei on 12-11-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NDActivityViewController.h"

@implementation NDActivityViewController
@synthesize m_tableView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        i = 0;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    [m_tableView setDelegate:nil];
    [m_tableView release],m_tableView=nil;
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect tRect = CGRectMake(0, 0, 320, 480);
    m_tableView = [[BIDragRefreshTableView alloc]initWithFrame:tRect];
    m_tableView.delegate = self;
    [m_tableView enableSectionSelected:YES];
 //   m_tableView.backgroundColor = [UIColor colorWithRed:0.82 green:0.84 blue:0.86 alpha:1];
    [self.view addSubview:m_tableView];
    
    self.navigationItem.title = @"好友动态";
    
    UIBarButtonItem *rightBarButtonItem = [ [ UIBarButtonItem alloc ]  
                                           initWithTitle: NSLocalizedString(@"导入好友", nil)
                                           style: UIBarButtonItemStylePlain  
                                           target: self  
                                           action: @selector(inputMyFriends)  
                                           ];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
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
- (void)inputMyFriends
{
    
}
#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}
#pragma mark - UITableViewDataSource Methods
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    return nil;
	
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    static NSString *CellIdentifier = @"Cell";
    
    NDActivityCell *cell = (NDActivityCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell ==nil){
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NDActivityCell" owner:self options:nil];
		cell = [nib objectAtIndex:0];
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
      //  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
	}
    

    
    
    
    return cell;
}
@end
