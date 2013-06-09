//
//  PhotoLookViewController.m
//  NetDisk
//
//  Created by Yangsl on 13-6-5.
//
//

#import "PhotoLookViewController.h"
#import "PhotoFile.h"
#import "YNFunctions.h"
#import "FavoritesData.h"
#import "AppDelegate.h"

#define ACTNUMBER 100000
#define ImageViewTag 200000
@interface PhotoLookViewController ()
@property float scale_;
@end

@implementation PhotoLookViewController
@synthesize imageScrollView;
@synthesize scale_,tableArray;
@synthesize currPage;
@synthesize isCliped;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillDisappear:(BOOL)animated
{
    for(int i=0;i<[downArray count];i++)
    {
        DownImage *downImage = [downArray objectAtIndex:i];
        [downImage setDelegate:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    imageDic = [[NSMutableDictionary alloc] init];
    activityDic = [[NSMutableDictionary alloc] init];
    downArray = [[NSMutableArray alloc] init];
    
    scollviewHeight = self.view.frame.size.height;
    self.view.backgroundColor = [UIColor blackColor];
    offset = 0.0;
    scale_ = 1.0;
    
    self.imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, scollviewHeight)];
    self.imageScrollView.backgroundColor = [UIColor clearColor];
    self.imageScrollView.scrollEnabled = YES;
    self.imageScrollView.pagingEnabled = YES;
    self.imageScrollView.showsHorizontalScrollIndicator = NO;
    self.imageScrollView.delegate = self;
    self.imageScrollView.contentSize = CGSizeMake(320*[tableArray count], scollviewHeight);
    
    if(currPage==0&&[tableArray count]>=3)
    {
        startPage = 0;
        endPage = currPage+2;
        for (int i = 0; i<currPage+3; i++){
            PhotoFile *demo = [tableArray objectAtIndex:i];
            if([[imageDic objectForKey:[NSString stringWithFormat:@"%i",demo.f_id]] isKindOfClass:[PhotoFile class]])
            {
                continue;
            }
            [self loadPageColoumn:i];
        }
    }
    
    if(currPage==0&&[tableArray count]<=3)
    {
        startPage = 0;
        endPage = [tableArray count]-1;
        for (int i = 0; i<[tableArray count]; i++){
            PhotoFile *demo = [tableArray objectAtIndex:i];
            if([[imageDic objectForKey:[NSString stringWithFormat:@"%i",demo.f_id]] isKindOfClass:[PhotoFile class]])
            {
                continue;
            }
            [self loadPageColoumn:i];
        }
    }
    
    if(currPage>0&&currPage+1<[tableArray count])
    {
        startPage = currPage-1;
        endPage = currPage+1;
        for (int i = currPage-1; i<currPage+2; i++){
            PhotoFile *demo = [tableArray objectAtIndex:i];
            if([[imageDic objectForKey:[NSString stringWithFormat:@"%i",demo.f_id]] isKindOfClass:[PhotoFile class]])
            {
                continue;
            }
            [self loadPageColoumn:i];
        }
    }
    
    if(currPage+1==[tableArray count] && [tableArray count]>=3)
    {
        startPage = currPage-3;
        endPage = currPage-1;
        for (int i = currPage-3; i<=currPage; i++){
            PhotoFile *demo = [tableArray objectAtIndex:i];
            if([[imageDic objectForKey:[NSString stringWithFormat:@"%i",demo.f_id]] isKindOfClass:[PhotoFile class]])
            {
                continue;
            }
            
            [self loadPageColoumn:i];
        }
    }
    
    if(currPage+1==[tableArray count] && [tableArray count]<3)
    {
        startPage = 0;
        endPage = currPage-1;
        for (int i = 0; i<=currPage; i++){
            PhotoFile *demo = [tableArray objectAtIndex:i];
            if([[imageDic objectForKey:[NSString stringWithFormat:@"%i",demo.f_id]] isKindOfClass:[PhotoFile class]])
            {
                continue;
            }
            
            [self loadPageColoumn:i];
        }
    }
    
    [self.imageScrollView setContentOffset:CGPointMake(320*currPage, 0) animated:NO];
    NSLog(@"320*currPage:%i",320*currPage);
    [self.view addSubview:self.imageScrollView];
    
    
    //添加底部试图
    CGRect bottonRect = CGRectMake(0, scollviewHeight-44, 320, 44);
    bottonToolBar = [[UIToolbar alloc] initWithFrame:bottonRect];
    [bottonToolBar setBarStyle:UIBarStyleBlackTranslucent];
    
    
    CGRect leftRect = CGRectMake(36, 5, 35, 33);
    leftButton = [[UIButton alloc] initWithFrame:leftRect];
    [leftButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [leftButton.titleLabel setTextColor:[UIColor blackColor]];
    [leftButton addTarget:self action:@selector(clipClicked:) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setTitle:@"收藏" forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftButton setBackgroundColor:[UIColor clearColor]];
    [bottonToolBar addSubview:leftButton];
    leftButton.showsTouchWhenHighlighted = YES;
    
    CGRect centerRect = CGRectMake(107+36, 5, 35, 33);
    centerButton = [[UIButton alloc] initWithFrame:centerRect];
    [centerButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [centerButton.titleLabel setTextColor:[UIColor blackColor]];
    [centerButton addTarget:self action:@selector(shareClicked:) forControlEvents:UIControlEventTouchUpInside];
    [centerButton setTitle:@"分享" forState:UIControlStateNormal];
    [centerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [centerButton setBackgroundColor:[UIColor clearColor]];
    [bottonToolBar addSubview:centerButton];
    centerButton.showsTouchWhenHighlighted = YES;
    
    CGRect rightRect = CGRectMake(213+36, 5, 35, 33);
    rightButton = [[UIButton alloc] initWithFrame:rightRect];
    [rightButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [rightButton.titleLabel setTextColor:[UIColor blackColor]];
    [rightButton addTarget:self action:@selector(deleteClicked:) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setTitle:@"删除" forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightButton setBackgroundColor:[UIColor clearColor]];
    rightButton.showsTouchWhenHighlighted = YES;
    [bottonToolBar addSubview:rightButton];
    
    [self.view addSubview:bottonToolBar];
    
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    [self.navigationController setNavigationBarHidden:YES];
    [bottonToolBar setHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)changeCenter:(id)sender{
    
}

#pragma mark - ScrollView delegate
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    
    for (UIView *v in scrollView.subviews){
        return v;
    }
    return nil;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    //加载当前页面，左右各十张
    isLoadImage = TRUE;
    [NSThread detachNewThreadSelector:@selector(loadImage) toTarget:self withObject:nil];
    
    if (scrollView == self.imageScrollView){
        CGFloat x = scrollView.contentOffset.x;
        if (x==offset){
            
        }
        else {
            offset = x;
            for (UIScrollView *s in scrollView.subviews){
                if ([s isKindOfClass:[UIScrollView class]]){
                    [s setZoomScale:1.0];
                    UIImageView *image = [[s subviews] objectAtIndex:0];
                    image.frame = CGRectMake(0, 0, 320, scollviewHeight);
                }
            }
        }
    }
}

#pragma mark 滑动隐藏
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    isLoadImage = FALSE;
    [self.navigationController setNavigationBarHidden:YES];
    [bottonToolBar setHidden:YES];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    NSLog(@"Did zoom!");
    UIView *v = [scrollView.subviews objectAtIndex:0];
    if ([v isKindOfClass:[UIImageView class]]){
        if (scrollView.zoomScale<1.0){
//         v.center = CGPointMake(scrollView.frame.size.width/2.0, scrollView.frame.size.height/2.0);
        }
    }
}

#pragma mark 加载符
-(void)loadActivity
{
    //加载数据
    int page = imageScrollView.contentOffset.x/320;
    PhotoFile *demo = [tableArray objectAtIndex:page];
    if(![[imageDic objectForKey:[NSString stringWithFormat:@"%i",demo.f_id]] isKindOfClass:[PhotoFile class]] && ![[activityDic objectForKey:[NSString stringWithFormat:@"%i",demo.f_id]] isKindOfClass:[PhotoFile class]])
    {
        CGRect activityRect = CGRectMake(320*(page-1)+(320-20)/2, (scollviewHeight-20)/2, 20, 20);
        UIActivityIndicatorView *activity_indicator = [[[UIActivityIndicatorView alloc] initWithFrame:activityRect] autorelease];
        [activity_indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
        [activity_indicator startAnimating];
        [activity_indicator setTag:ACTNUMBER+page];
        [imageScrollView addSubview:activity_indicator];
        [activityDic setObject:demo forKey:[NSString stringWithFormat:@"%i",demo.f_id]];
    }
}

#pragma mark 加载数据
-(void)loadImage
{
    //加载数据
    int page = imageScrollView.contentOffset.x/320;
    //判断是否加载图片
    if(page-5>=0)
    {
        for(int i=page-1;isLoadImage&&i>page-5;i--)
        {
            PhotoFile *demo = [tableArray objectAtIndex:i];
            if([[imageDic objectForKey:[NSString stringWithFormat:@"%i",demo.f_id]] isKindOfClass:[PhotoFile class]])
            {
                continue;
            }
            [self loadPageColoumn:i];
        }
    }
    else
    {
        for(int i=page-1;isLoadImage&&i>0;i--)
        {
            PhotoFile *demo = [tableArray objectAtIndex:i];
            if([[imageDic objectForKey:[NSString stringWithFormat:@"%i",demo.f_id]] isKindOfClass:[PhotoFile class]])
            {
                continue;
            }
            
            [self loadPageColoumn:i];
        }
    }
    
    if(page+5<=[tableArray count])
    {
        for(int i=page;isLoadImage&&i<page+5;i++)
        {
            PhotoFile *demo = [tableArray objectAtIndex:i];
            if([[imageDic objectForKey:[NSString stringWithFormat:@"%i",demo.f_id]] isKindOfClass:[PhotoFile class]])
            {
                continue;
            }
            
            [self loadPageColoumn:i];
        }
    }
    else
    {
        for(int i=page;isLoadImage&&i<[tableArray count];i++)
        {
            PhotoFile *demo = [tableArray objectAtIndex:i];
            if([[imageDic objectForKey:[NSString stringWithFormat:@"%i",demo.f_id]] isKindOfClass:[PhotoFile class]])
            {
                continue;
            }
            
            [self loadPageColoumn:i];
        }
    }
}

-(void)loadPageColoumn:(int)i
{
    PhotoFile *demo = [tableArray objectAtIndex:i];
    UITapGestureRecognizer *doubleTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    UITapGestureRecognizer *onceTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleOnceTap:)];
    [onceTap setNumberOfTapsRequired:1];
    
    UIScrollView *s = [[UIScrollView alloc] initWithFrame:CGRectMake(320*i, 0, 320, scollviewHeight)];
    s.backgroundColor = [UIColor clearColor];
    s.contentSize = CGSizeMake(320, scollviewHeight);
    s.showsHorizontalScrollIndicator = NO;
    s.showsVerticalScrollIndicator = NO;
    s.delegate = self;
    s.minimumZoomScale = 1.0;
    s.maximumZoomScale = 3.0;
    s.tag = i+1;
    [s setZoomScale:1.0];
    
    UIImageView *imageview = [[UIImageView alloc] init];
    imageview.frame = CGRectMake(0, 0, 320, scollviewHeight);
    imageview.userInteractionEnabled = YES;
    imageview.tag = ImageViewTag+i;
    [imageview addGestureRecognizer:doubleTap];
    [s addSubview:imageview];
    
    [s addGestureRecognizer:onceTap];
    [s setBounces:YES];
    
    if([self image_exists_at_file_path:[NSString stringWithFormat:@"%iT",demo.f_id]])
    {
        NSString *path = [self get_image_save_file_path:[NSString stringWithFormat:@"%iT",demo.f_id]];
        imageview.image = [UIImage imageWithContentsOfFile:path];
    }
    else
    {
        NSString *path = [self get_image_save_file_path:[NSString stringWithFormat:@"%i",demo.f_id]];
        imageview.image = [UIImage imageWithContentsOfFile:path];
        dispatch_async(dispatch_get_main_queue(), ^{
            DownImage *downImage = [[[DownImage alloc] init] autorelease];
            [downImage setFileId:demo.f_id];
            [downImage setImageUrl:[NSString stringWithFormat:@"%iT",demo.f_id]];
            [downImage setImageViewIndex:ImageViewTag+i];
            [downImage setIndex:ACTNUMBER+i];
            [downImage setShowType:1];
            [downImage setDelegate:self];
            [downImage startDownload];
            [downArray addObject:downImage];
        });
    }
    [imageview setContentMode:UIViewContentModeScaleAspectFit];
    [self.imageScrollView addSubview:s];
    [imageDic setObject:demo forKey:[NSString stringWithFormat:@"%i",demo.f_id]];
    [onceTap release];
    [doubleTap release];
    [imageview release];
    [s release];
}

-(void)notImagePath
{
    CGRect activityRect = CGRectMake((320-20)/2, (scollviewHeight-20)/2, 20, 20);
    UIActivityIndicatorView *activity_indicator = [[UIActivityIndicatorView alloc] initWithFrame:activityRect];
    [activity_indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [activity_indicator startAnimating];
    [self.view addSubview:activity_indicator];
}


#pragma mark -
-(void)handleDoubleTap:(UIGestureRecognizer *)gesture{
    NSLog(@"handleDoubleTap");
    float newScale = 0;
    if(!isDoubleClick)
    {
        isDoubleClick = TRUE;
        newScale = [(UIScrollView*)gesture.view.superview zoomScale] * 3.0;
    }
    else
    {
        isDoubleClick = FALSE;
    }
    CGRect zoomRect = [self zoomRectForScale:newScale  inView:(UIScrollView*)gesture.view.superview withCenter:[gesture locationInView:gesture.view]];
    UIView *view = gesture.view.superview;
    if ([view isKindOfClass:[UIScrollView class]]){
        UIScrollView *s = (UIScrollView *)view;
        [s zoomToRect:zoomRect animated:YES];
    }
}

-(void)handleOnceTap:(UIGestureRecognizer *)gesture{
    int page = imageScrollView.contentOffset.x/320;
    //单击头部和底部出现
    if(bottonToolBar.hidden)
    {
        self.navigationItem.title = [NSString stringWithFormat:@"%i/%i",page+1,[tableArray count]];
        [self.navigationController setNavigationBarHidden:NO];
        [bottonToolBar setHidden:NO];
        if([[tableArray objectAtIndex:page] isKindOfClass:[PhotoFile class]])
        {
          PhotoFile *demo = [tableArray objectAtIndex:page];
            NSString *f_id = [NSString stringWithFormat:@"%i",demo.f_id];
            if ([[FavoritesData sharedFavoritesData] isExistsWithFID:f_id]) {
                [self isHiddenDelete:YES];
            }
            else
            {
                [self isHiddenDelete:NO];
            }
        }
    }
    else
    {
        [self.navigationController setNavigationBarHidden:YES];
        [bottonToolBar setHidden:YES];
    }
}

#pragma mark - Utility methods

-(CGRect)zoomRectForScale:(float)scale inView:(UIScrollView*)scrollView withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    zoomRect.size.height = [scrollView frame].size.height / scale;
    zoomRect.size.width  = [scrollView frame].size.width  / scale;
    
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

-(CGRect)resizeImageSize:(CGRect)rect{
    //    NSLog(@"x:%f y:%f width:%f height:%f ", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    CGRect newRect;
    
    CGSize newSize;
    CGPoint newOri;
    
    CGSize oldSize = rect.size;
    if (oldSize.width>=320.0 || oldSize.height>=scollviewHeight){
        float scale = (oldSize.width/320.0>oldSize.height/scollviewHeight?oldSize.width/320.0:oldSize.height/scollviewHeight);
        newSize.width = oldSize.width/scale;
        newSize.height = oldSize.height/scale;
    }
    else {
        newSize = oldSize;
    }
    newOri.x = (320.0-newSize.width)/2.0;
    newOri.y = (scollviewHeight-newSize.height)/2.0;
    
    newRect.size = newSize;
    newRect.origin = newOri;
    
    return newRect;
}

#pragma mark  这个路径下是否存在此图片
- (BOOL)image_exists_at_file_path:(NSString *)image_path
{
    NSFileManager *file_manager = [NSFileManager defaultManager];
    NSString *documentDir = [YNFunctions getProviewCachePath];
    NSArray *array=[image_path componentsSeparatedByString:@"/"];
    NSString *path=[NSString stringWithFormat:@"%@/%@",documentDir,[array lastObject]];
    return [file_manager fileExistsAtPath:path];
}

#pragma mark  获取图片路径
- (NSString*)get_image_save_file_path:(NSString*)image_path
{
    NSString *documentDir = [YNFunctions getProviewCachePath];
    NSArray *array=[image_path componentsSeparatedByString:@"/"];
    NSString *path=[NSString stringWithFormat:@"%@/%@",documentDir,[array lastObject]];
    return path;
}

-(void)isHiddenDelete:(BOOL)bl
{
    if(bl)
    {
        CGRect leftRect = CGRectMake((160-100)/2, 5, 100, 33);
        [leftButton setTitle:@"取消收藏" forState:UIControlStateNormal];
        [leftButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [leftButton setFrame:leftRect];
        CGRect centerRect = CGRectMake(160+(160-35)/2, 5, 35, 33);
        [centerButton setFrame:centerRect];
        [rightButton setHidden:YES];
    }
    else
    {
        CGRect leftRect = CGRectMake(36, 5, 35, 33);
        [leftButton setTitle:@"收藏" forState:UIControlStateNormal];
        [leftButton setFrame:leftRect];
        CGRect centerRect = CGRectMake(107+36, 5, 35, 33);
        [centerButton setFrame:centerRect];
        [rightButton setHidden:NO];
        if(isCliped)
        {
            CGRect leftRect = CGRectMake((160-100)/2, 5, 100, 33);
            [leftButton setTitle:@"收藏" forState:UIControlStateNormal];
            [leftButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
            [leftButton setFrame:leftRect];
            CGRect centerRect = CGRectMake(160+(160-35)/2, 5, 35, 33);
            [centerButton setFrame:centerRect];
            [rightButton setHidden:YES];
        }
    }
}

#pragma mark 收藏按钮事件
-(void)clipClicked:(id)sender
{
    int page = [[[self.navigationItem.title componentsSeparatedByString:@"/"] objectAtIndex:0] intValue]-1;
    PhotoFile *demo = nil;
    if([[tableArray objectAtIndex:page] isKindOfClass:[PhotoFile class]])
    {
        demo = [tableArray objectAtIndex:page];
    }
    NSString *f_id = [NSString stringWithFormat:@"%i",demo.f_id];
    if ([[FavoritesData sharedFavoritesData] isExistsWithFID:f_id]) {
        [[FavoritesData sharedFavoritesData] removeObjectForKey:f_id];
        hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
        hud.labelText=@"取消收藏成功";
        hud.mode=MBProgressHUDModeText;
        [hud show:YES];
        [hud hide:YES afterDelay:0.8f];
        [hud release];
        hud = nil;
        if(!isCliped)
        {
            [self isHiddenDelete:NO];
        }
        else
        {
            [leftButton setTitle:@"收藏" forState:UIControlStateNormal];
        }
    }
    else
    {
        //收藏
        /*
         请求详细数据
         */
        SCBPhotoManager *photoManager = [[[SCBPhotoManager alloc] init] autorelease];
        [photoManager setPhotoDelegate:self];
        [photoManager getDetail:demo.f_id];
    }
}

#pragma mark 分享按钮事件
-(void)shareClicked:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"分享到" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"微信朋友圈" otherButtonTitles:@"微信好友", nil];
    [actionSheet showInView:self.view];
    [actionSheet release];
}

#pragma mark UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    int page = [[[self.navigationItem.title componentsSeparatedByString:@"/"] objectAtIndex:0] intValue]-1;
    PhotoFile *demo = nil;
    if([[tableArray objectAtIndex:page] isKindOfClass:[PhotoFile class]])
    {
        demo = [tableArray objectAtIndex:page];
    }
    if(buttonIndex == 0)
    {
        if([app_delegate respondsToSelector:@selector(sendImageContentIsFiends:path:)])
        {
            //微信朋友圈
            [app_delegate sendImageContentIsFiends:YES path:[NSString stringWithFormat:@"%iT",demo.f_id]];
        }
    }
    if(buttonIndex == 1)
    {
        if([app_delegate respondsToSelector:@selector(sendImageContentIsFiends:path:)])
        {
            //微信好友
            [app_delegate sendImageContentIsFiends:NO path:[NSString stringWithFormat:@"%iT",demo.f_id]];
        }
    }
    if(buttonIndex == 2)
    {
        //新浪微博
        //        [app_delegate ssoButtonPressed];
    }
    if(buttonIndex == 3)
    {
        
        
    }
}

#pragma mark 删除按钮事件
-(void)deleteClicked:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否要删除图片" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
    [alertView release];
}

#pragma mark UIAalertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        int page = [[[self.navigationItem.title componentsSeparatedByString:@"/"] objectAtIndex:0] intValue]-1;
        deletePage = page;
        PhotoFile *demo = nil;
        if([[tableArray objectAtIndex:page] isKindOfClass:[PhotoFile class]])
        {
            demo = [tableArray objectAtIndex:page];
        }
        SCBPhotoManager *photoManager = [[[SCBPhotoManager alloc] init] autorelease];
        [photoManager setPhotoDelegate:self];
        NSArray *array = [NSArray arrayWithObject:[NSString stringWithFormat:@"%i",demo.f_id]];
        [photoManager requestDeletePhoto:array];
        
        hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
        hud.mode=MBProgressHUDModeIndeterminate;
        hud.labelText=@"正在删除";
        [hud show:YES];
    }
}


