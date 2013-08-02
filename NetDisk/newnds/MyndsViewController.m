//
//  MyndsViewController.m
//  NetDisk
//
//  Created by fengyongning on 13-4-28.
//
//

#import "MyndsViewController.h"
#import "SCBFileManager.h"
#import "SCBShareManager.h"
#import "SCBSession.h"
#import "FileItemTableCell.h"
#import "YNFunctions.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "FavoritesData.h"
#import "PhotoFile.h"
#import "PhotoLookViewController.h"
#import "IconDownloader.h"
#import "ImageBrowserViewController.h"
#import "OtherBrowserViewController.h"
#import "SCBLinkManager.h"
#import <MessageUI/MessageUI.h>

#define TabBarHeight 60
#define ChangeTabWidth 90
#define RightButtonBoderWidth 0
typedef enum{
    kAlertTagDeleteOne,
    kAlertTagDeleteMore,
    kAlertTagRename,
    kAlertTagNewFinder,
}AlertTag;
typedef enum{
    kActionSheetTagShare,
    kActionSheetTagMore,
}ActionSheetTag;
@implementation FileItem

+ (FileItem*) fileItem
{
	return [[[self alloc] init] autorelease];
}

- (void) dealloc
{
	[super dealloc];
}
@end

@interface MyndsViewController ()
@property (strong,nonatomic) SCBFileManager *fm;
@property (strong,nonatomic) SCBShareManager *sm;
@property (strong,nonatomic) SCBFileManager *fm_move;
@property (strong,nonatomic) NSIndexPath *selectedIndexPath;
@property (strong,nonatomic) UITableViewCell *optionCell;
@property (strong,nonatomic) UIBarButtonItem *editBtn;
@property (strong,nonatomic) UIBarButtonItem *deleteBtn;
@property (assign,nonatomic) BOOL isEditing;
@property (strong,nonatomic) NSMutableArray *m_fileItems;
@property(strong,nonatomic) MBProgressHUD *hud;
@property (strong,nonatomic) NSArray *willDeleteObjects;
@end

@implementation MyndsViewController

