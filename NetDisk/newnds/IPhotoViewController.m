//
//  IPhotoViewController.m
//  NetDisk
//
//  Created by Yangsl on 13-8-23.
//
//

#import "IPhotoViewController.h"
#import "AppDelegate.h"
#import "SCBSession.h"
#import "PhotoLookViewController.h"

#define TableViewHeight self.view.frame.size.height-TabBarHeight-44
#define ChangeTabWidth 70
#define RightButtonBoderWidth 0

@interface IPhotoViewController ()

@end

@implementation IPhotoViewController
@synthesize topView;
@synthesize isNeedBackButton;
@synthesize isPhoto;
@synthesize file_tableView;
@synthesize photo_tableView;
@synthesize f_id;
@synthesize escButton;
@synthesize move_fid;
@synthesize ctrlView;
@synthesize edit_view;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

//显示文件列表
-(void)showFileList
{
    [file_tableView requestFile:f_id space_id:[[SCBSession sharedSession] spaceID]];
}

//显示照片列表
-(void)showPhotoList
{
    
}

//返回按钮
-(void)clickBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [self.navigationController setNavigationBarHidden:YES];
    self.view.backgroundColor = [UIColor whiteColor];
    //添加头部试图
    topView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [imageV setImage:[UIImage imageNamed:@"Bk_Title.png"]];
    [topView addSubview:imageV];
    [imageV release];
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
    if(isNeedBackButton)
    {
        UIImage *back_image = [UIImage imageNamed:@"Bt_Back.png"];
        UIButton *back_button = [[UIButton alloc] initWithFrame:CGRectMake(RightButtonBoderWidth, (44-back_image.size.height/2)/2, back_image.size.width/2, back_image.size.height/2)];
        [back_button setBackgroundImage:imge forState:UIControlStateHighlighted];
        [back_button setImage:back_image forState:UIControlStateNormal];
        [back_button addTarget:self action:@selector(clickBack) forControlEvents:UIControlEventTouchUpInside];
        [topView addSubview:back_button];
        [back_button release];
    }
    //选项卡栏目
    UIButton *phoot_button = [[UIButton alloc] init];
    [phoot_button setTag:23];
    [phoot_button setFrame:CGRectMake(320/2-ChangeTabWidth, 0, ChangeTabWidth, 44)];
    [phoot_button setTitle:@"文件" forState:UIControlStateNormal];
    [phoot_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [phoot_button addTarget:self action:@selector(clicked_file:) forControlEvents:UIControlEventTouchDown];
    [phoot_button setBackgroundImage:imge forState:UIControlStateHighlighted];
    [topView addSubview:phoot_button];
    [phoot_button release];
    
    UIButton *file_button = [[UIButton alloc] init];
    [file_button setTag:24];
    [file_button setFrame:CGRectMake(320/2, 0, ChangeTabWidth, 44)];
    [file_button setTitle:@"照片" forState:UIControlStateNormal];
    [file_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [file_button addTarget:self action:@selector(clicked_photo:) forControlEvents:UIControlEventTouchDown];
    [file_button setBackgroundImage:imge forState:UIControlStateHighlighted];
    [topView addSubview:file_button];
    [file_button release];
    
    UIButton *space_button = [[UIButton alloc] init];
    [space_button setTag:25];
    [space_button setFrame:CGRectMake(file_button.frame.origin.x+file_button.frame.size.width, 0, 44*70/65, 44)];
//    [space_button setTitle:@"照片" forState:UIControlStateNormal];
    [space_button setImage:[UIImage imageNamed:@"Title_Users.png"] forState:UIControlStateNormal];
    [space_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [space_button addTarget:self action:@selector(clicked_space:) forControlEvents:UIControlEventTouchDown];
    [space_button setBackgroundImage:imge forState:UIControlStateHighlighted];
    [topView addSubview:space_button];
    [space_button release];
    
    //更多按钮
    UIButton *more_button = [[UIButton alloc] init];
    UIImage *moreImage = [UIImage imageNamed:@"Bt_More.png"];
    [more_button setFrame:CGRectMake(320-RightButtonBoderWidth-moreImage.size.width/2, (44-moreImage.size.height/2)/2, moreImage.size.width/2, moreImage.size.height/2)];
    [more_button setImage:moreImage forState:UIControlStateNormal];
    [more_button setBackgroundImage:imge forState:UIControlStateHighlighted];
    [more_button addTarget:self action:@selector(clicked_more:) forControlEvents:UIControlEventTouchDown];
    [topView addSubview:more_button];
    [more_button release];
    [self.view addSubview:topView];
    
    //初始化文件列表
    CGRect rect = CGRectMake(0, 44, 320, TableViewHeight);
    file_tableView = [[FileTableView alloc] initWithFrame:rect];
    [file_tableView setAllHeight:self.view.frame.size.height];
    [file_tableView setFile_delegate:self];
    [self.view addSubview:file_tableView];
    
    
    //初始化图片列表
    photo_tableView = [[PhotoTableView alloc] initWithFrame:rect];
    [photo_tableView setPhoto_delegate:self];
    [self.view addSubview:photo_tableView];
    
    if(isPhoto)
    {
        [self clicked_photo:file_button];
        [file_tableView setHidden:YES];
    }
    else
    {
        [self clicked_file:phoot_button];
        [photo_tableView setHidden:YES];
    }
    
    CGRect esc_rect = CGRectMake(0, 0, 320, self.view.frame.size.height);
    escButton = [[UIButton alloc] initWithFrame:esc_rect];
    [escButton addTarget:self action:@selector(EscMenu) forControlEvents:UIControlEventTouchDown];
    [escButton setHidden:YES];
    [self.view addSubview:escButton];
    
    [super viewDidLoad];
}

//点击照片内容
-(void)clicked_photo:(id)sender
{
    UIButton *button = sender;
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
    [button setBackgroundImage:imge forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    UIButton *photo_button = (UIButton *)[self.view viewWithTag:23];
    [photo_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [photo_button setBackgroundImage:nil forState:UIControlStateNormal];
    
    if(!isPhoto)
    {
        isPhoto = TRUE;
    }
    file_tableView.hidden = YES;
    photo_tableView.hidden = NO;
}

-(void)clicked_space:(id)sender
{
    NSLog(@"-(void)clicked_space:(id)sender");
}

-(void)clicked_more:(id)sender
{
    NSLog(@"-(void)clicked_more:(id)sender");
    
    if(ctrlView == nil)
    {
        //操作菜单
        ctrlView=[[UIControl alloc] init];
        ctrlView.frame=self.view.frame;
        [ctrlView addTarget:self action:@selector(touchView:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:ctrlView];
        UIImageView *bg=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Bk_na.png"]];
        bg.frame=CGRectMake(25, 44, 270, 175);
        [ctrlView addSubview:bg];
        
        //按钮－新建文件夹0,0
        UIButton *btnUpload= [UIButton buttonWithType:UIButtonTypeCustom];
        btnUpload.frame=CGRectMake(25, 44, 90, 87);
        [btnUpload setImage:[UIImage imageNamed:@"Bt_naUpload.png"] forState:UIControlStateNormal];
        [btnUpload setBackgroundImage:[UIImage imageNamed:@"Bk_naChecked.png"] forState:UIControlStateHighlighted];
        [btnUpload addTarget:self action:@selector(goUpload:) forControlEvents:UIControlEventTouchUpInside];
        [ctrlView addSubview:btnUpload];
        UILabel *lblNewFinder=[[[UILabel alloc] init] autorelease];
        lblNewFinder.text=@"上传";
        lblNewFinder.textAlignment=UITextAlignmentCenter;
        lblNewFinder.font=[UIFont systemFontOfSize:12];
        lblNewFinder.textColor=[UIColor whiteColor];
        lblNewFinder.backgroundColor=[UIColor clearColor];
        lblNewFinder.frame=CGRectMake(25, 59+44, 90, 21);
        [ctrlView addSubview:lblNewFinder];
        
        //按钮－编辑0,1
        UIButton *btnSearch= [UIButton buttonWithType:UIButtonTypeCustom];
        btnSearch.frame=CGRectMake(25+90, 44, 90, 87);
        [btnSearch setImage:[UIImage imageNamed:@"Bt_naSeach.png"] forState:UIControlStateNormal];
        [btnSearch setBackgroundImage:[UIImage imageNamed:@"Bk_naChecked.png"] forState:UIControlStateHighlighted];
        [btnSearch addTarget:self action:@selector(goSearch:) forControlEvents:UIControlEventTouchUpInside];
        [ctrlView addSubview:btnSearch];
        UILabel *lblNewFinder01=[[[UILabel alloc] init] autorelease];
        lblNewFinder01.text=@"搜索";
        lblNewFinder01.textAlignment=UITextAlignmentCenter;
        lblNewFinder01.font=[UIFont systemFontOfSize:12];
        lblNewFinder01.textColor=[UIColor whiteColor];
        lblNewFinder01.backgroundColor=[UIColor clearColor];
        lblNewFinder01.frame=CGRectMake(25+90, 59+44, 90, 21);
        [ctrlView addSubview:lblNewFinder01];
        
        //按钮－新建文件夹 0，2
        UIButton *btnNewFinder02= [UIButton buttonWithType:UIButtonTypeCustom];
        btnNewFinder02.frame=CGRectMake(25+(90*2), 44, 90, 87);
        [btnNewFinder02 setImage:[UIImage imageNamed:@"Bt_naNews.png"] forState:UIControlStateNormal];
        [btnNewFinder02 setBackgroundImage:[UIImage imageNamed:@"Bk_naChecked.png"] forState:UIControlStateHighlighted];
        [btnNewFinder02 addTarget:self action:@selector(goMessage:) forControlEvents:UIControlEventTouchUpInside];
        [ctrlView addSubview:btnNewFinder02];
        UILabel *lblNewFinder02=[[[UILabel alloc] init] autorelease];
        lblNewFinder02.text=@"消息";
        lblNewFinder02.textAlignment=UITextAlignmentCenter;
        lblNewFinder02.font=[UIFont systemFontOfSize:12];
        lblNewFinder02.textColor=[UIColor whiteColor];
        lblNewFinder02.backgroundColor=[UIColor clearColor];
        lblNewFinder02.frame=CGRectMake(25+(90*2), 59+44, 90, 21);
        [ctrlView addSubview:lblNewFinder02];
        
        //按钮－新建文件夹 1，0
        UIButton *btnEdit= [UIButton buttonWithType:UIButtonTypeCustom];
        btnEdit.frame=CGRectMake(25, 44+88, 90, 87);
        [btnEdit setImage:[UIImage imageNamed:@"Bt_naEdit.png"] forState:UIControlStateNormal];
        [btnEdit setBackgroundImage:[UIImage imageNamed:@"Bk_naChecked.png"] forState:UIControlStateHighlighted];
        [btnEdit addTarget:self action:@selector(editAction:) forControlEvents:UIControlEventTouchUpInside];
        [ctrlView addSubview:btnEdit];
        UILabel *lblEdit=[[[UILabel alloc] init] autorelease];
        lblEdit.tag = 2013;
        lblEdit.text=@"编辑";
        lblEdit.textAlignment=UITextAlignmentCenter;
        lblEdit.font=[UIFont systemFontOfSize:12];
        lblEdit.textColor=[UIColor whiteColor];
        lblEdit.backgroundColor=[UIColor clearColor];
        lblEdit.frame=CGRectMake(25, 59+88+44, 90, 21);
        [ctrlView addSubview:lblEdit];
        
        //按钮－新建文件夹 1，1
        UIButton *btnNewFinder= [UIButton buttonWithType:UIButtonTypeCustom];
        btnNewFinder.frame=CGRectMake(25+90, 44+88, 90, 87);
        [btnNewFinder setImage:[UIImage imageNamed:@"Bt_naCreateForlder.png"] forState:UIControlStateNormal];
        [btnNewFinder setBackgroundImage:[UIImage imageNamed:@"Bk_naChecked.png"] forState:UIControlStateHighlighted];
        [btnNewFinder addTarget:self action:@selector(newFinder:) forControlEvents:UIControlEventTouchUpInside];
        [ctrlView addSubview:btnNewFinder];
        UILabel *lblNewFinder11=[[[UILabel alloc] init] autorelease];
        lblNewFinder11.text=@"新建文件夹";
        lblNewFinder11.textAlignment=UITextAlignmentCenter;
        lblNewFinder11.font=[UIFont systemFontOfSize:12];
        lblNewFinder11.textColor=[UIColor whiteColor];
        lblNewFinder11.backgroundColor=[UIColor clearColor];
        lblNewFinder11.frame=CGRectMake(25+90, 59+88+44, 90, 21);
        [ctrlView addSubview:lblNewFinder11];
    }
    else
    {
        ctrlView.hidden = NO;
    }
}

#pragma mark 更多事件中的按钮事件
-(void)touchView:(id)sender
{
    ctrlView.hidden = YES;
}

-(void)goUpload:(id)sender
{
    
}

-(void)goSearch:(id)sender
{
    
}

-(void)goMessage:(id)sender
{
    
}

-(void)editAction:(id)sender
{
    UILabel *lblEdit = (UILabel *)[ctrlView viewWithTag:2013];
    if([lblEdit.text isEqualToString:@"编辑"])
    {
        [lblEdit setText:@"取消"];
        [file_tableView setEditing:YES animated:YES];
        [file_tableView editAction];
        MYTabBarController *myTabbar = (MYTabBarController *)[self tabBarController];
        [myTabbar setHidesTabBarWithAnimate:YES];
        if(edit_view == nil)
        {
            CGRect rect = CGRectMake(0,self.view.frame.size.height-60, 320,60);
            edit_view = [[UIView alloc] initWithFrame:rect];
            [edit_view setBackgroundColor:[UIColor colorWithRed:74/255.0f green:81/255.0f blue:88/255.0f alpha:1.0f]];
            [self.view addSubview:edit_view];
            //移动按钮
            UIButton *editBtn1=[UIButton buttonWithType:UIButtonTypeCustom];
            editBtn1.frame=CGRectMake(10, 0, 60, 60);
            [editBtn1 setImage:[UIImage imageNamed:@"Bt_ShareF.png"] forState:UIControlStateNormal];
            [editBtn1 addTarget:self action:@selector(sharedAction:) forControlEvents:UIControlEventTouchUpInside];
            [edit_view addSubview:editBtn1];
            UILabel *editLbl1=[[[UILabel alloc] init] autorelease];
            editLbl1.text=@"分享";
            editLbl1.textAlignment=UITextAlignmentCenter;
            editLbl1.font=[UIFont systemFontOfSize:12];
            editLbl1.textColor=[UIColor whiteColor];
            editLbl1.backgroundColor=[UIColor clearColor];
            editLbl1.frame=CGRectMake(19, 45-5, 42, 21);
            [edit_view addSubview:editLbl1];
            //移动按钮
            UIButton *editBtn2=[UIButton buttonWithType:UIButtonTypeCustom];
            editBtn2.frame=CGRectMake(10+80, 0, 60, 60);
            [editBtn2 setImage:[UIImage imageNamed:@"Bt_MoveF.png"] forState:UIControlStateNormal];
            [editBtn2 addTarget:self action:@selector(toMove:) forControlEvents:UIControlEventTouchUpInside];
            [edit_view addSubview:editBtn2];
            UILabel *editLbl2=[[[UILabel alloc] init] autorelease];
            editLbl2.text=@"移动";
            editLbl2.textAlignment=UITextAlignmentCenter;
            editLbl2.font=[UIFont systemFontOfSize:12];
            editLbl2.textColor=[UIColor whiteColor];
            editLbl2.backgroundColor=[UIColor clearColor];
            editLbl2.frame=CGRectMake(19+80, 45-5, 42, 21);
            [edit_view addSubview:editLbl2];
            //移动按钮
            UIButton *editBtn3=[UIButton buttonWithType:UIButtonTypeCustom];
            editBtn3.frame=CGRectMake(10+80+80, 0, 60, 60);
            [editBtn3 setImage:[UIImage imageNamed:@"Bt_AllF.png"] forState:UIControlStateNormal];
            [editBtn3 addTarget:self action:@selector(allSelect:) forControlEvents:UIControlEventTouchUpInside];
            [edit_view addSubview:editBtn3];
            UILabel *editLbl3=[[[UILabel alloc] init] autorelease];
            editLbl3.text=@"全选";
            editLbl3.textAlignment=UITextAlignmentCenter;
            editLbl3.font=[UIFont systemFontOfSize:12];
            editLbl3.textColor=[UIColor whiteColor];
            editLbl3.backgroundColor=[UIColor clearColor];
            editLbl3.frame=CGRectMake(19+80+80, 45-5, 42, 21);
            [edit_view addSubview:editLbl3];
            //移动按钮
            UIButton *editBtn4=[UIButton buttonWithType:UIButtonTypeCustom];
            editBtn4.frame=CGRectMake(10+80+80+80, 0, 60, 60);
            [editBtn4 setImage:[UIImage imageNamed:@"Bt_DelF.png"] forState:UIControlStateNormal];
            [editBtn4 addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
            [edit_view addSubview:editBtn4];
            UILabel *editLbl4=[[[UILabel alloc] init] autorelease];
            editLbl4.text=@"删除";
            editLbl4.textAlignment=UITextAlignmentCenter;
            editLbl4.font=[UIFont systemFontOfSize:12];
            editLbl4.textColor=[UIColor whiteColor];
            editLbl4.backgroundColor=[UIColor clearColor];
            editLbl4.frame=CGRectMake(19+80+80+80, 45-5, 42, 21);
            [edit_view addSubview:editLbl4];
        }
        else
        {
            [edit_view setHidden:NO];
        }
    }
    else
    {
        [lblEdit setText:@"编辑"];
        [file_tableView setEditing:NO animated:YES];
        [file_tableView escAction];
        MYTabBarController *myTabbar = (MYTabBarController *)[self tabBarController];
        [myTabbar setHidesTabBarWithAnimate:NO];
        [edit_view setHidden:YES];
    }
}

-(void)newFinder:(id)sender
{
    
}

//点击文件内容
-(void)clicked_file:(id)sender
{
    UIButton *button = sender;
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
    [button setBackgroundImage:imge forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    UIButton *file_button = (UIButton *)[self.view viewWithTag:24];
    [file_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [file_button setBackgroundImage:nil forState:UIControlStateNormal];
    
    if(isPhoto)
    {
        isPhoto = FALSE;
    }
    file_tableView.hidden = NO;
    [self showFileList];
    photo_tableView.hidden = YES;
}

#pragma mark FileTableViewDelegate -------------------

-(void)downController:(NSString *)fid
{
    IPhotoViewController *iphotoView = [[IPhotoViewController alloc] init];
    iphotoView.f_id = fid;
    iphotoView.isPhoto = isPhoto;
    iphotoView.isNeedBackButton = YES;
    [self.navigationController pushViewController:iphotoView animated:YES];
    [iphotoView release];
}

-(void)showFile:(int)index array:(NSMutableArray *)tableArray
{
    PhotoLookViewController *photoLookViewController = [[PhotoLookViewController alloc] init];
    [photoLookViewController setHidesBottomBarWhenPushed:YES];
    [photoLookViewController setCurrPage:index];
    [photoLookViewController setTableArray:tableArray];
    [self presentModalViewController:photoLookViewController animated:YES];
    [photoLookViewController release];
}

-(void)showAllFile:(NSMutableArray *)tableArray
{
    
}

-(void)showController:(NSString *)fid titleString:(NSString *)fname
{
    QBImageFileViewController *qbImage_fileView = [[QBImageFileViewController alloc] init];
    qbImage_fileView.f_id = fid;
    qbImage_fileView.f_name = fname;
    qbImage_fileView.isChangeMove = YES;
    [qbImage_fileView setQbDelegate:self];
    [self presentModalViewController:qbImage_fileView animated:YES];
    [qbImage_fileView release];
}

-(void)showEscButton:(UIView *)view
{
    escButton.hidden = NO;
    [self.view bringSubviewToFront:escButton];
    [escButton bringSubviewToFront:view];
}

-(void)hiddenEscButton:(UIView *)view
{
    escButton.hidden = YES;
}

#pragma mark QBImageFileViewDelegate ----------------

-(void)uploadFileder:(NSString *)deviceName
{
    
}

-(void)uploadFiledId:(NSString *)f_id_
{
    move_fid = f_id_;
    //移动文件
    
}

#pragma mark clickMenu

-(void)EscMenu
{
    escButton.hidden = YES;
}

#pragma mark 编辑状态

-(void)sharedAction:(id)sender
{
    
}

-(void)toMove:(id)sender
{
    
}

-(void)allSelect:(id)sender
{
    
}

-(void)deleteAction:(id)sender
{
    
}


-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)dealloc
{
    [topView release];
    [file_tableView release];
    [photo_tableView release];
    [f_id release];
    [escButton release];
    [move_fid release];
    [ctrlView release];
    [edit_view release];
    [super dealloc];
}

@end