#pragma mark SCBPhotoDelegate
-(void)requstDelete:(NSDictionary *)dictioinary
{
    if([[dictioinary objectForKey:@"code"] intValue] == 0)
    {
        /*
         重新添加数据
         */
        if(self.imageScrollView)
        {
            [self.imageScrollView removeFromSuperview];
            [self.imageScrollView release];
            [imageDic removeAllObjects];
            [activityDic removeAllObjects];
        }
        
        [tableArray removeObjectAtIndex:deletePage];
        
        if([tableArray count]==0)
        {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        
        offset = 0.0;
        scale_ = 1.0;
        if(deletePage==[tableArray count])
        {
            currPage = deletePage-1;
        }
        self.imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, scollviewHeight)];
        self.imageScrollView.backgroundColor = [UIColor clearColor];
        self.imageScrollView.scrollEnabled = YES;
        self.imageScrollView.pagingEnabled = YES;
        self.imageScrollView.showsHorizontalScrollIndicator = NO;
        self.imageScrollView.delegate = self;
        
        
        if(currPage==0&&[tableArray count]>=3)
        {
            startPage = 0;
            endPage = currPage+2;
            for (int i = 0; i<currPage+3; i++){
                PhotoFile *demo = [tableArray objectAtIndex:i];
                if([[imageDic objectForKey:[NSString stringWithFormat:@"%i",demo.f_id]] isKindOfClass:[PhotoFile class]])
                {
                    continue;
                }
                [self loadPageColoumn:i];
            }
        }
        
        if(currPage==0&&[tableArray count]<=3)
        {
            startPage = 0;
            endPage = [tableArray count]-1;
            for (int i = 0; i<[tableArray count]; i++){
                PhotoFile *demo = [tableArray objectAtIndex:i];
                if([[imageDic objectForKey:[NSString stringWithFormat:@"%i",demo.f_id]] isKindOfClass:[PhotoFile class]])
                {
                    continue;
                }
                [self loadPageColoumn:i];
            }
        }
        
        if(currPage>0&&currPage+1<[tableArray count])
        {
            startPage = currPage-1;
            endPage = currPage+1;
            for (int i = currPage-1; i<currPage+2; i++){
                PhotoFile *demo = [tableArray objectAtIndex:i];
                if([[imageDic objectForKey:[NSString stringWithFormat:@"%i",demo.f_id]] isKindOfClass:[PhotoFile class]])
                {
                    continue;
                }
                [self loadPageColoumn:i];
            }
        }
        
        if(currPage+1==[tableArray count] && [tableArray count]>=3)
        {
            startPage = currPage-3;
            endPage = currPage-1;
            for (int i = currPage-3; i<=currPage; i++){
                PhotoFile *demo = [tableArray objectAtIndex:i];
                if([[imageDic objectForKey:[NSString stringWithFormat:@"%i",demo.f_id]] isKindOfClass:[PhotoFile class]])
                {
                    continue;
                }
                
                [self loadPageColoumn:i];
            }
        }
        
        if(currPage+1==[tableArray count] && [tableArray count]<3)
        {
            startPage = 0;
            endPage = currPage-1;
            for (int i = 0; i<=currPage; i++){
                PhotoFile *demo = [tableArray objectAtIndex:i];
                if([[imageDic objectForKey:[NSString stringWithFormat:@"%i",demo.f_id]] isKindOfClass:[PhotoFile class]])
                {
                    continue;
                }
                
                [self loadPageColoumn:i];
            }
        }
        
        [self.view addSubview:self.imageScrollView];
//        [self.view bringSubviewToFront:self.navigationController.navigationBar];
        [self.view bringSubviewToFront:bottonToolBar];
        
        self.imageScrollView.contentSize = CGSizeMake(320*[tableArray count], scollviewHeight);
        [self.imageScrollView setContentOffset:CGPointMake(320*currPage, 0) animated:NO];
        [self handleOnceTap:nil];
        
        hud.labelText=@"删除成功";
        hud.mode=MBProgressHUDModeText;
        [hud hide:YES afterDelay:0.8f];
        [hud release];
        hud = nil;
    }
    else
    {
        hud.labelText=@"删除失败";
        hud.mode=MBProgressHUDModeText;
        [hud hide:YES afterDelay:0.8f];
        [hud release];
        hud = nil;
    }
}

