//
//  NDViewController.m
//  NetDisk
//
//  Created by jiangwei on 12-11-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//


#import "NDViewController.h"
#import "ImageBrowserViewController.h"


void callBackFmFunc(Value &jsonValue,void *s_pv);
void callBackFmSubFunc(Value &jsonValue,void *s_pv);
void callBackFmUploadFunc(Value &jsonValue,void *s_pv);
void callBackFmMkdirFunc(Value &jsonValue,void *s_pv);
void callBackFmDownloadFunc(Value &jsonValue,void *s_pv);
void callBackShareCreateFunc(Value &jsonValue,void *s_pv);
void callBackGetFriendsFunc(Value &jsonValue,void *s_pv);
void callBackFmPasteFunc(Value &jsonValue,void *s_pv);
void callBackFmRmFunc(Value &jsonValue,void *s_pv);
void callBackKeepFunc(Value &jsonValue,void *s_pv);

@implementation NDViewController
@synthesize m_tableView,m_leftButton,m_titleLabel,m_rightButton,m_storeLabel,m_cacleButton,m_pasteButton,m_bottomBackView,m_pastView,m_batchView,m_moveButton,m_normalView,m_shareButton,m_deleteButton,m_editButton;
@synthesize items = _items;
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    counts = 0;
    shareRow = -1;
    
    self.m_titleLabel.text = @"我的虹盘";
    self.m_storeLabel.text = @"";
    UIBarButtonItem *leftBarButtonItem = [ [ UIBarButtonItem alloc ]  
                                          initWithTitle: NSLocalizedString(@"关于", nil)
                                          style: UIBarButtonItemStylePlain  
                                          target: self  
                                          action: @selector(about)  
                                          ];
    UIBarButtonItem *rightBarButtonItem = [ [ UIBarButtonItem alloc ]  
                                           initWithTitle: NSLocalizedString(@"好友动态", nil)
                                           style: UIBarButtonItemStylePlain  
                                           target: self  
                                           action: @selector(activity)  
                                           ];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 100.0, 62.0, 29.0)];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"topIcon_About.png"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarBtn = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem=backBarBtn;
    [backBarBtn release];
    
    UIBarButtonItem *backBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"返回", nil) style:UIBarButtonItemStyleBordered target:nil action:nil];
	self.navigationItem.backBarButtonItem=backBarButtonItem;
	[backBarButtonItem release];
    
    
    
    m_listArray = [[NSMutableArray alloc] initWithCapacity:0];
    /*  
     HUD = [[[MBProgressHUD alloc] initWithView:self.navigationController.view] autorelease];
     [self.navigationController.view addSubview:HUD];
     HUD.delegate = self;
     */   
    CGRect tRect = CGRectMake(0, 44, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen] bounds].size.height-(480-370));
    //NSLog(@"UIScreen mainScreen bounds size (%f, %f, %f , %f)",[[UIScreen mainScreen]bounds].origin.x,[[UIScreen mainScreen]bounds].origin.y,[[UIScreen mainScreen]bounds].size.width,[[UIScreen mainScreen] bounds].size.height);
    m_tableView = [[BIDragRefreshTableView alloc]initWithFrame:tRect];
    m_tableView.delegate = self;
    [m_tableView enableSectionSelected:YES];
    m_tableView.backgroundColor = [UIColor clearColor];
    [self.view insertSubview:m_tableView belowSubview:m_bottomBackView];
    m_tableView.dragRefreshTableView.sectionHeaderHeight = 0;
    [m_tableView.dragRefreshTableView setSeparatorColor:[UIColor clearColor]];
    
    NDLoginViewController *_lv = [[NDLoginViewController alloc] initWithNibName:@"NDLoginViewController" bundle:nil];
    _lv.delegate = self;
    [_lv setNav:self.navigationController];
    [self presentModalViewController:_lv animated:NO];
    [_lv release];
    
    m_hud = [[ATMHud alloc] initWithDelegate:self];
	[self.view addSubview:m_hud.view];
    
    [m_editButton setImage:[UIImage imageNamed:@"topIcon_Complete"] forState:UIControlStateSelected];
    
    [m_deleteButton setImage:[UIImage imageNamed:@"Icons48_Cancel_h"] forState:UIControlStateSelected];
    [m_shareButton setImage:[UIImage imageNamed:@"icon48_share_h"] forState:UIControlStateSelected];
    [m_moveButton setImage:[UIImage imageNamed:@"Icon48_move_h"] forState:UIControlStateSelected];
    
    m_searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
    m_searchBar.backgroundColor = [UIColor clearColor];
    //    m_searchBar.barStyle = UIBarStyleBlackTranslucent;
	m_searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    m_searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	m_searchBar.keyboardType = UIKeyboardTypeDefault;
	m_searchBar.delegate = self;
    
    [[m_searchBar.subviews objectAtIndex:0]removeFromSuperview];
    self.m_tableView.dragRefreshTableView.tableHeaderView = m_searchBar;
}

- (void)dealloc
{
    [m_listArray release],m_listArray=nil;
    /*   if (subFolderView!=nil) {
     [subFolderView release],subFolderView=nil;
     }*/
    [m_listSourceArray release];
    [m_titleLabel release];
    [m_tableView release];
    [m_leftButton release];
    [m_rightButton release];
    [m_storeLabel release];
    [m_pasteButton release];
    [m_cacleButton release];
    [m_bottomBackView release];
    [m_normalView release];
    [m_pastView release];
    [m_batchView release];
    [m_deleteButton release];
    [m_shareButton release];
    [m_moveButton release];
    [m_editButton release];
    
    [m_searchBar release];
    [super dealloc];
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
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"usr_name"];
    NSString *userPwd  = [[NSUserDefaults standardUserDefaults] objectForKey:@"usr_pwd"];
    if (userName==nil&&userPwd==nil) {
        NDLoginViewController *_lv = [[NDLoginViewController alloc] initWithNibName:@"NDLoginViewController" bundle:nil];
        _lv.delegate = self;
        [_lv setNav:self.navigationController];
        [self presentModalViewController:_lv animated:NO];
        [_lv release];
        
        return;
    }
    
    NDAppDelegate *appDelegate =  (NDAppDelegate *)[UIApplication sharedApplication].delegate;
    if ( appDelegate.m_pasteType==PasteTypeFM && appDelegate.m_copyArray!=nil&&[appDelegate.m_copyArray count]>0) {
        [self hiddenPasteButton:NO];
    }
    else{
        [self hiddenPasteButton:YES];
    }
    
    
    [self.m_tableView reloadData];
    
    if (appDelegate.m_parentIdForFresh!=nil&&![appDelegate.m_parentIdForFresh isEqualToString:@""]) {
        if ([appDelegate.m_parentIdForFresh isEqualToString:@"1"]) {
            [self getMainData];
            NSLog(@"%@",appDelegate.m_parentIdForFresh);
            [appDelegate clearFreshID];
        }
    }    
    //    scBox.GetFriendshipsGroupsDeep(0,-1,callBackGetFriendsFunc,self);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    return NO;
}