- (id)init
{
    self = [super init];
    if (self) {
        
        [self.view setBackgroundColor:[UIColor whiteColor]];
        //顶视图
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
        //返回按钮
        if(1)
        {
            UIImage *back_image = [UIImage imageNamed:@"Bt_Back.png"];
            UIButton *back_button = [[UIButton alloc] initWithFrame:CGRectMake(RightButtonBoderWidth, (44-back_image.size.height/2)/2, back_image.size.width/2, back_image.size.height/2)];
            [back_button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
            [back_button setBackgroundImage:imge forState:UIControlStateHighlighted];
            [back_button setImage:back_image forState:UIControlStateNormal];
            [nbar addSubview:back_button];
            [back_button release];
        }
        //更多按钮
        UIButton *more_button = [[UIButton alloc] init];
        UIImage *moreImage = [UIImage imageNamed:@"Bt_More.png"];
        [more_button setFrame:CGRectMake(320-RightButtonBoderWidth-moreImage.size.width/2, (44-moreImage.size.height/2)/2, moreImage.size.width/2, moreImage.size.height/2)];
        [more_button setImage:moreImage forState:UIControlStateNormal];
        [more_button setBackgroundImage:imge forState:UIControlStateHighlighted];
        [more_button addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
        [nbar addSubview:more_button];
        [more_button release];
        
        //表视图
        self.tableView=[[UITableView alloc] init];
        self.tableView.allowsSelectionDuringEditing=YES;
        self.tableView.delegate=self;
        self.tableView.dataSource=self;
        [self.view addSubview:self.tableView];
        CGRect r=self.view.frame;
        r.origin.y=44;
        self.tableView.frame=r;
        r=self.tableView.frame;
        self.tableView.frame=r;
        self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
        
//        //操作菜单
//        self.ctrlView=[[UIControl alloc] init];
//        r=self.view.frame;
//        //r.size.height=120;
//        //r.origin.x=140;
//        [self.ctrlView setFrame:r];
//        [self.ctrlView addTarget:self action:@selector(touchView:) forControlEvents:UIControlEventTouchUpInside];
//        self.ctrlView.backgroundColor=[UIColor colorWithWhite:0 alpha:0];
//        [self.view addSubview:self.ctrlView];
//        [self.ctrlView setHidden:YES];
//        UIImageView *bg=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Bg_Buttons.png"]];
//        r=CGRectMake(0+140, 0, 176, 112);
//        [bg setFrame:r];
//        [self.ctrlView addSubview:bg];
//        
//        //按钮－新建文件夹
//        UIButton *btnNewFinder= [UIButton buttonWithType:UIButtonTypeCustom];
//        btnNewFinder.frame=CGRectMake(38+140, 30, 34, 34);
//        [btnNewFinder setImage:[UIImage imageNamed:@"Bt_NewFolder.png"] forState:UIControlStateNormal];
//        [btnNewFinder addTarget:self action:@selector(newFinder:) forControlEvents:UIControlEventTouchUpInside];
//        [self.ctrlView addSubview:btnNewFinder];
//        
//        UILabel *lblNewFinder=[[UILabel alloc] init];
//        lblNewFinder.text=@"新建文件夹";
//        lblNewFinder.font=[UIFont systemFontOfSize:12];
//        lblNewFinder.backgroundColor=[UIColor colorWithWhite:0 alpha:0];
//        lblNewFinder.textColor=[UIColor whiteColor];
//        lblNewFinder.frame=CGRectMake(23+140, 72, 64, 20);
//        [self.ctrlView addSubview:lblNewFinder];
//        
//        //按钮－编辑
//        UIButton *btnEdit= [UIButton buttonWithType:UIButtonTypeCustom];
//        btnEdit.frame=CGRectMake(116+140, 30, 34, 34);
//        [btnEdit setImage:[UIImage imageNamed:@"Bt_Edit.png"] forState:UIControlStateNormal];
//        [btnEdit addTarget:self action:@selector(editAction:) forControlEvents:UIControlEventTouchUpInside];
//        [self.ctrlView addSubview:btnEdit];
//        
//        self.lblEdit=[[UILabel alloc] init];
//        self.lblEdit.text=@"编辑";
//        self.lblEdit.font=[UIFont systemFontOfSize:12];
//        self.lblEdit.backgroundColor=[UIColor colorWithWhite:0 alpha:0];
//        self.lblEdit.textColor=[UIColor whiteColor];
//        self.lblEdit.frame=CGRectMake(119+140, 72, 29, 21);
//        [self.ctrlView addSubview:self.lblEdit];
        
        //操作菜单
        self.ctrlView=[[UIControl alloc] init];
        self.ctrlView.frame=self.view.frame;
        [self.ctrlView addTarget:self action:@selector(touchView:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.ctrlView];
        [self.ctrlView setHidden:YES];
        UIImageView *bg=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Bk_na.png"]];
        bg.frame=CGRectMake(25, 44, 270, 175);
        [self.ctrlView addSubview:bg];
        
        //按钮－新建文件夹0,0
        UIButton *btnNewFinder= [UIButton buttonWithType:UIButtonTypeCustom];
        btnNewFinder.frame=CGRectMake(25, 44, 90, 87);
        [btnNewFinder setImage:[UIImage imageNamed:@"Bt_naUpload.png"] forState:UIControlStateNormal];
        [btnNewFinder setBackgroundImage:[UIImage imageNamed:@"Bk_naChecked.png"] forState:UIControlStateHighlighted];
        [btnNewFinder addTarget:self action:@selector(goUpload:) forControlEvents:UIControlEventTouchUpInside];
        [self.ctrlView addSubview:btnNewFinder];
        UILabel *lblNewFinder=[[[UILabel alloc] init] autorelease];
        lblNewFinder.text=@"上传";
        lblNewFinder.textAlignment=UITextAlignmentCenter;
        lblNewFinder.font=[UIFont systemFontOfSize:12];
        lblNewFinder.textColor=[UIColor whiteColor];
        lblNewFinder.backgroundColor=[UIColor clearColor];
        lblNewFinder.frame=CGRectMake(25, 59+44, 90, 21);
        [self.ctrlView addSubview:lblNewFinder];
        
        //按钮－编辑0,1
        UIButton *btnEdit= [UIButton buttonWithType:UIButtonTypeCustom];
        btnEdit.frame=CGRectMake(25+90, 44, 90, 87);
        [btnEdit setImage:[UIImage imageNamed:@"Bt_naSeach.png"] forState:UIControlStateNormal];
        [btnEdit setBackgroundImage:[UIImage imageNamed:@"Bk_naChecked.png"] forState:UIControlStateHighlighted];
        [btnEdit addTarget:self action:@selector(goSearch:) forControlEvents:UIControlEventTouchUpInside];
        [self.ctrlView addSubview:btnEdit];
        UILabel *lblNewFinder01=[[[UILabel alloc] init] autorelease];
        lblNewFinder01.text=@"搜索";
        lblNewFinder01.textAlignment=UITextAlignmentCenter;
        lblNewFinder01.font=[UIFont systemFontOfSize:12];
        lblNewFinder01.textColor=[UIColor whiteColor];
        lblNewFinder01.backgroundColor=[UIColor clearColor];
        lblNewFinder01.frame=CGRectMake(25+90, 59+44, 90, 21);
        [self.ctrlView addSubview:lblNewFinder01];
        
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
        
        //按钮－新建文件夹 1，0
        UIButton *btnNewFinder10= [UIButton buttonWithType:UIButtonTypeCustom];
        btnNewFinder10.frame=CGRectMake(25, 44+88, 90, 87);
        [btnNewFinder10 setImage:[UIImage imageNamed:@"Bt_naEdit.png"] forState:UIControlStateNormal];
        [btnNewFinder10 setBackgroundImage:[UIImage imageNamed:@"Bk_naChecked.png"] forState:UIControlStateHighlighted];
        [btnNewFinder10 addTarget:self action:@selector(editAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.ctrlView addSubview:btnNewFinder10];
        self.lblEdit=[[[UILabel alloc] init] autorelease];
        self.lblEdit.text=@"编辑";
        self.lblEdit.textAlignment=UITextAlignmentCenter;
        self.lblEdit.font=[UIFont systemFontOfSize:12];
        self.lblEdit.textColor=[UIColor whiteColor];
        self.lblEdit.backgroundColor=[UIColor clearColor];
        self.lblEdit.frame=CGRectMake(25, 59+88+44, 90, 21);
        [self.ctrlView addSubview:self.lblEdit];
        
        //按钮－新建文件夹 1，1
        UIButton *btnNewFinder11= [UIButton buttonWithType:UIButtonTypeCustom];
        btnNewFinder11.frame=CGRectMake(25+90, 44+88, 90, 87);
        [btnNewFinder11 setImage:[UIImage imageNamed:@"Bt_naCreateForlder.png"] forState:UIControlStateNormal];
        [btnNewFinder11 setBackgroundImage:[UIImage imageNamed:@"Bk_naChecked.png"] forState:UIControlStateHighlighted];
        [btnNewFinder11 addTarget:self action:@selector(newFinder:) forControlEvents:UIControlEventTouchUpInside];
        [self.ctrlView addSubview:btnNewFinder11];
        UILabel *lblNewFinder11=[[[UILabel alloc] init] autorelease];
        lblNewFinder11.text=@"新建文件夹";
        lblNewFinder11.textAlignment=UITextAlignmentCenter;
        lblNewFinder11.font=[UIFont systemFontOfSize:12];
        lblNewFinder11.textColor=[UIColor whiteColor];
        lblNewFinder11.backgroundColor=[UIColor clearColor];
        lblNewFinder11.frame=CGRectMake(25+90, 59+88+44, 90, 21);
        [self.ctrlView addSubview:lblNewFinder11];
        
//        //按钮－新建文件夹 1，2
//        UIButton *btnNewFinder12= [UIButton buttonWithType:UIButtonTypeCustom];
//        btnNewFinder12.frame=CGRectMake(25+(90*2), 44+88, 90, 87);
//        [btnNewFinder12 setImage:[UIImage imageNamed:@"Bt_DownloadF.png"] forState:UIControlStateNormal];
//        [btnNewFinder12 setBackgroundImage:[UIImage imageNamed:@"Bk_naChecked.png"] forState:UIControlStateHighlighted];
//        [btnNewFinder12 addTarget:self action:@selector(newFinder:) forControlEvents:UIControlEventTouchUpInside];
//        [self.ctrlView addSubview:btnNewFinder12];
//        UILabel *lblNewFinde12r=[[[UILabel alloc] init] autorelease];
//        lblNewFinde12r.text=@"新建文件夹";
//        lblNewFinde12r.textAlignment=UITextAlignmentCenter;
//        lblNewFinde12r.font=[UIFont systemFontOfSize:12];
//        lblNewFinde12r.textColor=[UIColor whiteColor];
//        lblNewFinde12r.backgroundColor=[UIColor clearColor];
//        lblNewFinde12r.frame=CGRectMake(25+(90*2), 59+88+44, 90, 21);
//        [self.ctrlView addSubview:lblNewFinde12r];
        
        
        //表格操作菜单
        self.cellMenu=[[UIView alloc] init];
        //self.cellMenu.backgroundColor=[UIColor blackColor];
        self.cellMenu.frame=CGRectMake(0, 70, 320, 65);
        UIImageView *imageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Bk_OptionBar.png" ]];
        imageView.frame=CGRectMake(0, 0, 320, 65);
        [self.cellMenu addSubview:imageView];
        [self.cellMenu setHidden:YES];
        [self.tableView addSubview:self.cellMenu];
        [self.tableView bringSubviewToFront:self.cellMenu];
        
        //移动按钮
        UIButton *btnMove=[UIButton buttonWithType:UIButtonTypeCustom];
        btnMove.frame=CGRectMake(10, 8, 60, 60);
        [btnMove setImage:[UIImage imageNamed:@"Bt_MoveF.png"] forState:UIControlStateNormal];
        [btnMove addTarget:self action:@selector(toMove:) forControlEvents:UIControlEventTouchUpInside];
        [self.cellMenu addSubview:btnMove];
        UILabel *lblMove=[[[UILabel alloc] init] autorelease];
        lblMove.text=@"移动";
        lblMove.textAlignment=UITextAlignmentCenter;
        lblMove.font=[UIFont systemFontOfSize:12];
        lblMove.textColor=[UIColor whiteColor];
        lblMove.backgroundColor=[UIColor clearColor];
        lblMove.frame=CGRectMake(19, 45, 42, 21);
        [self.cellMenu addSubview:lblMove];
        //重命名按钮
        self.btnRename=[UIButton buttonWithType:UIButtonTypeCustom];
        self.btnRename.frame=CGRectMake(90, 8, 60, 60);
        [self.btnRename setImage:[UIImage imageNamed:@"Bt_RenameF.png"] forState:UIControlStateNormal];
        [self.btnRename addTarget:self action:@selector(toRename:) forControlEvents:UIControlEventTouchUpInside];
        [self.cellMenu addSubview:self.btnRename];
        self.lblRename=[[[UILabel alloc] init] autorelease];
        self.lblRename.text=@"命命名";
        self.lblRename.textAlignment=UITextAlignmentCenter;
        self.lblRename.font=[UIFont systemFontOfSize:12];
        self.lblRename.textColor=[UIColor whiteColor];
        self.lblRename.backgroundColor=[UIColor clearColor];
        self.lblRename.frame=CGRectMake(99, 45, 42, 21);
        [self.cellMenu addSubview:self.lblRename];
        //下载按钮
        self.btnDownload=[UIButton buttonWithType:UIButtonTypeCustom];
        self.btnDownload.frame=CGRectMake(170, 8, 60, 60);
        [self.btnDownload setImage:[UIImage imageNamed:@"Bt_DownloadF.png"] forState:UIControlStateNormal];
        [self.btnDownload addTarget:self action:@selector(toFavorite:) forControlEvents:UIControlEventTouchUpInside];
        [self.cellMenu addSubview:self.btnDownload];
        self.lblDownload=[[[UILabel alloc] init] autorelease];
        self.lblDownload.text=@"下载";
        self.lblDownload.textAlignment=UITextAlignmentCenter;
        self.lblDownload.font=[UIFont systemFontOfSize:12];
        self.lblDownload.textColor=[UIColor whiteColor];
        self.lblDownload.backgroundColor=[UIColor clearColor];
        self.lblDownload.frame=CGRectMake(179, 45, 42, 21);
        [self.cellMenu addSubview:self.lblDownload];
        //删除按钮
        self.btnDel=[UIButton buttonWithType:UIButtonTypeCustom];
        self.btnDel.frame=CGRectMake(250, 8, 60, 60);
        [self.btnDel setImage:[UIImage imageNamed:@"Bt_DelF.png"] forState:UIControlStateNormal];
        [self.btnDel addTarget:self action:@selector(toDelete:) forControlEvents:UIControlEventTouchUpInside];
        [self.cellMenu addSubview:self.btnDel];
        self.lblDel=[[[UILabel alloc] init] autorelease];
        self.lblDel.text=@"删除";
        self.lblDel.textAlignment=UITextAlignmentCenter;
        self.lblDel.font=[UIFont systemFontOfSize:12];
        self.lblDel.textColor=[UIColor whiteColor];
        self.lblDel.backgroundColor=[UIColor clearColor];
        self.lblDel.frame=CGRectMake(259, 45, 42, 21);
        [self.cellMenu addSubview:self.lblDel];
        self.btnDel.hidden=YES;
        self.lblDel.hidden=YES;
        //更多按钮
        self.btnMore=[UIButton buttonWithType:UIButtonTypeCustom];
        self.btnMore.frame=CGRectMake(250, 8, 60, 60);
        [self.btnMore setImage:[UIImage imageNamed:@"Bt_MoreF.png"] forState:UIControlStateNormal];
        [self.btnMore addTarget:self action:@selector(toMore:) forControlEvents:UIControlEventTouchUpInside];
        [self.cellMenu addSubview:self.btnMore];
        self.lblMore=[[[UILabel alloc] init] autorelease];
        self.lblMore.text=@"更多";
        self.lblMore.textAlignment=UITextAlignmentCenter;
        self.lblMore.font=[UIFont systemFontOfSize:12];
        self.lblMore.textColor=[UIColor whiteColor];
        self.lblMore.backgroundColor=[UIColor clearColor];
        self.lblMore.frame=CGRectMake(259, 45, 42, 21);
        [self.cellMenu addSubview:self.lblMore];
        
        
        //新建文件夹视图
        self.newFinderView=[[[UIView alloc] init] autorelease];
        self.newFinderView.frame=self.view.frame;
        [self.view addSubview:self.newFinderView];
        [self.newFinderView setHidden:YES];
        UIImageView *newFinderBg=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Bk_CreateFolder.png"]];
        newFinderBg.frame=CGRectMake(25, 100, 270, 176);
        [self.newFinderView addSubview:newFinderBg];
        UILabel *lblTitle=[[[UILabel alloc] initWithFrame:CGRectMake(91, 110, 138, 21)] autorelease];
        lblTitle.textColor=[UIColor whiteColor];
        lblTitle.backgroundColor=[UIColor clearColor];
        lblTitle.textAlignment=UITextAlignmentCenter;
        lblTitle.text=@"新建文件夹";
        [self.newFinderView addSubview:lblTitle];
        UIButton *btnOk=[UIButton buttonWithType:UIButtonTypeCustom];
        btnOk.frame=CGRectMake(25, 221, 135, 55);
        //btnOk.titleLabel.text=@"确定";
        [btnOk setTitle:@"确定" forState:UIControlStateNormal];
        [btnOk setBackgroundImage:[UIImage imageNamed:@"Bk_naChecked.png"] forState:UIControlStateHighlighted];
        [btnOk setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnOk addTarget:self action:@selector(okNewFinder:) forControlEvents:UIControlEventTouchUpInside];
        [self.newFinderView addSubview:btnOk];
        UIButton *btnCancel=[UIButton buttonWithType:UIButtonTypeCustom];
        btnCancel.frame=CGRectMake(160, 221, 135, 55);
        [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
        [btnCancel setBackgroundImage:[UIImage imageNamed:@"Bk_naChecked.png"] forState:UIControlStateHighlighted];
        btnCancel.titleLabel.textColor=[UIColor whiteColor];
        [btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnCancel addTarget:self action:@selector(cancelNewFinder:) forControlEvents:UIControlEventTouchUpInside];
        [self.newFinderView addSubview:btnCancel];
        self.tfdFinderName=[[[UITextField alloc] initWithFrame:CGRectMake(83, 159, 190, 30)] autorelease];
        self.tfdFinderName.placeholder=@"文件夹名称";
        self.tfdFinderName.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
        self.tfdFinderName.borderStyle=UITextBorderStyleNone;
        self.tfdFinderName.delegate=self;
        [self.newFinderView addSubview:self.tfdFinderName];
        
    }
    return self;
}
-(void)touchView:(id)sender
{
    if (!self.ctrlView.isHidden) {
        [self.ctrlView setHidden:YES];
    }
}
-(void)dealloc
{
    [self.fm cancelAllTask];
    self.fm=nil;
    [self.fm_move  cancelAllTask];
    self.fm_move=nil;
    [super dealloc];
    //self.imageDownloadsInProgress=nil;
}
- (void)viewDidLoad
{
    [self setHidesBottomBarWhenPushed:NO];
    self.imageDownloadsInProgress=[NSMutableDictionary dictionary];
    [super viewDidLoad];
    self.optionCell=[[[UITableViewCell alloc] init] autorelease];
    [self.optionCell addSubview:[[[UIToolbar alloc] init] autorelease]];
    self.selectedIndexPath=nil;
//    self.toolBar=[[UIToolbar alloc] init];
//    CGSize wsize=[[UIScreen mainScreen] bounds].size;
//    [self.toolBar setFrame:CGRectMake(0, wsize.height-50, wsize.width, 50)];
//    [self.view.superview addSubview:self.toolBar];
//    [self.view.superview layoutSubviews];

}
- (void)viewWillAppear:(BOOL)animated
{
    self.titleLabel.text=self.navigationItem.title;
    
    CGRect r=self.ctrlView.frame;
    r.origin.y=44;
    self.ctrlView.frame=self.view.frame;
    r=self.view.frame;
    r.origin.y=44;
    r.size.height=self.view.frame.size.height-56;
    self.tableView.frame=r;
    [self.ctrlView setHidden:YES];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    
    [self setHidesBottomBarWhenPushed:NO];
    
    [self updateFileList];
    NSLog(@"viewWillAppear::");
    [super viewWillAppear:animated];
    //Initialize the toolbar
    if (self.myndsType!=kMyndsTypeSelect)
    {
        return;
    }
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.barStyle = UIBarStyleDefault;
    
    //Set the toolbar to fit the width of the app.
    [toolbar sizeToFit];
    
    //Caclulate the height of the toolbar
    CGFloat toolbarHeight = [toolbar frame].size.height;
    
    //Get the bounds of the parent view
    CGRect rootViewBounds = self.parentViewController.view.bounds;
    
    //Get the height of the parent view.
    CGFloat rootViewHeight = CGRectGetHeight(rootViewBounds);
    
    //Get the width of the parent view,
    CGFloat rootViewWidth = CGRectGetWidth(rootViewBounds);
    
    //Create a rectangle for the toolbar
    CGRect rectArea = CGRectMake(0, rootViewHeight - toolbarHeight, rootViewWidth, toolbarHeight);
    
    //Reposition and resize the receiver
    [toolbar setFrame:rectArea];
    
    //Add the toolbar as a subview to the navigation controller.
    [self.navigationController.view addSubview:toolbar];
    self.toolBar=toolbar;
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.myndsType==kMyndsTypeDefault) {
//        self.editBtn=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(showMenu:)];
//        [self.editBtn setImage:[UIImage imageNamed:@"Bt_Operator.png"]];
        self.editBtn=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Bt_Operator.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showMenu:)];
        self.deleteBtn=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteAction:)];
        //[self.deleteBtn setEnabled:NO];
        [self.navigationItem setRightBarButtonItems:@[self.editBtn]];
        if(self.isEditing)
        {
            [self editAction:self.editBtn];
        }
    }else if (self.myndsType==kMyndsTypeSelect)
    {
        UIBarButtonItem *ok_btn=[[UIBarButtonItem alloc] initWithTitle:@"    确 定    " style:UIBarButtonItemStyleDone target:self action:@selector(moveFileToHere:)];
        UIBarButtonItem *cancel_btn=[[UIBarButtonItem alloc] initWithTitle:@"    取 消    " style:UIBarButtonItemStyleBordered target:self action:@selector(moveCancel:)];
        UIBarButtonItem *fix=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [self.navigationItem setRightBarButtonItems:nil];
        [self.toolBar setItems:@[fix,cancel_btn,fix,ok_btn,fix]];
        [ok_btn release];
        [cancel_btn release];
        [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.x, self.tableView.frame.size.width, self.tableView.frame.size.height-44)];
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [self.sm cancelAllTask];
    self.sm=nil;
    [self.fm cancelAllTask];
    self.fm=nil;
    [self.fm_move cancelAllTask];
    self.fm_move=nil;
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    for (IconDownloader *iconLoader in self.imageDownloadsInProgress.allValues) {
        [iconLoader cancelDownload];
    };
}
-(void)viewDidUnload
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 操作方法
-(void)cancelNewFinder:(id)sender
{
    [self.tfdFinderName endEditing:YES];
    [self.newFinderView setHidden:YES];
}
-(void)okNewFinder:(id)sender
{
    [self.tfdFinderName endEditing:YES];
    NSString *fildtext=[self.tfdFinderName text];
    //                if (![fildtext isEqualToString:name]) {
    //                    NSLog(@"重命名");
    //                    [self.fm cancelAllTask];
    //                    self.fm=[[[SCBFileManager alloc] init] autorelease];
    //                    [self.fm renameWithID:f_id newName:fildtext];
    //                    [self.fm setDelegate:self];
    //                }
    [self.fm cancelAllTask];
    self.fm=[[[SCBFileManager alloc] init] autorelease];
    [self.fm newFinderWithName:fildtext pID:self.f_id sID:[[SCBSession sharedSession] spaceID]];
    [self.fm setDelegate:self];
    NSLog(@"点击确定");
    [self.newFinderView setHidden:YES];
}
- (void)moveFileToHere:(id)sender
{
    [self.delegate moveFileToID:self.f_id];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)moveCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)deleteAction:(id)sender
{
    NSMutableArray *f_ids=[NSMutableArray array];
    NSMutableArray *deleteObjects=[NSMutableArray array];
    for (int i=0;i<self.m_fileItems.count;i++) {
        FileItem *fileItem=[self.m_fileItems objectAtIndex:i];
        if (fileItem.checked) {
            NSDictionary *dic=[self.listArray objectAtIndex:i];
            NSString *f_id=[dic objectForKey:@"f_id"];
            [f_ids addObject:f_id];
            [deleteObjects addObject:dic];
        }
    }
    if ([deleteObjects count]<=0) {
        return;
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否要删除所选文件" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
    [alertView setTag:kAlertTagDeleteMore];
    [alertView release];
}
- (void)editAction:(id)sender
{
    [self.ctrlView setHidden:YES];
    [self hideOptionCell];
    [self setIsEditing:!self.isEditing];
    //UIBarButtonItem *button = (UIBarButtonItem *)sender;
    if (self.isEditing) {
        //[button setTitle:@"完成"];
        //[self.navigationItem setRightBarButtonItems:@[self.editBtn,self.deleteBtn] animated:YES];
        [self.lblEdit setText:@"取消"];
        [self.navigationItem setLeftBarButtonItem:self.deleteBtn];
        AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
        [appDelegate.myTabBarController setHidesTabBarWithAnimate:YES];
//        CGRect r=self.view.frame;
//        r.size.height=[[UIScreen mainScreen] bounds].size.height-r.origin.y;
//        self.view.frame=r;
//        //self.tabBarController.tabBar.hidden=YES;
    }else
    {
        //[button setTitle:@"编辑"];
        [self.lblEdit setText:@"编辑"];
        [self.navigationItem setLeftBarButtonItem:nil];
        AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
        [appDelegate.myTabBarController setHidesTabBarWithAnimate:NO];
        //[self.navigationItem setRightBarButtonItems:@[self.editBtn] animated:YES];
    }
    //   if (!button.selected) {
    //        NDAppDelegate *appDelegate =  (NDAppDelegate *)[UIApplication sharedApplication].delegate;
    //        [appDelegate clearCopyCache];
    //    }
    //[self setEditing:self.isEditing animated:YES];
    [self resetFileItems];
    [self.tableView setEditing:self.isEditing animated:YES];
    
    //    [self hiddenBatchButton:m_editButton.selected];
    //    m_editButton.selected = !m_editButton.selected;
    
    //    [self.m_tableView.dragRefreshTableView setEditing:m_editButton.selected animated:YES];
    //[self.tableView setEditing:YES animated:YES];
    
    
    //    if (m_editButton.selected) {
    //        self.items = [NSMutableArray arrayWithCapacity:0];
    //        for (int i=0; i<[m_listArray count]; i++) {
    //            Item *item = [[Item alloc] init];
    //            //     item.title = [NSString stringWithFormat:@"%d",i];
    //            item.isChecked = NO;
    //            [_items addObject:item];
    //            [item release];
    //        }
    //    }
    //    [self.m_tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
}
-(void)loadData
{
    [self updateFileList];
}
- (void)operateUpdate
{
    [self.fm cancelAllTask];
    self.fm=nil;
    self.fm=[[[SCBFileManager alloc] init] autorelease];
    [self.fm setDelegate:self];
    [self.fm operateUpdateWithID:self.f_id ];
}
- (void)updateFileList
{
    NSString *dataFilePath=[YNFunctions getDataCachePath];
    dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:self.f_id]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataFilePath])
    {
        NSError *jsonParsingError=nil;
        NSData *data=[NSData dataWithContentsOfFile:dataFilePath];
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
        self.dataDic=dic;
        if (self.dataDic) {
            self.listArray=(NSArray *)[self.dataDic objectForKey:@"files"];
            NSMutableArray *a=[NSMutableArray array];
            NSMutableArray *b=[NSMutableArray array];
            for (int i=0; i<self.listArray.count; i++) {
                FileItem *fileItem=[[[FileItem alloc]init]autorelease];
                [a addObject:fileItem];
                [fileItem setChecked:NO];
                NSDictionary *dic=[self.listArray objectAtIndex:i];
                NSString *f_mime=[[dic objectForKey:@"f_mime"] lowercaseString];
                if ([f_mime isEqualToString:@"directory"]) {
                    [b addObject:dic];
                }
            }
            self.m_fileItems=a;
            self.finderArray=b;
            [self.tableView reloadData];
        }
    }
    //    if (self.fm) {
    //        return;
    //    }
    if (self.myndsType==kMyndsTypeMyShare) {
        [self.sm cancelAllTask];
        self.sm=nil;
        self.sm=[[[SCBShareManager alloc] init] autorelease];
        [self.sm setDelegate:self];
        [self.sm openFinderWithID:self.f_id shareType:@"O"];
    }else if (self.myndsType==kMyndsTypeShare) {
        [self.sm cancelAllTask];
        self.sm=nil;
        self.sm=[[[SCBShareManager alloc] init] autorelease];
        [self.sm setDelegate:self];
        [self.sm openFinderWithID:self.f_id shareType:@"M"];
    }else
    {
        [self.fm cancelAllTask];
        self.fm=nil;
        self.fm=[[[SCBFileManager alloc] init] autorelease];
        [self.fm setDelegate:self];
        [self.fm openFinderWithID:self.f_id sID:[[SCBSession sharedSession] spaceID]];
    }
}

