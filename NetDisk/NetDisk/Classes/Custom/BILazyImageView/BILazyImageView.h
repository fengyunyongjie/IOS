//
//  BILazyImageView.h
//  PagingTextScroller
//
//  Created by haodu on 11-10-17.
//  Copyright 2011 haodu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ImageIO/ImageIO.h>
#import "clientlib/SevenCBoxClient.h"
#import "Function.h"
// Enable thread safe instantiation, requires iOS 4
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_4_0
#define BI_USE_THREAD_SAFE_INITIALIZATION_NOT_AVAILABLE
#else
#define BI_USE_THREAD_SAFE_INITIALIZATION
#endif

@class BILazyImageView;

@protocol BILazyImageViewDelegate <NSObject>
@optional
- (void)lazyImageView:(BILazyImageView *)lazyImageView fileDic:(NSDictionary *)fileDic;
@end

@interface BILazyImageView : UIImageView <UIGestureRecognizerDelegate>
{
	

	/* For progressive download */
	CGImageSourceRef _imageSource;
	CGFloat _fullHeight;
	CGFloat _fullWidth;
	NSUInteger _expectedSize;
    
    BOOL shouldShowProgressiveDownload;
	
	id<BILazyImageViewDelegate> _delegate;
    
    SevenCBoxClient cBx;
    NSDictionary *m_picDic;
    
    NSTimer *t_time;
}

@property (nonatomic, retain) NSURL *url;
@property (nonatomic, assign) BOOL shouldShowProgressiveDownload;

@property (nonatomic, assign) id<BILazyImageViewDelegate> delegate;
@property (nonatomic, retain) NSDictionary *m_picDic;

- (void)cancelLoading;

@end
