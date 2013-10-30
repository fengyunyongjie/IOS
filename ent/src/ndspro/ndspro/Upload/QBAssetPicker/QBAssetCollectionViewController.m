/*
 Copyright (c) 2013 Katsuma Tanaka
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

/*
    重新编写选择视图
 */

#import "QBAssetCollectionViewController.h"

// Views
#import "QBImagePickerAssetCell.h"
#import "QBImagePickerFooterView.h"
#import "QBImageFileViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CustomViewController.h"
#import "YNFunctions.h"
#import "AppDelegate.h"

#define QBY 20
#define TabBarHeight 88
#define TabBarButtonHeight TabBarHeight-45
#define TableViewHeight (self.view.frame.size.height-TabBarHeight)
#define ChangeTabWidth 90
#define RightButtonBoderWidth 0
#define hilighted_color [UIColor colorWithRed:255.0/255.0 green:180.0/255.0 blue:94.0/255.0 alpha:1.0]
#define BottonViewHeight self.view.frame.size.height-TabBarHeight

@interface QBAssetCollectionViewController ()

@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) NSMutableOrderedSet *selectedAssets;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIBarButtonItem *doneButton;

- (void)reloadData;
- (void)updateRightBarButtonItem;
- (void)updateDoneButton;
- (void)done;
- (void)cancel;

@end

@implementation QBAssetCollectionViewController
@synthesize isNeedBackButton,device_name,f_id,space_id,moreEditBar;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        /* Initialization */
        self.assets = [NSMutableArray array];
        self.selectedAssets = [NSMutableOrderedSet orderedSet];
        
        self.imageSize = CGSizeMake(75, 75);
        
        // Table View
        CGRect rect = CGRectMake(0, 0, 320, TableViewHeight);
        UITableView *tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.allowsSelection = YES;
        tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.view addSubview:tableView];
        self.tableView = tableView;
    }
    
    return self;
}