-(void)goUpload:(id)sender
{
    //打开照片库
    QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsMultipleSelection = YES;

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
    [navigationController setNavigationBarHidden:YES];
    [self presentModalViewController:navigationController animated:YES];
    [imagePickerController release];
    [navigationController release];
    NSLog(@"点击上传");
}

#pragma mark QBImagePickerControllerDelegate

-(void)changeUpload:(NSMutableOrderedSet *)array_
{
    AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app_delegate.upload_all changeUpload:array_];
}
-(void)changeDeviceName:(NSString *)device_name
{
    AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app_delegate.upload_all changeDeviceName:device_name];
}

-(void)goSearch:(id)sender
{
    NSLog(@"点击搜索");
}
-(void)goMessage:(id)sender
{
    NSLog(@"点击消息");
}
-(void)newFinder:(id)sender
{
    [self.ctrlView setHidden:YES];
    NSLog(@"点击新建文件夹");
    [self.newFinderView setHidden:NO];
//    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"新建文件夹" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
//    [[alert textFieldAtIndex:0] setText:@""];
//    [[alert textFieldAtIndex:0] setDelegate:self];
//    [alert setTag:kAlertTagNewFinder];
//    [alert show];
}
-(void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)showMenu:(id)sender
{
    if (self.selectedIndexPath) {
        //[self.tableView deleteRowsAtIndexPaths:@[self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self hideOptionCell];
    }
    [self.ctrlView setHidden:!self.ctrlView.hidden];
}
-(void)toMore:(id)sender
{
    UIActionSheet *actionSheet=[[UIActionSheet alloc]  initWithTitle:@"更多" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:@"分享", nil];
    [actionSheet setTag:kActionSheetTagMore];
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
}
-(void)toRename:(id)sender
{
    NSDictionary *dic=[self.listArray objectAtIndex:self.selectedIndexPath.row-1];
    NSString *name=[dic objectForKey:@"f_name"];
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"重命名" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[alert textFieldAtIndex:0] setText:name];
    [alert setTag:kAlertTagRename];
    [alert show];
}
-(void)toFavorite:(id)sender
{
    NSDictionary *dic=[self.listArray objectAtIndex:self.selectedIndexPath.row-1];
    NSString *f_id=[dic objectForKey:@"f_id"];
    if ([[FavoritesData sharedFavoritesData] isExistsWithFID:f_id]) {
        [[FavoritesData sharedFavoritesData] removeObjectForKey:f_id];
        NSString *fileName=[dic objectForKey:@"f_name"];
        NSString *filePath=[YNFunctions getFMCachePath];
        filePath=[filePath stringByAppendingPathComponent:fileName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSError *error=[[NSError alloc] init];
            if ([[NSFileManager defaultManager] removeItemAtPath:filePath error:&error]) {
                NSLog(@"删除本地收藏文件成功：%@",filePath);
            }else
            {
                NSLog(@"删除本地收藏文件失败：%@",filePath);
            }
        }
    }else
    {
        [[FavoritesData sharedFavoritesData] setObject:dic forKey:f_id];
    }
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:self.selectedIndexPath.row -1 inSection:self.selectedIndexPath.section];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self hideOptionCell];
}
-(void)toDelete:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否要删除文件" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
    [alertView setTag:kAlertTagDeleteOne];
    [alertView release];
}
-(void)moveFileToID:(NSString *)f_id
{
    NSDictionary *dic=[self.listArray objectAtIndex:self.selectedIndexPath.row-1];
    NSString *m_fid=[dic objectForKey:@"f_id"];
    if (self.fm_move) {
        [self.fm cancelAllTask];
    }else
    {
        self.fm_move=[[[SCBFileManager alloc] init] autorelease];
    }
    self.fm_move.delegate=self;
    if ([f_id intValue]!=[m_fid intValue]) {
        [self.fm_move moveFileIDs:@[m_fid] toPID:f_id];
    }
    [self hideOptionCell];
}
-(void)toShared:(id)sender
{
    NSDictionary *dic=[self.listArray objectAtIndex:self.selectedIndexPath.row-1];
    NSString *f_id=[dic objectForKey:@"f_id"];
    
    SCBLinkManager *lm_temp=[[[SCBLinkManager alloc] init] autorelease];
    [lm_temp setDelegate:self];
    [lm_temp linkWithIDs:@[f_id]];
    [self hideOptionCell];
//    NSArray *activityItems=[[NSArray alloc] initWithObjects:@"?想和您分享虹盘的文件，链接地址：?", nil];
//    UIActivityViewController *activetyVC=[[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
//    
//    UIActivityViewControllerCompletionHandler myBlock=^(NSString *activityType,BOOL completed){
//        NSLog(@"%@",activityType);
//        if (completed) {
//            NSLog(@"completed");
//        }else
//        {
//            NSLog(@"cancled");
//        }
//    };
//    activetyVC.completionHandler=myBlock;
//    [self presentViewController:activetyVC animated:YES completion:nil];
}
-(void)toMove:(id)sender
{
    
    MyndsViewController *moveViewController=[[[MyndsViewController alloc] init] autorelease];
    moveViewController.f_id=@"1";
    moveViewController.myndsType=kMyndsTypeSelect;
    moveViewController.title=@"我的空间";
    moveViewController.delegate=self;
    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:moveViewController];
    [self presentViewController:nav animated:YES completion:nil];
}
-(void)hideOptionCell
{
    if(self.selectedIndexPath) {
        NSArray *indexesToDelete = @[self.selectedIndexPath];
        self.selectedIndexPath = nil;
        //[self.tableView deleteRowsAtIndexPaths:indexesToDelete withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [self.cellMenu setHidden:YES];
}
-(void)pasteBoard:(NSString *)content
{
    [[UIPasteboard generalPasteboard] setString:content];
}
-(void)mailShare:(NSString *)content
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        
        [picker setSubject:content];
        
        
        // Set up recipients
        //NSArray *toRecipients = [NSArray arrayWithObject:@"first@example.com"];
        //NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil];
        //NSArray *bccRecipients = [NSArray arrayWithObject:@"fourth@example.com"];
        
        //[picker setToRecipients:toRecipients];
        //[picker setCcRecipients:ccRecipients];
        //[picker setBccRecipients:bccRecipients];
        
        // Attach an image to the email
        //NSString *path = [[NSBundle mainBundle] pathForResource:@"rainy" ofType:@"jpg"];
        //NSData *myData = [NSData dataWithContentsOfFile:path];
        //[picker addAttachmentData:myData mimeType:@"image/jpeg" fileName:@"rainy"];
        
        // Fill out the email body text
        NSString *emailBody = content;
        [picker setMessageBody:emailBody isHTML:NO];
        
        [self presentModalViewController:picker animated:YES];
        [picker release];
    }
}
-(void)messageShare:(NSString *)content
{
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
        picker.messageComposeDelegate = self;
        
        [picker setBody:content];
        [self presentModalViewController:picker animated:YES];
        [picker release];
    }
}
-(void)weixin:(NSString *)content
{
    AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    [appDelegate sendImageContentIsFiends:NO text:content];
}
-(void)frends:(NSString *)content
{
    AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    [appDelegate sendImageContentIsFiends:YES text:content];
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (self.dataDic) {
        if (self.myndsType==kMyndsTypeSelect) {
            return [self.finderArray count];
        }else
        {
            NSArray *a= (NSArray *)[self.dataDic objectForKey:@"files"];
            if (self.selectedIndexPath) {
                //return [a count]+1;
            }
            return [a count];
        }
    }
    return 1;
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self.ctrlView setHidden:YES];
    if (self.selectedIndexPath && self.selectedIndexPath.row==indexPath.row+1) {
        [self hideOptionCell];
        return;
    }
    int row=indexPath.row;
    NSArray *a= (NSArray *)[self.dataDic objectForKey:@"files"];
    NSDictionary *this=(NSDictionary *)[a objectAtIndex:row];
    NSString *t_fl = [[this objectForKey:@"f_mime"] lowercaseString];
    if ([t_fl isEqualToString:@"directory"]) {
        self.btnRename.frame=CGRectMake(130, 8, 60, 60);
        self.lblRename.frame=CGRectMake(139, 45, 42, 21);
        self.btnDel.hidden=NO;
        self.lblDel.hidden=NO;
        self.btnDownload.hidden=YES;
        self.lblDownload.hidden=YES;
        self.btnMore.hidden=YES;
        self.lblMore.hidden=YES;
    }else{
        self.btnRename.frame=CGRectMake(90, 8, 60, 60);
        self.lblRename.frame=CGRectMake(99, 45, 42, 21);
        self.btnDel.hidden=YES;
        self.lblDel.hidden=YES;
        self.btnDownload.hidden=NO;
        self.lblDownload.hidden=NO;
        self.btnMore.hidden=NO;
        self.lblMore.hidden=NO;

    }
    CGRect r=self.cellMenu.frame;
    r.origin.y=(indexPath.row+1) * 50-8;
    if (r.origin.y+r.size.height > self.tableView.contentSize.height) {
        r.origin.y=self.tableView.contentSize.height-r.size.height;
    }
    self.cellMenu.frame=r;
    [self.cellMenu setHidden:NO];
    
    double delayInSeconds = 0.0;
    BOOL shouldAdjustInsertedRow = YES;
    if(self.selectedIndexPath) {
        NSArray *indexesToDelete = @[self.selectedIndexPath];
        if(self.selectedIndexPath.row <= indexPath.row)
            shouldAdjustInsertedRow = NO;
        self.selectedIndexPath = nil;
        delayInSeconds = 0.2;
//        [tableView deleteRowsAtIndexPaths:indexesToDelete withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    //    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    //    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    //        if(shouldAdjustInsertedRow)
    //            self.selectedIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
    //        else
    //            self.selectedIndexPath = indexPath;
    //        [tableView insertRowsAtIndexPaths:@[self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    //    });
    if(shouldAdjustInsertedRow)
    {
        self.selectedIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
    }
    else
    {
        self.selectedIndexPath = indexPath;
    }
 //   [tableView insertRowsAtIndexPaths:@[self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.myndsType==kMyndsTypeSelect) {
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[FileItemTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                             reuseIdentifier:CellIdentifier] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        if (self.dataDic) {
            NSArray *a= (NSArray *)[self.dataDic objectForKey:@"files"];
            NSDictionary *this=(NSDictionary *)[a objectAtIndex:indexPath.row];

            
            NSString *name= [this objectForKey:@"f_name"];
            NSString *f_modify=[this objectForKey:@"f_modify"];
            cell.textLabel.text=name;
            cell.detailTextLabel.text=f_modify;
            cell.imageView.image = [UIImage imageNamed:@"Ico_FolderF.png"];
        return cell;
        }
    }