-(void)getFileDetail:(NSDictionary *)dictionary
{
    NSLog(@"dictionary:%@",dictionary);
    if([[dictionary objectForKey:@"code"] intValue] == 0)
    {
        /*
         得到数据后，添加到收藏
         */
        NSDictionary *dic = [[dictionary objectForKey:@"files"] objectAtIndex:0];
        NSString *f_id = [dic objectForKey:@"f_id"];
        [[FavoritesData sharedFavoritesData] setObject:dic forKey:f_id];
        NSLog(@"增加一个收藏，收藏总数: %d",[[FavoritesData sharedFavoritesData] count]);
        hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
        hud.labelText=@"收藏成功";
        hud.mode=MBProgressHUDModeText;
        [hud show:YES];
        [hud hide:YES afterDelay:0.8f];
        [hud release];
        hud = nil;
        [self isHiddenDelete:YES];
    }
    else
    {
        hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
        hud.labelText=@"收藏失败";
        hud.mode=MBProgressHUDModeText;
        [hud show:YES];
        [hud hide:YES afterDelay:0.8f];
        [hud release];
        hud = nil;
    }
    
}

#pragma mark 下载回调
-(void)appImageDidLoad:(NSInteger)indexTag urlImage:(UIImage *)image index:(int)index
{
     if([[imageScrollView viewWithTag:indexTag] isKindOfClass:[UIImageView class]])
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             UIImageView *imageV = (UIImageView *)[imageScrollView viewWithTag:indexTag];
             [imageV setImage:image];
             [imageV setContentMode:UIViewContentModeScaleAspectFit];
         });
     }
}

@end