-(void)viewDidLoad
{
    //添加头部试图
//    topView = [[UIView alloc] initWithFrame:CGRectMake(0, QBY, 320, 44)];
//    UIImageView *images = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
//    [images setImage:[UIImage imageNamed:@"Bk_Title.png"]];
//    [topView addSubview:images];
//    isNeedBackButton = YES;
    //把色值转换成图片
//    CGRect rect_image = CGRectMake(0, 0, ChangeTabWidth, 44);
//    UIGraphicsBeginImageContext(rect_image.size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetFillColorWithColor(context,
//                                   [hilighted_color CGColor]);
//    CGContextFillRect(context, rect_image);
//    UIImage * imge = [[UIImage alloc] init];
//    imge = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    //返回按钮
//    if(isNeedBackButton)
//    {
//        //添加背景
//        UIImage *back_image = [UIImage imageNamed:@"Bt_Back.png"];
//        UIButton *back_button = [[UIButton alloc] initWithFrame:CGRectMake(RightButtonBoderWidth, (44-back_image.size.height/2)/2, back_image.size.width/2, back_image.size.height/2)];
//        [back_button addTarget:self action:@selector(clicked_back) forControlEvents:UIControlEventTouchUpInside];
//        [back_button setBackgroundImage:imge forState:UIControlStateHighlighted];
//        [back_button setImage:back_image forState:UIControlStateNormal];
//        [topView addSubview:back_button];
//    }
    
    
//    //选项卡栏目
//    UIButton *phoot_button = [[UIButton alloc] init];
//    [phoot_button setTag:23];
//    [phoot_button setFrame:CGRectMake((320-ChangeTabWidth)/2, 0, ChangeTabWidth, 44)];
//    [phoot_button setTitle:@"文件上传" forState:UIControlStateNormal];
//    [phoot_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [phoot_button addTarget:self action:@selector(clicked_uploadState:) forControlEvents:UIControlEventTouchDown];
//    [phoot_button setBackgroundImage:imge forState:UIControlStateHighlighted];
//    [topView addSubview:phoot_button];
    
    
//    UIButton*rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0,40,40)];
//    [rightButton setImage:[UIImage imageNamed:@"title_more.png"] forState:UIControlStateNormal];
//    [rightButton setBackgroundImage:[UIImage imageNamed:@"title_bk.png"] forState:UIControlStateHighlighted];
//    [rightButton addTarget:self action:@selector(menuAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //更多按钮
    more_button = [[UIButton alloc] initWithFrame:CGRectMake(320-RightButtonBoderWidth-40, 0, 40, 44)];
    [more_button setTitle:@"全选" forState:UIControlStateNormal];
    [more_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [more_button addTarget:self action:@selector(clicked_more:) forControlEvents:UIControlEventTouchDown];
    [more_button.titleLabel setFont:[UIFont systemFontOfSize:14]];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:more_button];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    //初始化返回按钮
    UIButton*backButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0,35,29)];
    [backButton setImage:[UIImage imageNamed:@"title_back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    if ([YNFunctions systemIsLaterThanString:@"7.0"]) {
        UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
        temporaryBarButtonItem.title = @"";
        self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    }
    else
    {
        self.navigationItem.leftBarButtonItem = backItem;
    }
    
    float mY = self.view.frame.size.height-155;
    if([[[UIDevice currentDevice] systemVersion] floatValue]<7.0)
    {
        mY = mY+20;
    }
    
    //添加底部试图
    self.moreEditBar=[[UIToolbar alloc] initWithFrame:CGRectMake(0,mY, 320, TabBarHeight+10)];
    CGRect bg_rect = CGRectMake(0, 0, 320, TabBarHeight+10);
    UIImageView *bg_image = [[UIImageView alloc] initWithFrame:bg_rect];
    [bg_image setImage:[UIImage imageNamed:@"oper_bk.png"]];
    [self.moreEditBar addSubview:bg_image];
    DDLogCInfo(@"moreEditBar:%@",NSStringFromCGRect(self.moreEditBar.frame));
//    [self.moreEditBar setBackgroundImage:[UIImage imageNamed:@"oper_bk.png"] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.view addSubview:self.moreEditBar];
    
    //添加选择文件
    CGRect change_rect = CGRectMake(2, 5, 316, 35);
    change_myFile_button = [[UIButton alloc] initWithFrame:change_rect];
    [change_myFile_button setBackgroundImage:[UIImage imageNamed:@"Bt_SelectFolder.png"] forState:UIControlStateNormal];
    [change_myFile_button.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [change_myFile_button.titleLabel setLineBreakMode:NSLineBreakByTruncatingMiddle];
    [change_myFile_button setTitle:device_name forState:UIControlStateNormal];
    [change_myFile_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [change_myFile_button addTarget:self action:@selector(clicked_MyFile:) forControlEvents:UIControlEventTouchUpInside];
    [self.moreEditBar addSubview:change_myFile_button];
    
    UIButton *btn_download ,*btn_resave;
    float boderWidth = (320-134*2)/3;
    btn_resave =[[UIButton alloc] initWithFrame:CGRectMake(boderWidth, 45+(TabBarButtonHeight-35)/2, 134, 35)];
    [btn_resave setBackgroundImage:[UIImage imageNamed:@"oper_bt_nor.png"] forState:UIControlStateNormal];
    [btn_resave setBackgroundImage:[UIImage imageNamed:@"oper_bt_se.png"] forState:UIControlStateHighlighted];
    [btn_resave setTitle:@"上传" forState:UIControlStateNormal];
    [btn_resave addTarget:self action:@selector(clicked_startUpload:) forControlEvents:UIControlEventTouchUpInside];
    [self.moreEditBar addSubview:btn_resave];
    
    btn_download =[[UIButton alloc] initWithFrame:CGRectMake(boderWidth*2+134, 45+(TabBarButtonHeight-35)/2, 134, 35)];
    [btn_download setBackgroundImage:[UIImage imageNamed:@"oper_bt_nor.png"] forState:UIControlStateNormal];
    [btn_download setBackgroundImage:[UIImage imageNamed:@"oper_bt_se.png"] forState:UIControlStateHighlighted];
    [btn_download setTitle:@"取消" forState:UIControlStateNormal];
    [btn_download addTarget:self action:@selector(clicked_uploadStop:) forControlEvents:UIControlEventTouchUpInside];
    [self.moreEditBar addSubview:btn_download];
}

-(void)networkError{}
-(void)authorMenusSuccess:(NSData*)data{}
-(void)searchSucess:(NSDictionary *)datadic{}
-(void)operateSucess:(NSDictionary *)datadic{}
-(void)openFinderSucess:(NSDictionary *)datadic{}
//打开家庭成员
-(void)getOpenFamily:(NSDictionary *)dictionary{}
//打开文件个人信息
-(void)getFileEntInfo:(NSDictionary *)dictionary
{
    DDLogCInfo(@"dictionary:%@",dictionary);
    NSString *names = [dictionary objectForKey:@"fpnames"];
    if([names length]>0 && ![names isEqualToString:@"<null>"])
    {
        NSString *fname = [dictionary objectForKey:@"fname"];
        if([fname length]>0)
        {
            AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            NSMutableString *file_url = [[NSMutableString alloc] init];
            [file_url appendString:appDelegate.file_url];
            [file_url appendString:names];
            [file_url appendString:fname];
            [change_myFile_button setTitle:file_url forState:UIControlStateNormal];
        }
    }
}
-(void)openFinderUnsucess{}
-(void)removeSucess{}
-(void)removeUnsucess{}
-(void)renameSucess{}
-(void)renameUnsucess{}
-(void)moveSucess{}
-(void)moveUnsucess{}
-(void)newFinderSucess{}
-(void)newFinderUnsucess{}

-(void)viewDidAppear:(BOOL)animated
{
    CGRect rect = CGRectMake(0, 0, 320, TableViewHeight);
//    if([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0)
//    {
//        rect.size.height = rect.size.height +44;
//    }
    [self.tableView setFrame:rect];
    
//    CGRect more_rect = self.moreEditBar.frame;
//    more_rect.origin.y = self.view.frame.size.height-TabBarHeight;
//    [self.moreEditBar setFrame:more_rect];
//    //添加底部视图
//    float bottonHeigth = BottonViewHeight;
//    bottonView = [[UIView alloc] initWithFrame:CGRectMake(0, bottonHeigth, 320, TabBarHeight)];
//    UIImageView *botton_image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, bottonView.frame.size.width, bottonView.frame.size.height)];
//    [botton_image setImage:[UIImage imageNamed:@"bk_nabottom.png"]];
//    [bottonView addSubview:botton_image];
//    
//    //添加选择文件
//    CGRect change_rect = CGRectMake(2, 5, 316, 35);
//    change_myFile_button = [[UIButton alloc] initWithFrame:change_rect];
//    [change_myFile_button setBackgroundImage:[UIImage imageNamed:@"Bt_SelectFolder.png"] forState:UIControlStateNormal];
//    [change_myFile_button.titleLabel setTextAlignment:NSTextAlignmentLeft];
//    [change_myFile_button setTitle:device_name forState:UIControlStateNormal];
//    [change_myFile_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [change_myFile_button addTarget:self action:@selector(clicked_changeMyFile:) forControlEvents:UIControlEventTouchUpInside];
//    [bottonView addSubview:change_myFile_button];
//    
//    //添加选定按钮
//    UIButton *upload_button = [[UIButton alloc] initWithFrame:CGRectMake((320/2-29)/2, 45+(TabBarButtonHeight-29)/2, 29, 29)];
//    [upload_button setBackgroundImage:[UIImage imageNamed:@"Bt_UploadOk.png"] forState:UIControlStateNormal];
//    [upload_button setBackgroundImage:[UIImage imageNamed:@"Bt_UploadOkCh.png"] forState:UIControlStateHighlighted];
//    [upload_button addTarget:self action:@selector(clicked_startUpload:) forControlEvents:UIControlEventTouchUpInside];
//    [bottonView addSubview:upload_button];
//    
//    UIButton *upload_back_button = [[UIButton alloc] initWithFrame:CGRectMake(320/2+(320/2-29)/2, 45+(TabBarButtonHeight-29)/2, 29, 29)];
//    [upload_back_button setBackgroundImage:[UIImage imageNamed:@"Bt_UploadCancle.png"] forState:UIControlStateNormal];
//    [upload_back_button setBackgroundImage:[UIImage imageNamed:@"Bt_UploadCancleCh.png"] forState:UIControlStateHighlighted];
//    [upload_back_button addTarget:self action:@selector(clicked_uploadStop:) forControlEvents:UIControlEventTouchUpInside];
//    [bottonView addSubview:upload_back_button];
//    
//    [self.view addSubview:bottonView];
}


-(void)clicked_back
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)clicked_uploadState:(id)sender
{
    
}

-(void)clicked_more:(id)sender
{
    if (self.selectedAssets.count == self.assets.count) {
        // Deselect all assets
        [self.selectedAssets removeAllObjects];
        [more_button setTitle:@"全选" forState:UIControlStateNormal];
    } else {
        // Select all assets
        [self.selectedAssets addObjectsFromArray:self.assets];
        [more_button setTitle:@"取消" forState:UIControlStateNormal];
    }
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:more_button];
    self.navigationItem.rightBarButtonItem = rightItem;
    // Set done button state
    [self updateDoneButton];
    
    // Update assets
//    if (self.showsFooterDescription) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
//    }
    
    // Update header text
//    if (self.showsHeaderButton) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
//    }
    
    // Cancel table view selection
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES];
}