//    if (self.selectedIndexPath && self.selectedIndexPath.row==indexPath.row && self.selectedIndexPath.section==indexPath.section) {
//        static NSString *CellIdentifier = @"Option Cell";
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//        if (cell == nil) {
//            cell = [[[FileItemTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle
//                                             reuseIdentifier:CellIdentifier] autorelease];
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        }
//        //cell.textLabel.text=@"收藏   分享   删除";
//        CGRect r=cell.bounds;
//        r.size.height=50;
//        UIToolbar *toolbar=[[[UIToolbar alloc] initWithFrame:r] autorelease];
//        //[toolbar setBackgroundImage:[UIImage imageNamed:@"option_bar.png"] forToolbarPosition:UIToolbarPositionTop barMetrics:UIBarMetricsDefault];
//        [toolbar insertSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Bk_OptionBar.png"]] atIndex:1];
//        //UIBarButtonItem *item0=[[UIBarButtonItem alloc] initWithTitle:@"重命名" style:UIBarButtonItemStyleDone target:self action:@selector(toRename:)];
//        UIBarButtonItem *item0=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"option_bar_edit.png"] style:UIBarButtonItemStylePlain target:self action:@selector(toRename:)];
//        [item0 setTitle:@"重命名"];
//        //UIBarButtonItem *item1=[[UIBarButtonItem alloc] initWithTitle:@"收藏" style:UIBarButtonItemStyleDone target:self action:@selector(toFavorite:)];
//        UIBarButtonItem *item1=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"tab_btn_favorite.png"] style:UIBarButtonItemStylePlain target:self action:@selector(toFavorite:)];
//        [item1 setTitle:@"收藏"];
//        //UIBarButtonItem *item2=[[UIBarButtonItem alloc] initWithTitle:@"移动" style:UIBarButtonItemStyleDone target:self action:@selector(toShared:)];
//        UIBarButtonItem *item2=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"option_bar_move.png"] style:UIBarButtonItemStylePlain target:self action:@selector(toMove:)];
//        [item2 setTitle:@"移动"];
//        //UIBarButtonItem *item3=[[UIBarButtonItem alloc] initWithTitle:@"删除" style:UIBarButtonItemStyleDone target:self action:@selector(toDelete:)];
//        UIBarButtonItem *item3=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"option_bar_remove.png"] style:UIBarButtonItemStylePlain target:self action:@selector(toDelete:)];
//        [item3 setTitle:@"删除"];
//        UIBarButtonItem *itemMore=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Bt_Operator.png"] style:UIBarButtonItemStylePlain target:self action:@selector(toMore:)];
//        [itemMore setTitle:@"更多"];
//        UIBarButtonItem *flexible=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//        NSDictionary *this=(NSDictionary *)[self.listArray objectAtIndex:indexPath.row-1];
//        NSString *t_fl = [[this objectForKey:@"f_mime"] lowercaseString];
//        if ([t_fl isEqualToString:@"directory"]) {
//            [toolbar setItems:@[flexible,item0,flexible,item2,flexible,item3,flexible]];
//        }else
//        {
//            if ([YNFunctions isOpenHideFeature]) {
//                [toolbar setItems:@[flexible,item0,flexible,item1,flexible,item2,flexible,itemMore,flexible]];
//            }else
//            {
//                [toolbar setItems:@[flexible,item0,flexible,item1,flexible,item2,flexible,item3,flexible]];
//            }
//        }
//        
//        [cell addSubview:toolbar];
//        return cell;
//    }
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[FileItemTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    int row=indexPath.row;
//    if (self.selectedIndexPath && self.selectedIndexPath.row<indexPath.row) {
//        row=row-1;
//    }
    UILabel *label =cell.textLabel;
    NSString *text;
    if (self.dataDic) {
        NSArray *a= (NSArray *)[self.dataDic objectForKey:@"files"];
        NSDictionary *this=(NSDictionary *)[a objectAtIndex:row];
        NSString *t_fl = [[this objectForKey:@"f_mime"] lowercaseString];
        if (self.myndsType==kMyndsTypeDefault) {
            cell.accessoryType=UITableViewCellAccessoryDetailDisclosureButton;
        }else
        {
            cell.accessoryType=UITableViewCellAccessoryNone;
        }
        
//        UIButton *btn=(UIButton *)cell.accessoryView;
//        [btn setBackgroundImage:[UIImage imageNamed:@"accessory.png"] forState:UIControlStateNormal];
        FileItem* fileItem = [self.m_fileItems objectAtIndex:row];
        [cell setChecked:fileItem.checked];
        
        NSString *name= [this objectForKey:@"f_name"];
        NSString *f_modify=[this objectForKey:@"f_modify"];
        NSString *f_id=[this objectForKey:@"f_id"];
        //cell.detailTextLabel.text=f_modify;
        if ([t_fl isEqualToString:@"directory"]) {
            cell.detailTextLabel.text=f_modify;
            if (cell.imageView.subviews.count>0) {
                UIImageView *tagView=[cell.imageView.subviews objectAtIndex:0];
                [tagView setHidden:YES];
            }
        }else
        {
            NSString *f_size=[this objectForKey:@"f_size"];
            cell.detailTextLabel.text=[NSString stringWithFormat:@"%@ %@",f_modify,[YNFunctions convertSize:f_size]];
        //是否显示收藏图标
            NSObject *tag=nil;
            tag=[[FavoritesData sharedFavoritesData] isExistsWithFID:f_id];
            if (tag!=nil) {
                if (cell.imageView.subviews.count==0) {
                    UIImageView *tagView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"favorite_tag.png"]];
                    CGRect r=[tagView frame];
                    r.origin.x=20;
                    r.origin.y=20;
                    [tagView setFrame:r];
                    [cell.imageView addSubview:tagView];
                }
                UIImageView *tagView=[cell.imageView.subviews objectAtIndex:0];
                [tagView setHidden:NO];
            }else
            {
                if (cell.imageView.subviews.count==0) {
                    UIImageView *tagView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"favorite_tag.png"]];
                    CGRect r=[tagView frame];
                    r.origin.x=20;
                    r.origin.y=20;
                    [tagView setFrame:r];
                    [cell.imageView addSubview:tagView];
                }
                UIImageView *tagView=[cell.imageView.subviews objectAtIndex:0];
                [tagView setHidden:YES];
            }
