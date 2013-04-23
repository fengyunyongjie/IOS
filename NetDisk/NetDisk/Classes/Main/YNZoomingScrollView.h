//
//  YNZoomingScrollView.h
//  NetDisk
//
//  Created by fengyongning on 13-4-8.
//
//

#import <UIKit/UIKit.h>
#import "MWTapDetectingImageView.h"
#import "MWTapDetectingView.h"

@interface YNZoomingScrollView : UIScrollView<UIScrollViewDelegate,MWTapDetectingImageViewDelegate,MWTapDetectingViewDelegate>
{
    id _photoBrowser;
    UIImage * oImage;   //源图
    UIImage * tImage;   //小图
    int ima_tag;
    MWTapDetectingView *_tapView; //for background taps
    MWTapDetectingImageView *_photoImageView;
    float progressValue;
    UIProgressView *progressView;
    long fileSize;
}
@property(nonatomic,assign)int imgTag;
@property(nonatomic,retain)NSDictionary *dataDic;
@property(nonatomic,assign)long fileSize;
-(id)initWithBrowser:(id)browser;
-(void)updateImage;
-(void)testDisplayImage:(NSDictionary *)datadic;
-(void)displayImage;
-(void)showOImage;
-(void)showTImage;
-(void)displayImageFailure;
-(void)setMaxMinZoomScalesForCurrentBounds;
-(void)prepareForReuse;
-(void)updateImgLoadProgress:(long)size;
@end
