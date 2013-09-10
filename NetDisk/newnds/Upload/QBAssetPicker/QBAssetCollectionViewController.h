/*
 Copyright (c) 2013 Katsuma Tanaka
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>

// Delegate
#import "QBAssetCollectionViewControllerDelegate.h"
#import "QBImagePickerAssetCellDelegate.h"

// Controllers
#import "QBImagePickerController.h"
#import "SCBPhotoManager.h"
#import "QBImageFileViewController.h"

@interface QBAssetCollectionViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, QBImagePickerAssetCellDelegate,NewFoldDelegate,QBImageFileViewDelegate>
{
    /*
     自定义navBar
     */
    UIView *topView;
    UIView *bottonView;
    UIButton *change_myFile_button;
    BOOL isNeedBackButton;
    SCBPhotoManager *photoManger;
    NSArray *fileArray;
    BOOL isFirst;
    NSString *device_name;
    NSString *f_id;
    NSString *space_id;
}

@property (nonatomic, retain) id<QBAssetCollectionViewControllerDelegate> delegate;
@property (nonatomic, strong) ALAssetsGroup *assetsGroup;

@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, assign) QBImagePickerFilterType filterType;
@property (nonatomic, assign) BOOL showsCancelButton;
@property (nonatomic, assign) BOOL fullScreenLayoutEnabled;
@property (nonatomic, assign) BOOL showsHeaderButton;
@property (nonatomic, assign) BOOL showsFooterDescription;

@property (nonatomic, assign) BOOL allowsMultipleSelection;
@property (nonatomic, assign) BOOL limitsMinimumNumberOfSelection;
@property (nonatomic, assign) BOOL limitsMaximumNumberOfSelection;
@property (nonatomic, assign) NSUInteger minimumNumberOfSelection;
@property (nonatomic, assign) NSUInteger maximumNumberOfSelection;

@property (nonatomic, assign) BOOL isNeedBackButton;
@property (nonatomic, assign) NSString *device_name;
@property (nonatomic, retain) NSString *f_id;
@property (nonatomic, retain) NSString *space_id;

@end