- (void)about
{
    
}
- (void)activity
{
    NDActivityViewController *_av = [[NDActivityViewController alloc] initWithNibName:@"NDActivityViewController" bundle:nil];
    [self.navigationController pushViewController:_av animated:YES];
    [_av release];
}
-(IBAction)openImage:(id)sender
{
    ImageBrowserViewController *browser=[[ImageBrowserViewController alloc] init];
    [self.navigationController pushViewController:browser animated:YES];
    [browser release];
}
- (IBAction)uploadFile:(id)sender
{
    NDAppDelegate *appDelegate =  (NDAppDelegate *)[UIApplication sharedApplication].delegate;
    NDTaskManagerViewController *t_taskCont= appDelegate._taskMangeView;
    [self.navigationController pushViewController:t_taskCont animated:YES];
    t_taskCont.m_bottom_view.hidden = NO;
    t_taskCont.segment.hidden = YES;
    t_taskCont.segment.selectedSegmentIndex = 0;
    [t_taskCont valueChanged:t_taskCont.segment];
    t_taskCont.m_parentFID = @"1";//上传到根目录
}
- (IBAction)pasteAction:(id)sender
{
    [m_hud setCaption:@"正在粘贴文件..."];
    [m_hud setActivity:YES];
    [m_hud show];
    
    NDAppDelegate *appDelegate =  (NDAppDelegate *)[UIApplication sharedApplication].delegate;
    vector<string> fids;
    for( NSString *m_fid in appDelegate.m_copyArray)
    {
        string fid([m_fid cStringUsingEncoding:NSUTF8StringEncoding]);
        fids.push_back(fid);
    }
    scBox.FmCopyToFolder(appDelegate.m_isCut,"1",fids,callBackFmPasteFunc,self);
    
}
- (IBAction)cancleAction:(id)sender
{
    NDAppDelegate *appDelegate =  (NDAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate clearCopyCache];
    
    [self hiddenPasteButton:YES];
}

- (IBAction)aboutMsg:(id)sender
{
    
}
- (IBAction)frientMsg:(id)sender
{
    
}

- (void)hiddenPasteButton:(BOOL)theBL
{    
    if (theBL) {
        m_pastView.hidden = theBL;
        m_normalView.hidden = !theBL;
        m_batchView.hidden = theBL;
        m_editButton.enabled = theBL;
    }
    else{
        m_pastView.hidden = theBL;
        m_normalView.hidden = !theBL;
        m_batchView.hidden = !theBL;
        m_editButton.enabled = !theBL;
    }
    
}
- (void)hiddenBatchButton:(BOOL)theBL
{    
    if (theBL) {
        m_batchView.hidden = theBL;
        m_normalView.hidden = !theBL;
        m_pastView.hidden = theBL;
    }
    else{
        m_batchView.hidden = theBL;
        m_normalView.hidden = !theBL;
        m_pastView.hidden = !theBL;
    }
    
}
- (IBAction)editAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (!button.selected) {
        NDAppDelegate *appDelegate =  (NDAppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate clearCopyCache];
    }
    
    
    
    [self hiddenBatchButton:m_editButton.selected];
    m_editButton.selected = !m_editButton.selected;
    
    [self.m_tableView.dragRefreshTableView setEditing:m_editButton.selected animated:YES];
    
    
    if (m_editButton.selected) {
        self.items = [NSMutableArray arrayWithCapacity:0];
        for (int i=0; i<[m_listArray count]; i++) {
            Item *item = [[Item alloc] init];
            //     item.title = [NSString stringWithFormat:@"%d",i];
            item.isChecked = NO;
            [_items addObject:item];
            [item release];
        }
    }
    [self.m_tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
}

- (IBAction)deleteAction:(id)sender
{
    [m_hud setCaption:@"正在删除文件"];
    [m_hud setActivity:YES];
    [m_hud show];
    
    vector<string> fids;
    
    for(int i=0;i<[_items count];i++)
    {
        Item *item = [_items objectAtIndex:i];
        if (item.isChecked) {
            NSDictionary *dic = [m_listArray objectAtIndex:i];
            NSString *f_id = [Function covertNumberToString:[dic objectForKey:@"f_id"]];
            string fid([f_id cStringUsingEncoding:NSUTF8StringEncoding]);
            fids.push_back(fid);
        }
        else
            continue;
    }
    
    scBox.FmRm(fids,callBackFmRmFunc,self);
}

- (IBAction)shareAction:(id)sender
{
    [m_hud setCaption:@"正在共享文件夹..."];
    [m_hud setActivity:YES];
    [m_hud show];
    
    NDAppDelegate *appDelegate =  (NDAppDelegate *)[UIApplication sharedApplication].delegate;
    vector<string> member_account = appDelegate->member_account;
    for(int i=0;i<[_items count];i++)
    {
        Item *item = [_items objectAtIndex:i];
        if (item.isChecked) {
            NSDictionary *dic = [m_listArray objectAtIndex:i];
            NSString *f_id = [Function covertNumberToString:[dic objectForKey:@"f_id"]];
            scBox.ShareCreate([f_id cStringUsingEncoding:NSUTF8StringEncoding], member_account,callBackShareCreateFunc,self);
            break;
        }
        else
            continue;
    }
    
}

- (IBAction)moveAction:(id)sender
{
    NDAppDelegate *appDelegate =  (NDAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate clearCopyCache];
    for(int i=0;i<[_items count];i++)
    {
        Item *item = [_items objectAtIndex:i];
        if (item.isChecked) {
            NSDictionary *dic = [m_listArray objectAtIndex:i];
            if (appDelegate.m_copyParentId==nil) {
                appDelegate.m_copyParentId = [Function covertNumberToString:[dic objectForKey:@"f_pid"]];
                appDelegate.m_pasteType = PasteTypeFM;
            }
            NSString *f_id = [Function covertNumberToString:[dic objectForKey:@"f_id"]];
            [appDelegate.m_copyArray addObject:f_id];
        }
        else
            continue;
    }
    
    
    appDelegate.m_isCut = true;
    
    
    [m_hud setCaption:@"已复制"];
    [m_hud setActivity:NO];
    [m_hud show];
    [m_hud hideAfter:0.8f];
    
    [self hiddenPasteButton:NO];
    
    m_editButton.selected = NO;
    m_editButton.enabled = NO;
    [self.m_tableView.dragRefreshTableView setEditing:NO animated:YES];
    [self.m_tableView reloadData];
}
- (IBAction)setting:(id)sender
{
    NDSettingViewController *_st = [[NDSettingViewController alloc] initWithNibName:@"NDSettingViewController" bundle:nil];
    [self.navigationController pushViewController:_st animated:YES];
    [_st release];
}

- (void)showFmInfoAction
{
    NSMutableDictionary *dic = [m_listArray objectAtIndex:shareRow];
    if (dic!=nil) {
        NDFmInfoViewController *fv = [[NDFmInfoViewController alloc] initWithNibName:@"NDFmInfoViewController" bundle:nil];
        fv.m_myInfoDic = dic;
        [self.navigationController pushViewController:fv animated:YES];
        [fv release];
    }   
}
#pragma mark - other Methods
- (void)setEnableButtons:(int)index
{
    NSMutableDictionary *dic = [m_listArray objectAtIndex:index];
    NSString *t_fl = [dic objectForKey:@"f_mime"];
    
    Item* item = [_items objectAtIndex:index];
    if (item.isChecked) {
        selectdCellCount++;
        if ([t_fl isEqualToString:@"directory"])
            selectdCellCountOfDirectory++;
    }
    else{
        selectdCellCount--;
        if ([t_fl isEqualToString:@"directory"])
            selectdCellCountOfDirectory--;
    }
    
    
    if (selectdCellCount>0) {
        m_deleteButton.selected = YES;
        m_deleteButton.userInteractionEnabled = YES;
        m_moveButton.selected = YES;
        m_moveButton.userInteractionEnabled = YES;
        
        if (selectdCellCount ==1 && selectdCellCountOfDirectory==1) {
            m_shareButton.selected = YES;
            m_shareButton.userInteractionEnabled = YES;
        }
        else{
            m_shareButton.selected = NO;
            m_shareButton.userInteractionEnabled = NO;
        }
    }
    else
    {
        [self disEnableButtons];
    }
}