-(void)clicked_MyFile:(id)sender
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    QBImageFileViewController *qbImage_fileView = [[QBImageFileViewController alloc] init];
    qbImage_fileView.f_id = @"0";
    qbImage_fileView.f_name = appDelegate.file_url;
    qbImage_fileView.title = appDelegate.file_url;
    qbImage_fileView.space_id = space_id;
    [qbImage_fileView setQbDelegate:self];
    [self.navigationController pushViewController:qbImage_fileView animated:YES];
//    CustomViewController *nagation = [[CustomViewController alloc] initWithRootViewController:qbImage_fileView];
//    [nagation setNavigationBarHidden:YES];
//    [self presentModalViewController:nagation animated:YES];
}

-(void)clicked_startUpload:(id)sender
{
    [self.delegate changeUpload:self.selectedAssets changeDeviceName:device_name changeFileId:self.f_id changeSpaceId:space_id];
    
    if([self.navigationController.viewControllers count]>3)
    {
        UIViewController *delailview = [self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-3];
        if(delailview)
        {
            [self.navigationController popToViewController:delailview animated:YES];
        }
    }
    else
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

-(void)newFold:(NSDictionary *)dictionary
{
    
}

-(void)openFile:(NSDictionary *)dictionary
{
    NSLog(@"dictionary:%@",dictionary);
    fileArray = [dictionary objectForKey:@"files"];
}

-(void)clicked_uploadStop:(id)sender
{
    if([self.navigationController.viewControllers count]>3)
    {
        UIViewController *delailview = [self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-3];
        if(delailview)
        {
            [self.navigationController popToViewController:delailview animated:YES];
        }
    }
    else
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

-(void)uploadFileder:(NSString *)deviceName
{
    device_name = deviceName;
}

-(void)uploadFiledId:(NSString *)f_id_
{
    self.f_id = f_id_;
}

- (void)viewWillAppear:(BOOL)animated
{
    //请求文件路径信息
    SCBFileManager *fileManger = [[SCBFileManager alloc] init];
    [fileManger setDelegate:self];
    [fileManger requestEntFileInfo:self.f_id];
    if([device_name length]>0)
    {
        [change_myFile_button setTitle:device_name forState:UIControlStateNormal];
    }
    [super viewWillAppear:animated];
    if(!isFirst)
    {
        isFirst = TRUE;
        // Reload
        [self reloadData];
        
        if (self.fullScreenLayoutEnabled) {
            // Set bar styles
            //        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
            //        self.navigationController.navigationBar.translucent = YES;
            //        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:NO];
            //        CGFloat top = 0;
            //        if (![[UIApplication sharedApplication] isStatusBarHidden]) top = top + 20;
            //        if (!self.navigationController.navigationBarHidden) top = top + 44;
            //        self.tableView.contentInset = UIEdgeInsetsMake(top, 0, 0, 0);
            //        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(top, 0, 0, 0);
            [self setWantsFullScreenLayout:YES];
        }
        [self.view bringSubviewToFront:change_myFile_button];
        // Scroll to bottom
        NSInteger numberOfRows = [self.tableView numberOfRowsInSection:2];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(numberOfRows - 1) inSection:2];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}


- (void)setShowsCancelButton:(BOOL)showsCancelButton
{
    _showsCancelButton = showsCancelButton;
    
    [self updateRightBarButtonItem];
}

- (void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection
{
    _allowsMultipleSelection = allowsMultipleSelection;
    
    [self updateRightBarButtonItem];
}


#pragma mark - Instance Methods

- (void)reloadData
{
    // Reload assets
    [self.assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            [self.assets addObject:result];
        }
    }];
    
    [self.tableView reloadData];
    
    // Set footer view
    if (self.showsFooterDescription) {
        [self.assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
        NSUInteger numberOfPhotos = self.assetsGroup.numberOfAssets;
        
        [self.assetsGroup setAssetsFilter:[ALAssetsFilter allVideos]];
        NSUInteger numberOfVideos = self.assetsGroup.numberOfAssets;
        
        switch(self.filterType) {
            case QBImagePickerFilterTypeAllAssets:
                [self.assetsGroup setAssetsFilter:[ALAssetsFilter allAssets]];
                break;
            case QBImagePickerFilterTypeAllPhotos:
                [self.assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
                break;
            case QBImagePickerFilterTypeAllVideos:
                [self.assetsGroup setAssetsFilter:[ALAssetsFilter allVideos]];
                break;
        }
        
        QBImagePickerFooterView *footerView = [[QBImagePickerFooterView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 48)];
        
        if (self.filterType == QBImagePickerFilterTypeAllAssets) {
            footerView.titleLabel.text = [self.delegate assetCollectionViewController:self descriptionForNumberOfPhotos:numberOfPhotos numberOfVideos:numberOfVideos];
        } else if (self.filterType == QBImagePickerFilterTypeAllPhotos) {
            footerView.titleLabel.text = [self.delegate assetCollectionViewController:self descriptionForNumberOfPhotos:numberOfPhotos];
        } else if (self.filterType == QBImagePickerFilterTypeAllVideos) {
            footerView.titleLabel.text = [self.delegate assetCollectionViewController:self descriptionForNumberOfVideos:numberOfVideos];
        }
        
//        self.tableView.tableFooterView = footerView;
    } else {
        QBImagePickerFooterView *footerView = [[QBImagePickerFooterView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 4)];
        
//        self.tableView.tableFooterView = footerView;
    }
}

- (void)updateRightBarButtonItem
{
//    if (self.allowsMultipleSelection) {
//        // Set done button
//        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
//        doneButton.enabled = NO;
//        
//        [self.navigationItem setRightBarButtonItem:doneButton animated:NO];
//        self.doneButton = doneButton;
//    } else if (self.showsCancelButton) {
//        // Set cancel button
//        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
//        
//        [self.navigationItem setRightBarButtonItem:cancelButton animated:NO];
//    } else {
//        [self.navigationItem setRightBarButtonItem:nil animated:NO];
//    }
}

- (void)updateDoneButton
{
    if (self.limitsMinimumNumberOfSelection) {
        self.doneButton.enabled = (self.selectedAssets.count >= self.minimumNumberOfSelection);
    } else {
        self.doneButton.enabled = (self.selectedAssets.count > 0);
    }
}

- (void)done
{
    [self.delegate assetCollectionViewController:self didFinishPickingAssets:self.selectedAssets.array];
}

- (void)cancel
{
    [self.delegate assetCollectionViewControllerDidCancel:self];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRowsInSection = 0;
    
    switch(section) {
        case 0: case 1:
        {
            if (self.allowsMultipleSelection && !self.limitsMaximumNumberOfSelection && self.showsHeaderButton) {
                numberOfRowsInSection = 1;
            }
        }
            break;
        case 2:
        {
            NSInteger numberOfAssetsInRow = self.view.bounds.size.width / self.imageSize.width;
            numberOfRowsInSection = self.assets.count / numberOfAssetsInRow;
            if ((self.assets.count - numberOfRowsInSection * numberOfAssetsInRow) > 0) numberOfRowsInSection++;
        }
            break;
    }
    
    return numberOfRowsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    switch(indexPath.section) {
        case 0:
        {
            NSString *cellIdentifier = @"HeaderCell";
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            }
            
            if (self.selectedAssets.count == self.assets.count) {
                cell.textLabel.text = [self.delegate descriptionForDeselectingAllAssets:self];
                
                // Set accessory view
                UIImageView *accessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 23, 23)];
                accessoryView.image = [UIImage imageNamed:@"minus.png"];
                
                accessoryView.layer.shadowColor = [[UIColor colorWithWhite:0 alpha:1.0] CGColor];
                accessoryView.layer.shadowOpacity = 0.70;
                accessoryView.layer.shadowOffset = CGSizeMake(0, 1.4);
                accessoryView.layer.shadowRadius = 2;
                
                cell.accessoryView = accessoryView;
            } else {
                cell.textLabel.text = [self.delegate descriptionForSelectingAllAssets:self];
                
                // Set accessory view
                UIImageView *accessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 23, 23)];
                accessoryView.image = [UIImage imageNamed:@"plus.png"];
                
                accessoryView.layer.shadowColor = [[UIColor colorWithWhite:0 alpha:1.0] CGColor];
                accessoryView.layer.shadowOpacity = 0.70;
                accessoryView.layer.shadowOffset = CGSizeMake(0, 1.4);
                accessoryView.layer.shadowRadius = 2;
                
                cell.accessoryView = accessoryView;
            }
        }
            break;
        case 1:
        {
            NSString *cellIdentifier = @"SeparatorCell";
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                // Set background view
                UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
                backgroundView.backgroundColor = [UIColor colorWithWhite:0.878 alpha:1.0];
                
                cell.backgroundView = backgroundView;
            }
        }
            break;
        case 2:
        {
            NSString *cellIdentifier = @"AssetCell";
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if (cell == nil) {
                NSInteger numberOfAssetsInRow = self.view.bounds.size.width / self.imageSize.width;
                CGFloat margin = round((self.view.bounds.size.width - self.imageSize.width * numberOfAssetsInRow) / (numberOfAssetsInRow + 1));
                
                cell = [[QBImagePickerAssetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier imageSize:self.imageSize numberOfAssets:numberOfAssetsInRow margin:margin];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [(QBImagePickerAssetCell *)cell setDelegate:self];
                [(QBImagePickerAssetCell *)cell setAllowsMultipleSelection:self.allowsMultipleSelection];
            }
            
            // Set assets
            NSInteger numberOfAssetsInRow = self.view.bounds.size.width / self.imageSize.width;
            NSInteger offset = numberOfAssetsInRow * indexPath.row;
            NSInteger numberOfAssetsToSet = (offset + numberOfAssetsInRow > self.assets.count) ? (self.assets.count - offset) : numberOfAssetsInRow;
            
            NSMutableArray *assets = [NSMutableArray array];
            for (NSUInteger i = 0; i < numberOfAssetsToSet; i++) {
                ALAsset *asset = [self.assets objectAtIndex:(offset + i)];
                
                [assets addObject:asset];
            }
            
            [(QBImagePickerAssetCell *)cell setAssets:assets];
            
            // Set selection states
            for (NSUInteger i = 0; i < numberOfAssetsToSet; i++) {
                ALAsset *asset = [self.assets objectAtIndex:(offset + i)];
                
                if ([self.selectedAssets containsObject:asset]) {
                    [(QBImagePickerAssetCell *)cell selectAssetAtIndex:i];
                } else {
                    [(QBImagePickerAssetCell *)cell deselectAssetAtIndex:i];
                }
            }
        }
            break;
    }
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat heightForRow = 0;
    
    switch(indexPath.section) {
        case 0:
        {
            heightForRow = 44;
        }
            break;
        case 1:
        {
            heightForRow = 1;
        }
            break;
        case 2:
        {
            NSInteger numberOfAssetsInRow = self.view.bounds.size.width / self.imageSize.width;
            CGFloat margin = round((self.view.bounds.size.width - self.imageSize.width * numberOfAssetsInRow) / (numberOfAssetsInRow + 1));
            heightForRow = margin + self.imageSize.height;
            if(([indexPath row]+1)*numberOfAssetsInRow >= self.assets.count)
            {
                heightForRow += 3;
            }
        }
            break;
    }
    
    return heightForRow;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        if (self.selectedAssets.count == self.assets.count) {
            // Deselect all assets
            [self.selectedAssets removeAllObjects];
        } else {
            // Select all assets
            [self.selectedAssets addObjectsFromArray:self.assets];
        }
        
        // Set done button state
        [self updateDoneButton];
        
        // Update assets
        if (self.showsFooterDescription) {
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
        }
        
        // Update header text
        if (self.showsHeaderButton) {
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        }
        
        // Cancel table view selection
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}