//            NSString *filePath=[YNFunctions getFMCachePath];
//            filePath=[filePath stringByAppendingPathComponent:name];
//            
//            UIImageView *tagImageView=(UIImageView *)[cell.imageView.subviews objectAtIndex:0];
//            [tagImageView setImage:[UIImage imageNamed:@"favorite_tag_n.png"]];
//            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
//                [tagImageView setImage:[UIImage imageNamed:@"favorite_tag.png"]];
//            }
        }
        text=name;
        
        if ([t_fl isEqualToString:@"directory"]) {
            cell.imageView.image = [UIImage imageNamed:@"Ico_FolderF.png"];
        }else if ([t_fl isEqualToString:@"png"]||
                  [t_fl isEqualToString:@"jpg"]||
                  [t_fl isEqualToString:@"jpeg"]||
                  [t_fl isEqualToString:@"bmp"]||
                  [t_fl isEqualToString:@"gif"])
        {
            NSDictionary *dic = [self.listArray objectAtIndex:row];
            NSString *compressaddr=[dic objectForKey:@"compressaddr"];
            compressaddr =[YNFunctions picFileNameFromURL:compressaddr];
            NSString *path=[YNFunctions getIconCachePath];
            path=[path stringByAppendingPathComponent:compressaddr];
            
            //"compressaddr":"cimage/cs860183fc-81bd-40c2-817a-59653d0dc513.jpg"
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) // avoid the app icon download if the app already has an icon
            {
                //UIImageView *tagView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:path]];
                UIImage *icon=[UIImage imageWithContentsOfFile:path];
                CGSize itemSize = CGSizeMake(160, 100);
                UIGraphicsBeginImageContext(itemSize);
                CGRect theR=CGRectMake(0, 0, itemSize.width, itemSize.height);
                if (icon.size.width>icon.size.height) {
                    theR.size.width=icon.size.width/(icon.size.height/itemSize.height);
                    theR.origin.x=-(theR.size.width/2)-itemSize.width;
                }else
                {
                    theR.size.height=icon.size.height/(icon.size.width/itemSize.width);
                    theR.origin.y=-(theR.size.height/2)-itemSize.height;
                }
                CGRect imageRect = CGRectMake(35, 5, 90, 90);
                [icon drawInRect:imageRect];
                UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                cell.imageView.image = image;
            }else
            {
                [self startIconDownload:dic forIndexPath:indexPath];
                cell.imageView.image = [UIImage imageNamed:@"Ico_PicF.png"];
            }
        }else if ([t_fl isEqualToString:@"doc"]||
                  [t_fl isEqualToString:@"docx"])
        {
            cell.imageView.image = [UIImage imageNamed:@"Ico_DocF.png"];
        }else if ([t_fl isEqualToString:@"mp3"])
        {
            cell.imageView.image = [UIImage imageNamed:@"Ico_MusicF.png"];
        }else if ([t_fl isEqualToString:@"mov"])
        {
            cell.imageView.image = [UIImage imageNamed:@"Ico_MovF.png"];
        }else if ([t_fl isEqualToString:@"ppt"])
        {
            cell.imageView.image = [UIImage imageNamed:@"icon_ppt.png"];
        }else
        {
            cell.imageView.image = [UIImage imageNamed:@"Ico_OtherF.png"];
        }