- (void)disEnableButtons
{
    m_deleteButton.selected = NO;
    m_deleteButton.userInteractionEnabled = NO;
    m_moveButton.selected = NO;
    m_moveButton.userInteractionEnabled = NO;
    m_shareButton.selected = NO;
    m_shareButton.userInteractionEnabled = NO;
}
#pragma mark - NDLoginViewControllerDelegate Methods
- (void)getMainData
{
    [m_hud setCaption:@"正在获取..."];
    [m_hud setActivity:YES];
    [m_hud show];
    scBox.FMOpenFolder("1",0,-1,callBackFmFunc,self);
}
#pragma mark - NDMainCellDelegate Methods
- (void)mainCellAddItem:(NDMainCell *)cell
{
    
    /*  if (counts>[m_listArray count]) {
     return;
     }*/
    if(counts==[m_listArray count])
    {
        counts++;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:counts inSection:1];
        NSArray *insertIndexPaths = [[NSArray alloc ]initWithObjects:indexPath, nil];
        [m_tableView.dragRefreshTableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationRight];
        [insertIndexPaths release];
        [self performSelector:@selector(scrollToBottom_tableView) withObject:nil afterDelay:.2];
    }
    
    else if(counts>[m_listArray count])
    {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:counts inSection:1];
        NSArray *insertIndexPaths = [[NSArray alloc ]initWithObjects:indexPath, nil];
        counts--;
        [m_tableView.dragRefreshTableView deleteRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationRight];
        [insertIndexPaths release];
        [self performSelector:@selector(relaseView) withObject:nil afterDelay:0.1f];
        
    }
}
- (void)relaseView
{
    [self mainCellChangeText:nil textEdit:NO];
}
- (void)mainCellAddFinderName:(NSString *)finderName
{
    [m_hud setCaption:@"正在创建文件夹..."];
    [m_hud setActivity:YES];
    [m_hud show];
    [self mainCellChangeText:nil textEdit:NO];
    string s_fn = [finderName cStringUsingEncoding:NSUTF8StringEncoding];
    scBox.FmMKdir(s_fn,"1",callBackFmMkdirFunc,self);
}
- (void)mainCellChangeText:(NDMainCell *)cell textEdit:(BOOL)textEdit
{
    m_tableView.dragRefreshTableView.scrollEnabled = !textEdit;
    m_editButton.enabled = !textEdit;
    if (m_listArray==nil||[m_listArray count]<2) {
        return;
    }
    CGRect rect = m_tableView.frame;    
    [UIView beginAnimations:@"Curl2" context:nil];//动画开始   
	[UIView setAnimationDuration:0.3];   
	[UIView setAnimationDelegate:self];  
	[UIView setAnimationBeginsFromCurrentState:YES];
	
	if (textEdit) {
        rect.origin.y = -130;
        m_tableView.frame = rect;
    }
    else{
        CGRect rect = m_tableView.frame;
        rect.origin.y = 44;
        m_tableView.frame = rect;
    }
    [UIView commitAnimations];
    
    
}

