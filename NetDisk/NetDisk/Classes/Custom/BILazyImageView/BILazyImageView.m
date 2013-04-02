//
//  BILazyImageView.m
//  PagingTextScroller
//
//  Created by haodu on 11-10-17.
//  Copyright 2011 haodu. All rights reserved.
//

#import "BILazyImageView.h"

#ifndef BI_USE_THREAD_SAFE_INITIALIZATION
#ifndef BI_USE_THREAD_SAFE_INITIALIZATION_NOT_AVAILABLE
#warning Thread safe initialization is not enabled.
#endif
#endif

void callBackThumbFileFunc(Value &jsonValue,void *s_pv);

@implementation BILazyImageView
@synthesize delegate=_delegate;
@synthesize m_picDic;
- (id)init
{
	if((self = [super init]) != nil) {
		self.shouldShowProgressiveDownload = YES;
	}
	return self;
}

- (void)dealloc
{
    if ([t_time isValid]) {
        [t_time invalidate];
    }
    
    
	self.image = nil;
	[m_picDic release];
    
	
	[super dealloc];
}
/*
- (void)loadImageAtURL:(NSURL *)url
{
	if ([NSThread isMainThread])
	{
		[self performSelectorInBackground:@selector(loadImageAtURL:) withObject:url];
		return;
	}
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10.0];

    
    string f_id = [[m_picDic objectForKey:@"f_id"] cStringUsingEncoding:NSUTF8StringEncoding];
    NSString *picName = [m_picDic objectForKey:@"compressaddr"];
    NSString *picPath = [NSString stringWithFormat:@"%@%@",[Function getTempCachePath],picName];
    cBx.FmDownloadThumbFile(f_id,[picPath cStringUsingEncoding:NSUTF8StringEncoding],NULL,NULL);
    
	
	CFRunLoopRun();
	
	[request release];
	
	[pool drain];
}
 */
- (void)setM_picDic:(NSDictionary *)picDic
{
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTap.delegate = self;
    singleTap.cancelsTouchesInView = NO;
    [self addGestureRecognizer:singleTap];
    [singleTap release];
    
    m_picDic = picDic;
    NSNumber *daf =[m_picDic objectForKey:@"f_id"];
    string f_id = [[Function covertNumberToString:daf] cStringUsingEncoding:NSUTF8StringEncoding];
    NSString *picName = [Function picFileNameFromURL:[m_picDic objectForKey:@"compressaddr"]];
    NSString *picPath = [NSString stringWithFormat:@"%@/%@",[Function getTempCachePath],picName];

    UIImage *image = [UIImage imageWithContentsOfFile:picPath];
    if (image) {
        self.image = image;
        return;
    }
    else{
    /*  
        //取大图作为缩略图显示，但是太慢了。
        NSString *f_name = [m_picDic objectForKey:@"f_name"];
        NSString *picPath=[[Function getImgCachePath] stringByAppendingPathComponent:f_name];
        UIImage *image = [UIImage imageWithContentsOfFile:picPath];
        if (image) {
            self.image = image;
            return;
        }
     */
    }
    self.image = [UIImage imageNamed:@"icon_pic"];
    
    [self performSelector:@selector(downloadPhotoByTask) withObject:nil afterDelay:0.1f];
 //   [self performSelectorInBackground:@selector(downloadPhotoByTask) withObject:nil];

    NSTimeInterval timeInterval =1.3f ;
    t_time  = [NSTimer scheduledTimerWithTimeInterval:timeInterval 
                                               target:self
                                             selector:@selector(researchImage)
                                             userInfo:nil 
                                              repeats:YES];
    
}
- (void)downloadPhotoByTask
{
    NSNumber *daf =[m_picDic objectForKey:@"f_id"];
    string f_id = [[Function covertNumberToString:daf] cStringUsingEncoding:NSUTF8StringEncoding];
    NSString *picName = [Function picFileNameFromURL:[m_picDic objectForKey:@"compressaddr"]];
    NSString *picPath = [NSString stringWithFormat:@"%@/%@",[Function getTempCachePath],picName];
    cBx.FmDownloadThumbFile(f_id,[picPath cStringUsingEncoding:NSUTF8StringEncoding],callBackThumbFileFunc,self);
}
#pragma mark -
#pragma mark CallBack Funtion
void callBackThumbFileFunc(Value &jsonValue,void *s_pv)
{
    int a = jsonValue["code"].asInt();
    string vall = jsonValue.toStyledString().c_str();
    NSString *vallStr = [NSString stringWithCString:vall.c_str() encoding:NSUTF8StringEncoding];
    //[s_pv showMyView:vallStr];
}
- (void)researchImage
{
    NSString *picName = [self.m_picDic objectForKey:@"compressaddr"];
    NSString *picPath = [NSString stringWithFormat:@"%@%@",[Function getTempCachePath],picName];
    
    UIImage *image = [UIImage imageWithContentsOfFile:picPath];
    if (image) {
        self.image = image;
        [t_time invalidate];
        return;
    }
}

- (void)didMoveToSuperview
{
	[super didMoveToSuperview];
}


#pragma mark NSURL Loading

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer 
{ 
	
	if ([self.delegate respondsToSelector:@selector(lazyImageView:fileDic:)]) {
		[self.delegate lazyImageView:self fileDic:self.m_picDic];
	}

}


#pragma mark Properties

@synthesize url = _url;
@synthesize shouldShowProgressiveDownload;

@end
