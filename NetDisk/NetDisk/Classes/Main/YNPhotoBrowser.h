//
//  YNPhotoBrowser.h
//  NetDisk
//
//  Created by fengyongning on 13-4-8.
//
//

#import <UIKit/UIKit.h>

@class MWPhotoBrowser;
@protocol MWPhotoBrowserDelegate <NSObject>
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser;
//- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index;
@optional
//- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index;
@end

@interface YNPhotoBrowser : UIViewController<UIScrollViewDelegate>

@end