- (void)itemOpertionForCell:(NDMainCell *)cell
{
    
    NSIndexPath *indexPath = cell.m_indexPath;
    shareRow = indexPath.row;
    NSDictionary *dic = [m_listArray objectAtIndex:indexPath.row];
    //    NSString *t_fl = [dic objectForKey:@"f_mime"];
    NSString *f_name = [dic objectForKey:@"f_name"];
    NSString *t_fl = [[dic objectForKey:@"f_mime"] lowercaseString];
    //    NSString *f_id = [Function covertNumberToString:[dic objectForKey:@"f_id"]];
    
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:f_name
                                                    delegate:self
                                           cancelButtonTitle:nil
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:nil];
    as.delegate = self;
    as.tag = TAG_ACTIONSHEET_SHARE;
    if([t_fl isEqualToString:@"png"]||
       [t_fl isEqualToString:@"jpg"]||
       [t_fl isEqualToString:@"jpeg"]||
       [t_fl isEqualToString:@"bmp"])
    {
        [as addButtonWithTitle:NSLocalizedString(@"收 藏",nil)];
    }else
    {
        [as addButtonWithTitle:NSLocalizedString(@"查 看",nil)];
    }
    [as addButtonWithTitle:NSLocalizedString(@"复 制",nil)];
    [as addButtonWithTitle:NSLocalizedString(@"剪 切",nil)];
    [as addButtonWithTitle:NSLocalizedString(@"删 除",nil)];
    [as addButtonWithTitle:NSLocalizedString(@"重命名",nil)];
    [as addButtonWithTitle:NSLocalizedString(@"取 消",nil)];
    as.cancelButtonIndex = [as numberOfButtons] - 1;
    
    [as showInView:self.view];
    [as release];
    
}
#pragma mark - UISearchBarDelegate Methods
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar { 
    
    searchBar.showsScopeBar = YES;  
    [searchBar sizeToFit];  
    [searchBar setShowsCancelButton:YES animated:YES];  
    for(id cc in [m_searchBar subviews])
    {
        if([cc isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)cc;
            [btn setTitle:@"取消"  forState:UIControlStateNormal];
        }
    }
    
    m_editButton.enabled = NO;
    m_bottomBackView.hidden = YES;
    return YES;  
}  
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {  
    //  searchBar.showsScopeBar = NO;  
    //  [searchBar sizeToFit];  
    //  [searchBar setShowsCancelButton:NO animated:YES]; 
    
    //  m_editButton.enabled = YES;
    
    
    return YES;  
}  
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ( searchText==nil||[searchText length]==0) {
        [m_listArray release];
        m_listArray = [m_listSourceArray retain];
        counts = [m_listArray count];
        [self.m_tableView reloadData];
        return;
    }
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:0];
    NSString *searchStr = [searchText lowercaseString];
    for (int i=0; i<[m_listSourceArray count]; i++) {
        NSDictionary *dic = [m_listSourceArray objectAtIndex:i];
        NSString *fileNameStr = [dic objectForKey:@"f_name"];
        NSRange rang = [fileNameStr rangeOfString:searchStr];
        if (rang.location!=NSNotFound) {
            [tempArray addObject:dic];
        }
    }
    [m_listArray release];
    m_listArray = [tempArray retain];
    counts = [m_listArray count];
    [self.m_tableView reloadData];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self performSelector:@selector(showCancleBtn) withObject:nil afterDelay:0.0f];
    return;
}
- (void)showCancleBtn
{
    for(id cc in [m_searchBar subviews])
    {
        if([cc isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)cc;
            btn.enabled = YES;
        }
    }
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.showsScopeBar = NO;  
    [searchBar sizeToFit];  
    [searchBar setShowsCancelButton:NO animated:YES];  
    [searchBar clearsContextBeforeDrawing];
    [searchBar resignFirstResponder];
    
    if ( searchBar.text!=nil&&[searchBar.text length]!=0) {
        [searchBar setText:@""];
        [m_listArray release];
        m_listArray = [m_listSourceArray retain];
        counts = [m_listArray count];
        [self.m_tableView reloadData];
    }
    
    m_editButton.enabled = YES;
    m_bottomBackView.hidden = NO;
}
#pragma mark - UIActionSheetDelegate Methods
- (void)actionSheet:(UIActionSheet *)as clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (as.cancelButtonIndex == buttonIndex) {
        return;
    }
    
    if (as.tag == TAG_ACTIONSHEET_PHOTO){
        switch (buttonIndex) {
            case 0:
            {
                BOOL hasCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
                if (hasCamera) {
                    [self showImagePicker:true];
                }
                else {
                    [self showImagePicker:false];
                }
                break;
            }
            case 1:
                [self showImagePicker:false];
                break;
                
            default:
                break;
        }
    }
    else if (as.tag == TAG_ACTIONSHEET_SHARE||as.tag == TAG_ACTIONSHEET_SINGLE) {
        NSDictionary *dic = [m_listArray objectAtIndex:shareRow];
        NSString *f_id = [Function covertNumberToString:[dic objectForKey:@"f_id"]];
        NDAppDelegate *appDelegate =  (NDAppDelegate *)[UIApplication sharedApplication].delegate;
        
        if (as.tag == TAG_ACTIONSHEET_SHARE)
        {
            switch (buttonIndex) {
                case 0:
                {
                    
                    NSString *t_fl = [[dic objectForKey:@"f_mime"] lowercaseString];
                    if([t_fl isEqualToString:@"png"]||
                       [t_fl isEqualToString:@"jpg"]||
                       [t_fl isEqualToString:@"jpeg"]||
                       [t_fl isEqualToString:@"bmp"])
                    {
                        NSString *f_name = [dic objectForKey:@"f_name"];
                        
                        NSMutableArray *keepedList = [[NSUserDefaults standardUserDefaults] objectForKey:@"nd_keeped_list"];
                        for(NSDictionary *tDic in keepedList)
                        {
                            NSString *t_f_name = [tDic objectForKey:@"f_name"];
                            if ([f_name isEqualToString:t_f_name]) {
                                [m_hud setCaption:@"该文件已收藏"];
                                [m_hud setActivity:NO];
                                [m_hud show];
                                [m_hud hideAfter:0.8f];
                                return;
                            }
                        }
                        NSMutableArray *keepingList = [[NSUserDefaults standardUserDefaults] objectForKey:@"nd_keeping_list"];
                        for(NSDictionary *tDic in keepingList)
                        {
                            NSString *t_f_name = [tDic objectForKey:@"f_name"];
                            if ([f_name isEqualToString:t_f_name]) {
                                [m_hud setCaption:@"该文件已收藏"];
                                [m_hud setActivity:NO];
                                [m_hud show];
                                [m_hud hideAfter:0.8f];
                                return;
                            }
                        }
                        
                        [m_hud setCaption:@"正在收藏..."];
                        [m_hud setActivity:YES];
                        [m_hud show];
                        
                        
                        NSString *savedImagePath=[[Function getKeepCachePath] stringByAppendingPathComponent:f_name];
                        scBox.FmDownloadFile([f_id cStringUsingEncoding:NSUTF8StringEncoding],[savedImagePath cStringUsingEncoding:NSUTF8StringEncoding],false,callBackKeepFunc,self);
                    }
                    else
                    {
                        [self showFmInfoAction];
                    }
                }
                    break;
                    
                case 1://复制
                {
                    [appDelegate clearCopyCache];
                    [appDelegate.m_copyArray addObject:f_id];
                    appDelegate.m_copyParentId = [Function covertNumberToString:[dic objectForKey:@"f_pid"]];
                    appDelegate.m_isCut = false;
                    appDelegate.m_pasteType = PasteTypeFM;
                    
                    [m_hud setCaption:@"已复制"];
                    [m_hud setActivity:NO];
                    [m_hud show];
                    [m_hud hideAfter:0.8f];
                    
                    [self hiddenPasteButton:NO];
                }
                    break;
                case 2://剪切
                {
                    [appDelegate clearCopyCache];
                    [appDelegate.m_copyArray addObject:f_id];
                    appDelegate.m_copyParentId = [Function covertNumberToString:[dic objectForKey:@"f_pid"]];
                    appDelegate.m_isCut = true;
                    appDelegate.m_pasteType = PasteTypeFM;
                    
                    [m_hud setCaption:@"已复制"];
                    [m_hud setActivity:NO];
                    [m_hud show];
                    [m_hud hideAfter:0.8f];
                    
                    [self hiddenPasteButton:NO];
                }
                    break;
                case 3://删除
                {
                    [m_hud setCaption:@"正在删除文件"];
                    [m_hud setActivity:YES];
                    [m_hud show];
                    
                    vector<string> fids;
                    string fid([f_id cStringUsingEncoding:NSUTF8StringEncoding]);
                    fids.push_back(fid);
                    scBox.FmRm(fids,callBackFmRmFunc,self);
                }      
                    break;
                case 4:
                {
                    UIRenameViewController *rv=[[UIRenameViewController alloc]initWithNibName:@"UIRenameViewController" bundle:nil];
                    NSMutableDictionary *tDic = [m_listArray objectAtIndex:shareRow];
                    rv.m_reanmeDic = tDic;
                    [self.navigationController pushViewController:rv animated:YES];
                    [rv release];
                }
                    break;
                default:
                    break;
            }
        }
        else if (as.tag == TAG_ACTIONSHEET_SINGLE)
        {
            switch (buttonIndex) {
                case 0://查看
                {
                    [self showFmInfoAction];
                }    
                    break;
                case 1://下载、打开
                {
                    NSString *f_name = [dic objectForKey:@"f_name"];
                    
                    NSString *savedImagePath=[[Function getImgCachePath] stringByAppendingPathComponent:f_name];
                    if([Function fileSizeAtPath:savedImagePath]<2)
                    {
                        NSString *keepedImagePath=[[Function getKeepCachePath] stringByAppendingPathComponent:f_name];
                        if([Function fileSizeAtPath:keepedImagePath]<2)//下载
                        {
                            [m_hud setCaption:@"正在下载"];
                            [m_hud setActivity:YES];
                            [m_hud show];
                            scBox.FmDownloadFile([f_id cStringUsingEncoding:NSUTF8StringEncoding],[savedImagePath cStringUsingEncoding:NSUTF8StringEncoding],true,callBackFmDownloadFunc,self);
                        }
                        else//打开
                        {
                            
                            NSString *t_fl = [[dic objectForKey:@"f_mime"] lowercaseString];
                            if([t_fl isEqualToString:@"png"]||
                               [t_fl isEqualToString:@"jpg"]||
                               [t_fl isEqualToString:@"jpeg"]||
                               [t_fl isEqualToString:@"bmp"])
                            {
                                ImageShowViewController *imageShow = [[ImageShowViewController alloc]initWithNibName:@"ImageShowViewController" bundle:nil];
                                imageShow.picPath=keepedImagePath;
                                [self.navigationController pushViewController:imageShow animated:YES];
                                [imageShow release];
                            }
                            else
                            {
                                [m_hud setCaption:NSLocalizedString(@"不提供此类文件预览",nil)];
                                [m_hud setActivity:NO];
                                [m_hud show];
                                [m_hud hideAfter:0.8f];
                            }
                        }
                    }
                    else//打开
                    {
                        NSString *t_fl = [[dic objectForKey:@"f_mime"] lowercaseString];
                        if([t_fl isEqualToString:@"png"]||
                           [t_fl isEqualToString:@"jpg"]||
                           [t_fl isEqualToString:@"jpeg"]||
                           [t_fl isEqualToString:@"bmp"])
                        {
                            ImageShowViewController *imageShow = [[ImageShowViewController alloc]initWithNibName:@"ImageShowViewController" bundle:nil];
                            imageShow.picPath=savedImagePath;
                            [self.navigationController pushViewController:imageShow animated:YES];
                            [imageShow release];
                        }
                        else
                        {
                            [m_hud setCaption:NSLocalizedString(@"不提供此类文件预览",nil)];
                            [m_hud setActivity:NO];
                            [m_hud show];
                            [m_hud hideAfter:0.8f];
                        }
                    }
                }
                    break;
                case 2://复制
                {
                    [appDelegate clearCopyCache];
                    [appDelegate.m_copyArray addObject:f_id];
                    appDelegate.m_copyParentId = [Function covertNumberToString:[dic objectForKey:@"f_pid"]];
                    appDelegate.m_isCut = false;
                    appDelegate.m_pasteType = PasteTypeFM;
                    
                    [m_hud setCaption:@"已复制"];
                    [m_hud setActivity:NO];
                    [m_hud show];
                    [m_hud hideAfter:0.8f];
                    
                    [self hiddenPasteButton:NO];
                }
                    break;
                case 3://剪切
                {
                    [appDelegate clearCopyCache];
                    [appDelegate.m_copyArray addObject:f_id];
                    appDelegate.m_copyParentId = [Function covertNumberToString:[dic objectForKey:@"f_pid"]];
                    appDelegate.m_isCut = true;
                    appDelegate.m_pasteType = PasteTypeFM;
                    
                    [m_hud setCaption:@"已复制"];
                    [m_hud setActivity:NO];
                    [m_hud show];
                    [m_hud hideAfter:0.8f];
                    
                    [self hiddenPasteButton:NO];
                }
                    break;
                case 4://删除
                {
                    [m_hud setCaption:@"正在删除文件"];
                    [m_hud setActivity:YES];
                    [m_hud show];
                    
                    vector<string> fids;
                    string fid([f_id cStringUsingEncoding:NSUTF8StringEncoding]);
                    fids.push_back(fid);
                    scBox.FmRm(fids,callBackFmRmFunc,self);
                }      
                    break;
                case 5:
                {
                    NSString *f_name = [dic objectForKey:@"f_name"];
                    
                    NSMutableArray *keepedList = [[NSUserDefaults standardUserDefaults] objectForKey:@"nd_keeped_list"];
                    for(NSDictionary *tDic in keepedList)
                    {
                        NSString *t_f_name = [tDic objectForKey:@"f_name"];
                        if ([f_name isEqualToString:t_f_name]) {
                            [m_hud setCaption:@"该文件已收藏"];
                            [m_hud setActivity:NO];
                            [m_hud show];
                            [m_hud hideAfter:0.8f];
                            return;
                        }
                    }
                    NSMutableArray *keepingList = [[NSUserDefaults standardUserDefaults] objectForKey:@"nd_keeping_list"];
                    for(NSDictionary *tDic in keepingList)
                    {
                        NSString *t_f_name = [tDic objectForKey:@"f_name"];
                        if ([f_name isEqualToString:t_f_name]) {
                            [m_hud setCaption:@"该文件已收藏"];
                            [m_hud setActivity:NO];
                            [m_hud show];
                            [m_hud hideAfter:0.8f];
                            return;
                        }
                    }
                    
                    [m_hud setCaption:@"正在收藏..."];
                    [m_hud setActivity:YES];
                    [m_hud show];
                    
                    
                    NSString *savedImagePath=[[Function getKeepCachePath] stringByAppendingPathComponent:f_name];
                    scBox.FmDownloadFile([f_id cStringUsingEncoding:NSUTF8StringEncoding],[savedImagePath cStringUsingEncoding:NSUTF8StringEncoding],false,callBackKeepFunc,self);
                    
                    //                    NSString *savedImagePath=[[Function getImgCachePath] stringByAppendingPathComponent:f_name];
                    //                    if([Function fileSizeAtPath:savedImagePath]<2)
                    //                    {
                    //                        [m_hud setCaption:@"正在收藏..."];
                    //                        [m_hud setActivity:YES];
                    //                        [m_hud show];
                    //                        savedImagePath=[[Function getKeepCachePath] stringByAppendingPathComponent:f_name];
                    //                        scBox.FmDownloadFile([f_id cStringUsingEncoding:NSUTF8StringEncoding],[savedImagePath cStringUsingEncoding:NSUTF8StringEncoding],callBackKeepFunc,self);
                    //                    }
                    //                    else
                    //                    {
                    //                        NSString *fromImagePath=[[Function getImgCachePath] stringByAppendingPathComponent:f_name];
                    //                        NSString *toImagePath=[[Function getKeepCachePath] stringByAppendingPathComponent:f_name];
                    //                        NSFileManager *fileManager = [NSFileManager defaultManager];
                    //                        BOOL success = [fileManager copyItemAtPath:fromImagePath toPath:toImagePath error:nil];
                    //                        if (!success) {
                    //                            [m_hud setCaption:@"加入收藏失败"];
                    //                            [m_hud setActivity:NO];
                    //                            [m_hud show];
                    //                        }
                    //                        else
                    //                        {
                    //                            NSMutableArray *keepedList = [[NSUserDefaults standardUserDefaults] objectForKey:@"nd_keeped_list"];
                    //                            if (keepedList==nil) {
                    //                                keepedList = [NSMutableArray array];
                    //                                
                    //                            }
                    //                            /*直接加入了dic，则无法插入NSUserDefaults，奇怪，估计dic内数据有异常。*/
                    //                            NSMutableDictionary *dd = [NSMutableDictionary dictionary];
                    //                            [dd setObject:[dic objectForKey:@"f_mime"] forKey:@"f_mime"];
                    //                            [dd setObject:[dic objectForKey:@"f_name"] forKey:@"f_name"];
                    //                            [keepedList insertObject:dd atIndex:0];
                    //                          /*  else{
                    //                                NSMutableArray *tempList = [NSMutableArray arrayWithArray:keepedList];
                    //                                [tempList insertObject:dic atIndex:0];
                    //                                keepedList = [NSArray arrayWithArray:tempList];
                    //                            }*/
                    //                            [[NSUserDefaults standardUserDefaults] setObject:keepedList forKey:@"nd_keeped_list"];
                    //                            [[NSUserDefaults standardUserDefaults] synchronize];
                    //                            
                    //                            [m_hud setCaption:@"已加入收藏"];
                    //                            [m_hud setActivity:NO];
                    //                            [m_hud show];
                    //                        }
                    //                        [m_hud hideAfter:0.8f];
                    //                    }
                    
                }    
                    break;
                case 6:
                {
                    UIRenameViewController *rv=[[UIRenameViewController alloc]initWithNibName:@"UIRenameViewController" bundle:nil];
                    NSMutableDictionary *tDic = [m_listArray objectAtIndex:shareRow];
                    rv.m_reanmeDic = tDic;
                    [self.navigationController pushViewController:rv animated:YES];
                    [rv release];
                }
                    break;
                default:
                    break;
            }
        }
        
    }
    
    
}
#pragma mark - UIImagePickerController Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    [m_hud setCaption:@"正在上传图片..."];
    [m_hud setActivity:YES];
    [m_hud show];
	if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        
    }
    //需要修改未temp目录下保存	
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *timeStr = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter release];
    
    NSData *imagedata=UIImagePNGRepresentation(image);
    
    NSString *savedImagePath=[[Function getTempCachePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",timeStr]];
    [imagedata writeToFile:savedImagePath atomically:YES];
    
    
    
    [self performSelector:@selector(uploadPic:) withObject:savedImagePath afterDelay:0.0f];
    
	[picker dismissModalViewControllerAnimated:YES];
	[imagePickerController.view removeFromSuperview];
    
    
}
- (void)uploadPic:(NSString *)theFileName
{
    scBox.FmUpload("1", [theFileName cStringUsingEncoding:NSUTF8StringEncoding], "",callBackFmUploadFunc,self);
}
#pragma mark -
#pragma mark BIDragRefreshTableViewDelegate

-(void)refreshTableHeaderViewDataSourceDidStartLoad:(BIRefreshTableHeaderView *) refreshTableHeaderView{
    
    if (m_editButton.selected) { 
        [m_tableView dataSourceDidFinishedLoad:m_tableView.headerView];
        return ;
    }
    
    [self performSelector:@selector(hiddenSearchCancelButton) withObject:nil afterDelay:0.01f];
    
    [self getMainData];
}
- (void)hiddenSearchCancelButton
{
    
    [m_searchBar setText:@""];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[picker dismissModalViewControllerAnimated:true];
}
#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.m_tableView.dragRefreshTableView.editing)
	{
        Item* item = [_items objectAtIndex:indexPath.row];
		NDMainCell *cell = (NDMainCell*)[tableView cellForRowAtIndexPath:indexPath];
        item.isChecked = !item.isChecked;
		[cell setChecked:item.isChecked];
        [self setEnableButtons:indexPath.row];
	}
    else
    {
   //     if(!m_editButton.enabled)
     //       return;
        switch (indexPath.section) {
            case 0:
            {
                switch (indexPath.row) {
                    case 0:
                    {  
                        NDMainViewController *subFolderView = [[NDMainViewController alloc] initWithNibName:@"NDMainViewController" bundle:nil];
                        subFolderView.m_parentType = PShareViewController;
                        subFolderView.m_title =[NSString stringWithString:@"我的共享"] ;
                        subFolderView.m_parentFID = @"1";
                        [self.navigationController pushViewController:subFolderView animated:YES];
                        [subFolderView release];
                    }
                        break;
//                    case 1:
//                    {   
//                        NDPhotoViewController *pv = [[NDPhotoViewController alloc]initWithNibName:@"NDPhotoViewController" bundle:nil];
//                        [self.navigationController pushViewController:pv animated:YES];
//                        [pv release];
//                    }
//                        break;
                    case 1:
                    {   
                        NDKeepViewController *_kp = [[NDKeepViewController alloc] initWithNibName:@"NDKeepViewController" bundle:nil];
                        
                        //    subFolderView.m_title =[NSString stringWithString:@"我的空间"] ;
                        [self.navigationController pushViewController:_kp animated:YES];
                        [_kp release];
                    }
                        break;
  
                    case 2:
                    {
                        NDAppDelegate *appDelegate =  (NDAppDelegate *)[UIApplication sharedApplication].delegate;
                        NDTaskManagerViewController *t_taskCont= appDelegate._taskMangeView;
                        [self.navigationController pushViewController:t_taskCont animated:YES];
                        t_taskCont.m_bottom_view.hidden = YES;
                        t_taskCont.segment.hidden = NO;
                        
                    }
                        break;
                    default:
                        break;
                }
            }
                break;
                
            case 1:
            {
                if (indexPath.row>=[m_listArray count]) {
                    return;
                }
                NSMutableDictionary *dic = [m_listArray objectAtIndex:indexPath.row];
                NSString *t_fl = [dic objectForKey:@"f_mime"];
                NSString *f_id = [Function covertNumberToString:[dic objectForKey:@"f_id"]];
                if ([t_fl isEqualToString:@"directory"]) { 
                    NDMainViewController *subFolderView = [[NDMainViewController alloc] initWithNibName:@"NDMainViewController" bundle:nil];
                    subFolderView.m_parentType = PViewController;
                    subFolderView.m_title = [dic objectForKey:@"f_name"];
                    subFolderView.m_parentFID = f_id;
                    subFolderView.m_infoDic = dic;
                    [self.navigationController pushViewController:subFolderView animated:YES];
                    [subFolderView release];
                }
                else{ 
                    shareRow = indexPath.row;
                    NSDictionary *dic = [m_listArray objectAtIndex:indexPath.row];
                    NSString *f_name = [dic objectForKey:@"f_name"];
                    
                    NSString *t_fl = [[dic objectForKey:@"f_mime"] lowercaseString];
                    if([t_fl isEqualToString:@"png"]||
                       [t_fl isEqualToString:@"jpg"]||
                       [t_fl isEqualToString:@"jpeg"]||
                       [t_fl isEqualToString:@"bmp"])
                    {
                        NSLog(@"选中的是图片文件，所有直接进入图片预览！！！！");
                        NSString *savedImagePath=[[Function getImgCachePath] stringByAppendingPathComponent:f_name];
                        ImageShowViewController *imageShow = [[ImageShowViewController alloc]initWithNibName:@"ImageShowViewController" bundle:nil];
                        imageShow.picPath=savedImagePath;
                        imageShow.m_index=indexPath.row;
                        imageShow.m_listArray=m_listArray;
                        [self.navigationController pushViewController:imageShow animated:YES];
                        [imageShow release];                        
                    }
                    else
                    {
                        [m_hud setCaption:NSLocalizedString(@"不提供此类文件预览",nil)];
                        [m_hud setActivity:NO];
                        [m_hud show];
                        [m_hud hideAfter:0.8f];
//                        UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:f_name
//                                                                        delegate:self
//                                                               cancelButtonTitle:nil
//                                                          destructiveButtonTitle:nil
//                                                               otherButtonTitles:nil];
//                        as.delegate = self;
//                        as.tag = TAG_ACTIONSHEET_SINGLE;
//                        
//                        NSString *savedImagePath=[[Function getImgCachePath] stringByAppendingPathComponent:f_name];
//                        NSString *keepedImagePath=[[Function getKeepCachePath] stringByAppendingPathComponent:f_name];
//                        [as addButtonWithTitle:NSLocalizedString(@"查 看",nil)];
//                        if([Function fileSizeAtPath:savedImagePath]<2 && [Function fileSizeAtPath:keepedImagePath]<2)
//                            [as addButtonWithTitle:NSLocalizedString(@"下 载",nil)];
//                        else
//                            [as addButtonWithTitle:NSLocalizedString(@"打开",nil)];
//                        [as addButtonWithTitle:NSLocalizedString(@"复 制",nil)];
//                        [as addButtonWithTitle:NSLocalizedString(@"剪 切",nil)];
//                        [as addButtonWithTitle:NSLocalizedString(@"删 除",nil)];
//                        [as addButtonWithTitle:NSLocalizedString(@"收 藏",nil)];
//                        [as addButtonWithTitle:NSLocalizedString(@"重命名",nil)];
//                        [as addButtonWithTitle:NSLocalizedString(@"取 消",nil)];
//                        as.cancelButtonIndex = [as numberOfButtons] - 1;
//                        
//                        [as showInView:self.view];
//                        [as release];
                    }
                }
            }
                break;
            default:
                break;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        return NO;
    }
    return m_editButton.selected;
}
#pragma mark - UITableViewDataSource Methods
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        return UITableViewCellEditingStyleNone;
    }
	return  (UITableViewCellEditingStyle)(UITableViewCellEditingStyleDelete|UITableViewCellEditingStyleInsert); 
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
        case 0:
            return NSLocalizedString(@"我的共享", nil);
            break;
        case 1:
            return NSLocalizedString(@"网盘文件", nil);
            break;
        default:
            return nil;
            break;
    }
	
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 0;
            break;
        case 1:
            return 30;
            break;    
        default:
            return 30;
            break;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    if (section==0) {
        return nil;
    }
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return  nil;
    }
    
    UILabel * label = [[[UILabel alloc] init] autorelease];
    label.frame = CGRectMake(10, 0, 320, 30);
    label.backgroundColor = [UIColor clearColor];
    label.font=[UIFont fontWithName:@"Arial" size:14];
    label.textColor = [UIColor whiteColor];
    label.text = sectionTitle;
    
    UIView * sectionView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)] autorelease];
    [sectionView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"title_bg"]]];
    [sectionView addSubview:label];
    return sectionView;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //列表每次刷新都要初始化数据
    selectdCellCount = 0;
    selectdCellCountOfDirectory = 0;
    [self disEnableButtons];
    
    switch (section) {
        case 0:
            return 3;
            break;
        case 1:
            if (m_editButton.selected)
                return [m_listArray count];
            else
                return counts+1;
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
    static NSString *CellIdentifier = @"Cell";
    static NSString *CellIdentifierAdd = @"CellAdd";
    static NSString *CellIdentifierAddText = @"CellAddText";
    NDMainCell *cell = nil;
    
    if (section == 0) {
        cell = (NDMainCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell ==nil){
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NDMainCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            
        }
        [cell setData:indexPath dataDic:nil];
    }
    else if(section == 1)
    {
        if (row<[m_listArray count]) {
            cell = (NDMainCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell ==nil){
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NDMainCell" owner:self options:nil];
                cell = [nib objectAtIndex:0];
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
                
                cell.delegate = self;
            }
            NSDictionary *cellDic = [m_listArray objectAtIndex:row];
            [cell setData:indexPath dataDic:cellDic];
            
            if (m_editButton.selected)
            {
                Item* item = [_items objectAtIndex:indexPath.row];
                [cell setChecked:item.isChecked];
            }
        }
        else if(row==[m_listArray count]){
            cell = (NDMainCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifierAdd];
            if (cell ==nil){
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NDMainCellAdd" owner:self options:nil];
                cell = [nib objectAtIndex:0];
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
                cell.delegate = self;
            }
            
        }
        else if(row>[m_listArray count]){
            cell = (NDMainCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifierAddText];
            if (cell ==nil){
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NDMainCellAddText" owner:self options:nil];
                cell = [nib objectAtIndex:0];
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
                cell.delegate = self;
            }
            
            
        }
        
    }
    
    return cell;
}
-(void)scrollToBottom_tableView
{
    
    NSIndexPath * ndxPath= [NSIndexPath indexPathForRow:counts inSection:1];
    [m_tableView.dragRefreshTableView scrollToRowAtIndexPath:ndxPath atScrollPosition:UITableViewScrollPositionBottom  animated:NO];
    
}
#pragma mark - CallBackFunc Methods
void callBackFmFunc(Value &jsonValue,void *s_pv){
    
    string vall = jsonValue.toStyledString().c_str();
    NSString *vallStr = [NSString stringWithCString:vall.c_str() encoding:NSUTF8StringEncoding];
    
    [s_pv parseReturnData:vallStr];
    /*    
     int code = jsonValue["code"].asInt();
     int total = jsonValue["total"].asInt(); 
     if (code==0) {
     if(jsonValue.isMember("files"))
     {
     Value filesValue = jsonValue["files"];
     int size = filesValue.size();
     for (int i=0; i<size; ++i) {
     string name = filesValue[i]["f_name"].asString();
     printf(name.c_str(),nil);
     }
     }
     
     int total = jsonValue["total"].asInt(); 
     if (total>0) {
     
     }
     }
     else
     {
     UIAlertView *alertView  = [[UIAlertView alloc]initWithTitle:@"未获得文件" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
     [alertView show];
     [alertView release];
     }
     */   
}
void callBackFmUploadFunc(Value &jsonValue,void *s_pv)
{
    sleep(1);
    string vall = jsonValue.toStyledString().c_str();
    NSString *vallStr = [NSString stringWithCString:vall.c_str() encoding:NSUTF8StringEncoding];
    [s_pv uploadFileSucess:vallStr];
    
}
void callBackFmSubFunc(Value &jsonValue,void *s_pv)
{
    string vall = jsonValue.toStyledString().c_str();
    NSString *vallStr = [NSString stringWithCString:vall.c_str() encoding:NSUTF8StringEncoding];
    [s_pv showFmSubView:vallStr];
}
void callBackFmMkdirFunc(Value &jsonValue,void *s_pv)
{
    
    string vall = jsonValue.toStyledString().c_str();
    NSString *vallStr = [NSString stringWithCString:vall.c_str() encoding:NSUTF8StringEncoding];
    [s_pv showFmMkdirView:vallStr];
}
void callBackFmDownloadFunc(Value &jsonValue,void *s_pv)
{
    sleep(1);
    
    string vall = jsonValue.toStyledString().c_str();
    NSString *vallStr = [NSString stringWithCString:vall.c_str() encoding:NSUTF8StringEncoding];
    [s_pv downloadFileSucess:vallStr];
}
void callBackShareCreateFunc(Value &jsonValue,void *s_pv)
{
    sleep(1);
    string vall = jsonValue.toStyledString().c_str();
    NSString *vallStr = [NSString stringWithCString:vall.c_str() encoding:NSUTF8StringEncoding];
    [s_pv showShareFileFinder:vallStr];
}
void callBackGetFriendsFunc(Value &jsonValue,void *s_pv)
{
    string vall = jsonValue.toStyledString().c_str();
    NSString *vallStr = [NSString stringWithCString:vall.c_str() encoding:NSUTF8StringEncoding];
    
    NSData *data =  [vallStr dataUsingEncoding:NSUTF8StringEncoding];
    NSArray*paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentsDirectory=[paths objectAtIndex:0]; 
    NSString *savedImagePath=[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt",@"friends"]];
    [data writeToFile:savedImagePath atomically:YES];
    vector<string> member_account;
    NSDictionary *valueDic = [vallStr JSONValue];
    int code = [[valueDic objectForKey:@"code"]intValue];
    if (code==0)
    {
        int groupCount = [[valueDic objectForKey:@"total"]intValue];
        if (groupCount>0) {
            NSArray *groupArray = [valueDic objectForKey:@"groups"];
            for(NSDictionary *groupDic in groupArray)
            {
                NSArray *friendArray = [groupDic objectForKey:@"friends"];
                for(NSDictionary *friendDic in friendArray)
                {
                    NSString *friendid = [friendDic objectForKey:@"friendid"];
                    if (friendid==nil||[friendid isEqualToString:@""]) {
                        continue;
                    }
                    string s_friendid = [friendid cStringUsingEncoding:NSUTF8StringEncoding];
                    member_account.push_back(s_friendid);
                }
            }
        }
        NDAppDelegate *appDelegate =  (NDAppDelegate *)[UIApplication sharedApplication].delegate;
        appDelegate->member_account = member_account;
    }
}
void callBackFmPasteFunc(Value &jsonValue,void *s_pv)
{
    sleep(1);
    
    int a = jsonValue["code"].asInt();
    if (a==0) {
        NDAppDelegate *appDelegate =  (NDAppDelegate *)[UIApplication sharedApplication].delegate;
        if (appDelegate.m_isCut==true) {
            appDelegate.m_parentIdForFresh = [NSString stringWithString:appDelegate.m_copyParentId];
        }
    }
    
    string vall = jsonValue.toStyledString().c_str();
    NSString *vallStr = [NSString stringWithCString:vall.c_str() encoding:NSUTF8StringEncoding];
    [s_pv showSuccessInfo:vallStr infoStr:@"粘贴"];
    
    
}
void callBackFmRmFunc(Value &jsonValue,void *s_pv)
{
    sleep(1);
    string vall = jsonValue.toStyledString().c_str();
    NSString *vallStr = [NSString stringWithCString:vall.c_str() encoding:NSUTF8StringEncoding];
    [s_pv showSuccessInfo:vallStr infoStr:@"删除"];
}
void callBackKeepFunc(Value &jsonValue,void *s_pv)
{
    
    string vall = jsonValue.toStyledString().c_str();
    NSString *vallStr = [NSString stringWithCString:vall.c_str() encoding:NSUTF8StringEncoding];
    [s_pv keepFileSucess:vallStr];
}
#pragma mark - Pri Methods
- (void)keepFileSucess:(NSString *)theData
{
    NSDictionary *valueDic = [theData JSONValue];
    
    int code = [[valueDic objectForKey:@"code"]intValue];
    if (code == 0) {
        [m_hud setCaption:@"已成功加入收藏"];
        
        [self performSelector:@selector(saveKeep) withObject:nil afterDelay:0.1f];
    }
    else{
        [m_hud setCaption:@"加入收藏失败"];
    }
    [m_hud setActivity:NO];
    [m_hud update];
    [self performSelectorOnMainThread:@selector(hiddenHub) withObject:nil waitUntilDone:NO];
}
- (void)saveKeep
{
    NSMutableArray *keepingList = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"nd_keeping_list"]];
    if (keepingList==nil) {
        keepingList = [NSMutableArray array];
    }
    NSDictionary *dic = [m_listArray objectAtIndex:shareRow];
    NSMutableDictionary *dd = [NSMutableDictionary dictionary];
    [dd setObject:[dic objectForKey:@"f_mime"] forKey:@"f_mime"];
    [dd setObject:[dic objectForKey:@"f_name"] forKey:@"f_name"];
    NSString *f_id = [Function covertNumberToString:[dic objectForKey:@"f_id"]];
    [dd setObject:f_id forKey:@"f_id"];
    [dd setObject:[dic objectForKey:@"compressaddr"] forKey:@"compressaddr"];
    [keepingList insertObject:dd atIndex:0];
    [[NSUserDefaults standardUserDefaults] setObject:keepingList forKey:@"nd_keeping_list"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)showFmMkdirView:(NSString *)theData
{
    NSDictionary *valueDic = [theData JSONValue];
    
    int code = [[valueDic objectForKey:@"code"]intValue];
    if (code==0) {
        [m_hud setCaption:@"文件夹创建成功"];
        [m_hud setImage:[UIImage imageNamed:@"19-check"]];
        scBox.FMOpenFolder("1",0,-1,callBackFmFunc,self);
    }
    else{
        [m_hud setCaption:@"文件夹创建失败"];
        [m_hud setImage:[UIImage imageNamed:@"11-x"]];
    }
    [m_hud setActivity:NO];
    [m_hud update];
    [self performSelectorOnMainThread:@selector(hiddenHub) withObject:nil waitUntilDone:NO];
}
- (void)showImagePicker:(BOOL)hasCamera{
	if( imagePickerController == nil )
	{
		imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
	}
    
	if (hasCamera) 
		imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	else
		imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	
    [self presentModalViewController:imagePickerController animated:YES];
	
    
}
- (void)uploadFileSucess:(NSString *)theData
{
    
    NSDictionary *valueDic = [theData JSONValue];
    
    int code = [[valueDic objectForKey:@"code"]intValue];
    if (code == 0) {
        //  [self performSelector:@selector(startTask) withObject:nil afterDelay:0.3f];
        [m_hud setCaption:@"已加入上传队列"];
    }
    else{
        [m_hud setCaption:@"加入上传队列失败"];
    }
    [m_hud setActivity:NO];
    [m_hud update];
    [self performSelectorOnMainThread:@selector(hiddenHub) withObject:nil waitUntilDone:NO];
}
- (void)downloadFileSucess:(NSString *)theData
{
    NSDictionary *valueDic = [theData JSONValue];
    
    int code = [[valueDic objectForKey:@"code"]intValue];
    if (code == 0) {
        //  [self performSelector:@selector(startTask) withObject:nil afterDelay:0.3f];
        [m_hud setCaption:@"已加入下载队列"];
    }
    else{
        [m_hud setCaption:@"加入下载对列失败"];
    }
    [m_hud setActivity:NO];
    [m_hud update];
    [self performSelectorOnMainThread:@selector(hiddenHub) withObject:nil waitUntilDone:NO];
}
-(void)startTask
{
    if (task) {
        task->Start();
    }
}
- (void)parseReturnData:(NSString *)theData
{
    NSDictionary *valueDic = [theData JSONValue];
    
    int code = [[valueDic objectForKey:@"code"]intValue];
    int total = [[valueDic objectForKey:@"total"]intValue];
    if (code==0&&total>0) {
        /*   [m_listArray removeAllObjects];
         for (int i=0; i<total; i++) {
         [m_listArray addObject:[[valueDic objectForKey:@"files"] objectAtIndex:i]];
         }
         //     m_listArray = [NSArray arrayWithArray:[valueDic objectForKey:@"files"]] ;
         NSLog(@"%@",m_listArray);
         */
     //   NSIndexSet *set = [NSIndexSet indexSetWithIndex:0];
        NSArray *tArray = [valueDic objectForKey:@"files"];
     //   tArray = [self sortList:tArray];
        m_listArray = [tArray retain];
        counts = [m_listArray count];
        [m_listSourceArray release];
        m_listSourceArray = [tArray retain];
        [m_tableView reloadData];
        NSDictionary *dataDic;
        int noc=0;
        for (dataDic in m_listArray) {
            NSString *t_fl = [[dataDic objectForKey:@"f_mime"] lowercaseString];
            if ([t_fl isEqualToString:@"png"]||
                [t_fl isEqualToString:@"jpg"]||
                [t_fl isEqualToString:@"jpeg"]||
                [t_fl isEqualToString:@"bmp"]) {
                NSNumber *daf =[dataDic objectForKey:@"f_id"];
                string f_id = [[Function covertNumberToString:daf] cStringUsingEncoding:NSUTF8StringEncoding];
                NSString *picName = [Function picFileNameFromURL:[dataDic objectForKey:@"compressaddr"]];
                NSString *picPath = [NSString stringWithFormat:@"%@/%@",[Function getTempCachePath],picName];
                
                UIImage *image = [UIImage imageWithContentsOfFile:picPath];
                if (image) {
                }else
                {
                    SevenCBoxClient::FmDownloadThumbFile(f_id,[picPath cStringUsingEncoding:NSUTF8StringEncoding]);
                    noc++;
                }
            }  
        }
        if (noc!=0) {
            SevenCBoxClient::StartTaskMonitor();
        }
    }
    [m_tableView dataSourceDidFinishedLoad:m_tableView.headerView];
    if (code==0)
    {
        
    }    
    else
    {
        [m_hud setCaption:@"获取失败!"];
        [m_hud setImage:[UIImage imageNamed:@"11-x"]];
        [m_hud setActivity:NO];
        [m_hud update];
    }
	
    [self performSelectorOnMainThread:@selector(hiddenHub) withObject:nil waitUntilDone:NO];
}