//        UIImageView *tagImageView=[cell.imageView.subviews objectAtIndex:0];
//        if ([t_fl isEqualToString:@"png"]||
//            [t_fl isEqualToString:@"jpg"]||
//            [t_fl isEqualToString:@"jpeg"]||
//            [t_fl isEqualToString:@"bmp"]||
//            [t_fl isEqualToString:@"gif"])
//        {
//            CGRect r=[tagImageView frame];
//            r.origin.x=20;
//            r.origin.y=20;
//            [tagImageView setFrame:r];
//        }else
//        {
//            CGRect r=[tagImageView frame];
//            r.origin.x=25;
//            r.origin.y=25;
//            [tagImageView setFrame:r];
//        }
        
    }else
    {
        text = @"加载中...";
    }
    label.text=text;
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}
// Override to support conditional editing of the table view.
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Return NO if you do not want the specified item to be editable.
//    return YES;
//}


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"Nib name" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    [self.ctrlView setHidden:YES];
    if (self.selectedIndexPath) {
        [self hideOptionCell];
        return;
    }
    
    if (self.dataDic==Nil) {
        return;
    }
    if (self.isEditing) {
        FileItem* fileItem = [self.m_fileItems objectAtIndex:indexPath.row];
        FileItemTableCell *cell = (FileItemTableCell*)[tableView cellForRowAtIndexPath:indexPath];
		fileItem.checked = !fileItem.checked;
		[cell setChecked:fileItem.checked];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    NSDictionary *dic=[self.listArray objectAtIndex:indexPath.row];
    NSString *f_name=[dic objectForKey:@"f_name"];
    NSString *f_id=[dic objectForKey:@"f_id"];
    NSString *f_mime=[[dic objectForKey:@"f_mime"] lowercaseString];
    if ([f_mime isEqualToString:@"directory"]) {
        MyndsViewController *viewController =[[[MyndsViewController alloc] init] autorelease];
        viewController.f_id=f_id;
        viewController.myndsType=self.myndsType;
        if (self.myndsType==kMyndsTypeSelect){
            viewController.delegate=self.delegate;
        }
        viewController.title=f_name;
        [self.navigationController pushViewController:viewController animated:YES];
    }else
    {
        if (self.myndsType!=kMyndsTypeDefault) {
            return;
        }
        if ([f_mime isEqualToString:@"png"]||
            [f_mime isEqualToString:@"jpg"]||
            [f_mime isEqualToString:@"jpeg"]||
            [f_mime isEqualToString:@"bmp"]||
            [f_mime isEqualToString:@"gif"]) {
            NSMutableArray *array=[NSMutableArray array];
            int index=0;
            for (int i=0;i<self.listArray.count;i++) {
                NSDictionary *dict=[self.listArray objectAtIndex:i];
                NSString *f_mime=[[dict objectForKey:@"f_mime"] lowercaseString];
                if ([f_mime isEqualToString:@"png"]||
                    [f_mime isEqualToString:@"jpg"]||
                    [f_mime isEqualToString:@"jpeg"]||
                    [f_mime isEqualToString:@"bmp"]||
                    [f_mime isEqualToString:@"gif"]) {
                    PhotoFile *demo = [[PhotoFile alloc] init];
                    [demo setF_date:[dict objectForKey:@"f_create"]];
                    [demo setF_id:[[dict objectForKey:@"f_id"] intValue]];
                    [array addObject:demo];
                    
                    if (i==indexPath.row) {
                        index=array.count-1;
                    }
                    [demo release];
                }
            }
            PhotoLookViewController *photoLookViewController = [[PhotoLookViewController alloc] init];
            [photoLookViewController setHidesBottomBarWhenPushed:YES];
            [photoLookViewController setCurrPage:index];
            [photoLookViewController setTableArray:array];
//            [self.navigationController pushViewController:photoLookViewController animated:YES];
            [self presentModalViewController:photoLookViewController animated:YES];
            [photoLookViewController release];

        }else
        {
            //非图片文件必须加入收藏后才可以预览（其实我的意思是可以直接预览）
            if ([YNFunctions isUnlockFeature]) {
                //先做文件类型判断，是否是为可预览文件，如果为否，不做任何操作
                //判断文件是否下载完成，如果下载完成，打开预览，否则不做任何操作
                NSString *fileName=[dic objectForKey:@"f_name"];
                NSString *filePath=[YNFunctions getFMCachePath];
                filePath=[filePath stringByAppendingPathComponent:fileName];
                if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                    //文件存在，打开预览
                    UIDocumentInteractionController *docIC=[[UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:filePath]] autorelease];
                    docIC.delegate=self;
                    [docIC presentPreviewAnimated:YES];
                }else{
                    OtherBrowserViewController *otherBrowser=[[[OtherBrowserViewController alloc] initWithNibName:@"OtherBrowser" bundle:nil]  autorelease];
                    [otherBrowser setHidesBottomBarWhenPushed:YES];
                    otherBrowser.dataDic=dic;
                    NSString *f_name=[dic objectForKey:@"f_name"];
                    otherBrowser.title=f_name;
                    [self.navigationController pushViewController:otherBrowser animated:YES];
                }

            }
        }
    }
}
#pragma mark - SCBLinkManagerDelegate
-(void)releaseLinkSuccess:(NSString *)l_url
{
    NSString *text=[NSString stringWithFormat:@"%@想和您分享虹盘的文件，链接地址：%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"usr_name"],l_url];
//    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=6.0) {
//        NSArray *activityItems=[[NSArray alloc] initWithObjects:text, nil];
//        UIActivityViewController *activetyVC=[[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
//        
//        UIActivityViewControllerCompletionHandler myBlock=^(NSString *activityType,BOOL completed){
//            NSLog(@"%@",activityType);
//            if (completed) {
//                NSLog(@"completed");
//            }else
//            {
//                NSLog(@"cancled");
//            }
//        };
//        activetyVC.completionHandler=myBlock;
//        [self presentViewController:activetyVC animated:YES completion:nil];
//    }else
    {
        UIActionSheet *actionSheet=[[UIActionSheet alloc]  initWithTitle:@"分享" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"短信分享",@"邮件分享",@"复制链接",@"分享到微信好友",@"分享到微信朋友圈", nil];
        [actionSheet setTitle:text];
        [actionSheet setTag:kActionSheetTagShare];
        [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
        [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    }
}
-(void)releaseLinkUnsuccess;
{
    NSLog(@"openFinderUnsucess: 网络连接失败!!");
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"获取外链失败";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
}
#pragma mark - SCBFileManagerDelegate
-(void)operateSucess:(NSDictionary *)datadic
{
    [self openFinderSucess:datadic];
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"操作成功";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
}
-(void)openFinderSucess:(NSDictionary *)datadic
{
    self.dataDic=datadic;
    self.listArray=(NSArray *)[self.dataDic objectForKey:@"files"];
    NSMutableArray *a=[NSMutableArray array];
    NSMutableArray *b=[NSMutableArray array];
    for (int i=0; i<self.listArray.count; i++) {
        FileItem *fileItem=[[[FileItem alloc]init]autorelease];
        [a addObject:fileItem];
        [fileItem setChecked:NO];
        NSDictionary *dic=[self.listArray objectAtIndex:i];
        NSString *f_mime=[[dic objectForKey:@"f_mime"] lowercaseString];
        if ([f_mime isEqualToString:@"directory"]) {
            [b addObject:dic];
        }
    }
    self.m_fileItems=a;
    self.finderArray=b;
    if (self.dataDic) {
        [self.tableView reloadData];
    }else
    {
        [self updateFileList];
    }
    NSLog(@"openFinderSucess:");
    if (self.dataDic)
    {
        NSString *dataFilePath=[YNFunctions getDataCachePath];
        dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:self.f_id]];
        
        NSError *jsonParsingError=nil;
        NSData *data=[NSJSONSerialization dataWithJSONObject:self.dataDic options:0 error:&jsonParsingError];
        BOOL isWrite=[data writeToFile:dataFilePath atomically:YES];
        if (isWrite) {
            NSLog(@"写入文件成功：%@",dataFilePath);
        }else
        {
            NSLog(@"写入文件失败：%@",dataFilePath);
        }
    }

}
-(void)openFinderUnsucess
{
    NSLog(@"openFinderUnsucess: 网络连接失败!!");
}
-(void)removeSucess
{
    if (self.willDeleteObjects) {
        [self removeFromDicWithObjects:self.willDeleteObjects];
        [self.tableView reloadData];
    }
    
    //[self.tableView reloadData];
    [self updateFileList];
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];    [self.hud show:NO];
    self.hud.labelText=@"操作成功";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
}
-(void)removeUnsucess
{
    NSLog(@"openFinderUnsucess: 网络连接失败!!");
    [self updateFileList];
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"操作失败";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
}
-(void)renameSucess
{
    [self operateUpdate];
//    [self updateFileList];
//    [self updateFileList];
//    if (!self.hud) {
//        self.hud=[[MBProgressHUD alloc] initWithView:self.view];
//        [self.view addSubview:self.hud];
//    }
//    [self.hud show:NO];
//    self.hud.labelText=@"操作成功";
//    self.hud.mode=MBProgressHUDModeText;
//    self.hud.margin=10.f;
//    [self.hud show:YES];
//    [self.hud hide:YES afterDelay:1.0f];
}
-(void)newFinderSucess
{
    [self operateUpdate];
}
-(void)newFinderUnsucess;
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    
    [self.hud show:NO];
    self.hud.labelText=@"操作失败";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
}
-(void)renameUnsucess
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    
    [self.hud show:NO];
    self.hud.labelText=@"操作失败";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
}

