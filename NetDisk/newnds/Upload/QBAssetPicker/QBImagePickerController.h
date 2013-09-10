/*
 Copyright (c) 2013 Katsuma Tanaka
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

// Delegate
#import "QBAssetCollectionViewControllerDelegate.h"

typedef NS_ENUM(NSInteger, QBImagePickerFilterType) {
    QBImagePickerFilterTypeAllAssets,
    QBImagePickerFilterTypeAllPhotos,
    QBImagePickerFilterTypeAllVideos
};

@class QBImagePickerController;

@protocol QBImagePickerControllerDelegate <NSObject>

@optional
- (void)imagePickerControllerWillFinishPickingMedia:(QBImagePickerController *)imagePickerController;
- (void)imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingMediaWithInfo:(id)info;
- (void)imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController;
- (NSString *)descriptionForSelectingAllAssets:(QBImagePickerController *)imagePickerController;
- (NSString *)descriptionForDeselectingAllAssets:(QBImagePickerController *)imagePickerController;
- (NSString *)imagePickerController:(QBImagePickerController *)imagePickerController descriptionForNumberOfPhotos:(NSUInteger)numberOfPhotos;
- (NSString *)imagePickerController:(QBImagePickerController *)imagePickerController descriptionForNumberOfVideos:(NSUInteger)numberOfVideos;
- (NSString *)imagePickerController:(QBImagePickerController *)imagePickerController descriptionForNumberOfPhotos:(NSUInteger)numberOfPhotos numberOfVideos:(NSUInteger)numberOfVideos;
-(void)changeUpload:(NSMutableOrderedSet *)array_;
-(void)changeDeviceName:(NSString *)device_name;
-(void)changeFileId:(NSString *)f_id;
-(void)changeSpaceId:(NSString *)s_id;

@end

#import "SCBPhotoManager.h"

@interface QBImagePickerController : UIViewController <UITableViewDataSource, UITableViewDelegate, QBAssetCollectionViewControllerDelegate,SCBPhotoDelegate>
{
    /*
     自定义navBar
     */
    UIView *topView;
    UIView *bottonView;
    UIButton *change_myFile_button;
    BOOL isNeedBackButton;
    NSString *f_id;
    SCBPhotoManager *photoManager;
    NSString *f_name;
    NSString *space_id;
}

@property (nonatomic, retain) id<QBImagePickerControllerDelegate> delegate;
@property (nonatomic, assign) QBImagePickerFilterType filterType;
@property (nonatomic, assign) BOOL showsCancelButton;
@property (nonatomic, assign) BOOL fullScreenLayoutEnabled;

@property (nonatomic, assign) BOOL allowsMultipleSelection;
@property (nonatomic, assign) BOOL limitsMinimumNumberOfSelection;
@property (nonatomic, assign) BOOL limitsMaximumNumberOfSelection;
@property (nonatomic, assign) NSUInteger minimumNumberOfSelection;
@property (nonatomic, assign) NSUInteger maximumNumberOfSelection;

@property (nonatomic,retain) SCBPhotoManager *photoManager;
@property (nonatomic,retain) NSString *f_id;
@property (nonatomic,retain) NSString *f_name;
@property (nonatomic,retain) NSString *space_id;

-(void)requestFileDetail;

@end