#pragma mark - QBImagePickerAssetCellDelegate

- (BOOL)assetCell:(QBImagePickerAssetCell *)assetCell canSelectAssetAtIndex:(NSUInteger)index
{
    BOOL canSelect = YES;
    
    if (self.allowsMultipleSelection && self.limitsMaximumNumberOfSelection) {
        canSelect = (self.selectedAssets.count < self.maximumNumberOfSelection);
    }
    
    return canSelect;
}

- (void)assetCell:(QBImagePickerAssetCell *)assetCell didChangeAssetSelectionState:(BOOL)selected atIndex:(NSUInteger)index
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:assetCell];
    
    NSInteger numberOfAssetsInRow = self.view.bounds.size.width / self.imageSize.width;
    NSInteger assetIndex = indexPath.row * numberOfAssetsInRow + index;
    ALAsset *asset = [self.assets objectAtIndex:assetIndex];
    NSLog(@"image:%@",asset.defaultRepresentation.filename);
    if (self.allowsMultipleSelection) {
        if (selected) {
            [self.selectedAssets addObject:asset];
        } else {
            [self.selectedAssets removeObject:asset];
        }
        
        // Set done button state
        [self updateDoneButton];
        
        // Update header text
        if (self.showsHeaderButton) {
            if ((selected && self.selectedAssets.count == self.assets.count) ||
               (!selected && self.selectedAssets.count == self.assets.count - 1)) {
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
    } else {
        [self.delegate assetCollectionViewController:self didFinishPickingAsset:asset];
    }
}

@end