-(void)moveUnsucess
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"操作失败";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
}
-(void)moveSucess
{
    [self operateUpdate];
//    [self updateFileList];
//    if (!self.hud) {
//        self.hud=[[MBProgressHUD alloc] initWithView:self.view];
//        [self.view addSubview:self.hud];
//    }
//    [self.hud show:NO];
//    self.hud.labelText=@"操作成功";
//    self.hud.mode=MBProgressHUDModeText;
//    self.hud.margin=10.f;
//    [self.hud show:YES];
//    [self.hud hide:YES afterDelay:1.0f];
}
-(void)removeFromDicWithObjects:(NSArray *)objects
{
    NSMutableArray *tempA=[NSMutableArray arrayWithArray:self.listArray];
    [tempA removeObjectsInArray:objects];
    NSMutableDictionary *tempD=[NSMutableDictionary dictionaryWithDictionary:self.dataDic];
    [tempD setObject:tempA forKey:@"files"];
    self.dataDic=tempD;
    //修改之后的结果写入本地文件，
    NSString *dataFilePath=[YNFunctions getDataCachePath];
    dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:self.f_id]];
    
    NSError *jsonParsingError=nil;
    NSData *data=[NSJSONSerialization dataWithJSONObject:self.dataDic options:0 error:&jsonParsingError];
    BOOL isWrite=[data writeToFile:dataFilePath atomically:YES];
    if (isWrite) {
        NSLog(@"写入文件成功：%@",dataFilePath);
    }else
    {
        NSLog(@"写入文件失败：%@",dataFilePath);
    }
}
-(void)resetFileItems
{
    NSMutableArray *a=[NSMutableArray array];
    for (id o in self.listArray) {
        FileItem *fileItem=[[[FileItem alloc]init]autorelease];
        [a addObject:fileItem];
        [fileItem setChecked:NO];
    }
    self.m_fileItems=a;
}
-(void)removeFromDicWithObject:(id)object
{
    NSMutableArray *tempA=[NSMutableArray arrayWithArray:self.listArray];
    [tempA removeObject:object];
    NSMutableDictionary *tempD=[NSMutableDictionary dictionaryWithDictionary:self.dataDic];
    [tempD setObject:tempA forKey:@"files"];
    self.dataDic=tempD;
    [self resetFileItems];
    //修改之后的结果写入本地文件，
    NSString *dataFilePath=[YNFunctions getDataCachePath];
    dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:self.f_id]];
    
    NSError *jsonParsingError=nil;
    NSData *data=[NSJSONSerialization dataWithJSONObject:self.dataDic options:0 error:&jsonParsingError];
    BOOL isWrite=[data writeToFile:dataFilePath atomically:YES];
    if (isWrite) {
        NSLog(@"写入文件成功：%@",dataFilePath);
    }else
    {
        NSLog(@"写入文件失败：%@",dataFilePath);
    }
}
#pragma mark - UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case kAlertTagDeleteOne:
        {
            if (buttonIndex==1) {
                NSDictionary *dic=[self.listArray objectAtIndex:self.selectedIndexPath.row-1];
                //[self removeFromDicWithObject:dic];
                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:self.selectedIndexPath.row-1 inSection:self.selectedIndexPath.section];
                NSLog(@"%d",self.selectedIndexPath.section);
                NSArray *indexesToDelete = @[indexPath,self.selectedIndexPath];
                self.selectedIndexPath = nil;
                //[self.tableView deleteRowsAtIndexPaths:indexesToDelete withRowAnimation:UITableViewRowAnimationAutomatic];
                self.willDeleteObjects=@[dic];
                NSString *f_id=[dic objectForKey:@"f_id"];
                [self.fm cancelAllTask];
                self.fm=[[[SCBFileManager alloc] init] autorelease];
                self.fm.delegate=self;
                [self.fm removeFileWithIDs:@[f_id]];
            }
            [self hideOptionCell];
            break;
        }
        case kAlertTagRename:
        {
            if (buttonIndex==1) {
                NSDictionary *dic=[self.listArray objectAtIndex:self.selectedIndexPath.row-1];
                NSString *name=[dic objectForKey:@"f_name"];
                NSString *f_id=[dic objectForKey:@"f_id"];
                NSString *fildtext=[[alertView textFieldAtIndex:0] text];
                if (![fildtext isEqualToString:name]) {
                    NSLog(@"重命名");
                    [self.fm cancelAllTask];
                    self.fm=[[[SCBFileManager alloc] init] autorelease];
                    [self.fm renameWithID:f_id newName:fildtext];
                    [self.fm setDelegate:self];
                }
                NSLog(@"点击确定");
            }else
            {
                NSLog(@"点击其它");
            }
            [self hideOptionCell];
            break;
        }
        case kAlertTagDeleteMore:
        {
            if (buttonIndex==1) {
                NSMutableArray *f_ids=[NSMutableArray array];
                NSMutableArray *deleteObjects=[NSMutableArray array];
                for (int i=0;i<self.m_fileItems.count;i++) {
                    FileItem *fileItem=[self.m_fileItems objectAtIndex:i];
                    if (fileItem.checked) {
                        NSDictionary *dic=[self.listArray objectAtIndex:i];
                        NSString *f_id=[dic objectForKey:@"f_id"];
                        [f_ids addObject:f_id];
                        [deleteObjects addObject:dic];
                    }
                }
                self.willDeleteObjects=deleteObjects;
                //[self removeFromDicWithObjects:deleteObjects];
                //[self.tableView reloadData];
                if (f_ids.count>0) {
                    [self.fm cancelAllTask];
                    self.fm=[[[SCBFileManager alloc] init] autorelease];
                    self.fm.delegate=self;
                    [self.fm removeFileWithIDs:f_ids];
                }

            }
            break;
        }
        case kAlertTagNewFinder:
        {
            if (buttonIndex==1) {
                NSString *fildtext=[[alertView textFieldAtIndex:0] text];
//                if (![fildtext isEqualToString:name]) {
//                    NSLog(@"重命名");
//                    [self.fm cancelAllTask];
//                    self.fm=[[[SCBFileManager alloc] init] autorelease];
//                    [self.fm renameWithID:f_id newName:fildtext];
//                    [self.fm setDelegate:self];
//                }
                [self.fm cancelAllTask];
                self.fm=[[[SCBFileManager alloc] init] autorelease];
                [self.fm newFinderWithName:fildtext pID:self.f_id];
                [self.fm setDelegate:self];
                NSLog(@"点击确定");
                [self.ctrlView setHidden:YES];
            }else
            {
                NSLog(@"点击其它");
            }
            //[self hideOptionCell];
            break;
        }
        default:
            break;
    }
    
    
    
}
#pragma mark -
#pragma mark Deferred image loading (UIScrollViewDelegate)

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.ctrlView setHidden:YES];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        if (self.selectedIndexPath) {
            //[self hideOptionCell];
            return;
        }
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.selectedIndexPath) {
        //[self hideOptionCell];
        return;
    }
    [self loadImagesForOnscreenRows];
}

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    if ([self.listArray count] > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            NSDictionary *dic = [self.listArray objectAtIndex:indexPath.row];
            NSString *compressaddr=[dic objectForKey:@"compressaddr"];
            compressaddr =[YNFunctions picFileNameFromURL:compressaddr];
            NSString *path=[YNFunctions getIconCachePath];
            path=[path stringByAppendingPathComponent:compressaddr];
            
            //"compressaddr":"cimage/cs860183fc-81bd-40c2-817a-59653d0dc513.jpg"
            if (![[NSFileManager defaultManager] fileExistsAtPath:path]) // avoid the app icon download if the app already has an icon
            {
                [self startIconDownload:dic forIndexPath:indexPath];
            }
        }
    }
}
- (void)startIconDownload:(NSDictionary *)dic forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil)
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.data_dic=dic;
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        [self.imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
        [iconDownloader startDownload];
        [iconDownloader release];
    }
}
- (void)appImageDidLoad:(NSIndexPath *)indexPath;
{
    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader != nil)
    {        
        [self.tableView reloadRowsAtIndexPaths:@[iconDownloader.indexPathInTableView] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    // Remove the IconDownloader from the in progress list.
    // This will result in it being deallocated.
    [self.imageDownloadsInProgress removeObjectForKey:indexPath];
}
#pragma mark - UIDocumentInteractionControllerDelegate
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)interactionController
{
    return self;
}
#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (range.location >= 255)
        return NO; // return NO to not change text
    return YES;
}
#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch ([actionSheet tag]) {
        case kActionSheetTagMore:
            if (buttonIndex == 0) {
                NSLog(@"删除");
                [self toDelete:nil];
            }else if (buttonIndex == 1) {
                NSLog(@"分享");
                [self toShared:nil];
            }else if(buttonIndex == 2) {
                NSLog(@"取消");
            }
            break;
        case kActionSheetTagShare:
            if (buttonIndex == 0) {
                NSLog(@"短信分享");
                //[self toDelete:nil];
                [self messageShare:actionSheet.title];
            }else if (buttonIndex == 1) {
                NSLog(@"邮件分享");
                //[self toShared:nil];
                [self mailShare:actionSheet.title];
            }else if(buttonIndex == 2) {
                NSLog(@"复制");
                [self pasteBoard:actionSheet.title];
            }else if(buttonIndex == 3) {
                NSLog(@"微信");
                [self weixin:actionSheet.title];
            }else if(buttonIndex == 4) {
                NSLog(@"朋友圈");
                [self frends:actionSheet.title];
            }else if(buttonIndex == 5) {
                NSLog(@"新浪");
            }else if(buttonIndex == 6) {
                NSLog(@"取消");
            }
            break;
        default:
            break;
    }
    
}
#pragma mark -
#pragma mark Dismiss Mail/SMS view controller

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the
// message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	NSString *resultValue=@"";
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			resultValue = @"Result: Mail sending canceled";
			break;
		case MFMailComposeResultSaved:
			resultValue = @"Result: Mail saved";
			break;
		case MFMailComposeResultSent:
			resultValue = @"Result: Mail sent";
			break;
		case MFMailComposeResultFailed:
			resultValue = @"Result: Mail sending failed";
			break;
		default:
			resultValue = @"Result: Mail not sent";
			break;
	}
    NSLog(@"%@",resultValue);
	[self dismissModalViewControllerAnimated:YES];
}


// Dismisses the message composition interface when users tap Cancel or Send. Proceeds to update the
// feedback message field with the result of the operation.
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
	
	NSString *resultValue=@"";
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MessageComposeResultCancelled:
			resultValue = @"Result: SMS sending canceled";
			break;
		case MessageComposeResultSent:
			resultValue = @"Result: SMS sent";
			break;
		case MessageComposeResultFailed:
			resultValue = @"Result: SMS sending failed";
			break;
		default:
			resultValue = @"Result: SMS not sent";
			break;
	}
    NSLog(@"%@",resultValue);
	[self dismissModalViewControllerAnimated:YES];
}


@end