- (void)showFmSubView:(NSString *)theData
{
    /*    NSDictionary *valueDic = [theData JSONValue];
     
     int code = [[valueDic objectForKey:@"code"]intValue];
     int total = [[valueDic objectForKey:@"total"]intValue];
     if (code==0&&total>0) {
     NSArray *tArray = [valueDic objectForKey:@"files"];
     [subFolderView.m_listArray release];
     subFolderView.m_listArray = tArray;
     
     }
     [self.navigationController pushViewController:subFolderView animated:YES];
     */    
}
- (NSArray *)sortList:(NSArray *)sourceArray
{
    //ortUsingDescriptors: 适合元素是dict类型，initWithKey既是dict key.
    
    
    NSSortDescriptor *sd1 = [NSSortDescriptor sortDescriptorWithKey:@"f_name" ascending:NO];
    
    NSArray *_ar = [sourceArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sd1, nil]];
    /*    
     for (int i=0; i<[_ar count]; i++) {
     NSDictionary *dic = [_ar objectAtIndex:i];
     NSLog(@"network=%d,created_at=%@",[[dic objectForKey:@"network"] intValue],[dic objectForKey:@"sortTime"]);
     }*/
    return _ar;
}


- (void)showShareFileFinder:(NSString *)theData
{
    
    NSDictionary *valueDic = [theData JSONValue];
    int code = [[valueDic objectForKey:@"code"]intValue];
    if (code==0)
    {
        [m_hud setCaption:@"共享成功!"];
        [m_hud setImage:[UIImage imageNamed:@"19-check"]];
    }    
    else
    {
        [m_hud setCaption:@"共享失败!"];
        [m_hud setImage:[UIImage imageNamed:@"11-x"]];
    }
	[m_hud setActivity:NO];
    [m_hud update];
    [self performSelectorOnMainThread:@selector(hiddenHub) withObject:nil waitUntilDone:NO];
    
}
- (void)showSuccessInfo:(NSString *)theData infoStr:(NSString *)infoStr
{
    
    NSDictionary *valueDic = [theData JSONValue];
    int code = [[valueDic objectForKey:@"code"]intValue];
    if (code==0)
    {
        [m_hud setCaption:[NSString stringWithFormat:@"%@成功",infoStr]];
        [m_hud setImage:[UIImage imageNamed:@"19-check"]];
        NDAppDelegate *appDelegate =  (NDAppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate clearCopyCache];
        if ([infoStr isEqualToString:@"粘贴"]) {
            [self hiddenPasteButton:YES];
        }
        else if([infoStr isEqualToString:@"删除"])
        {
            self.items = [NSMutableArray arrayWithCapacity:0];
            for (int i=0; i<[m_listArray count]; i++) {
                Item *item = [[Item alloc] init];
                //     item.title = [NSString stringWithFormat:@"%d",i];
                item.isChecked = NO;
                [_items addObject:item];
                [item release];
            }
        }
        [self getMainData];
    }
    else
    {
        [m_hud setCaption:[NSString stringWithFormat:@"%@失败",infoStr]];
        [m_hud setImage:[UIImage imageNamed:@"11-x"]];
    }
    
    [m_hud setActivity:NO];
    [m_hud update];
    [self performSelectorOnMainThread:@selector(hiddenHub) withObject:nil waitUntilDone:NO];
}
- (void)hiddenHub
{
    [m_hud hideAfter:1.2f];
}
@end
