//
//  NDTaskManagerViewController.h
//  NetDisk
//
//  Created by jiangwei on 13-1-7.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "NSString+SBJSON.h"
#import "NDTaskCell.h"
#include "SevenCBoxClient.h"
#import "STSegmentedControl.h"
#import "AGImagePickerController.h"
#import "AGIPCToolbarItem.h"
#import "ATMHud.h"
#import "CheckConnectionKind.h"
#define ND_SEND_UPLOADPHOTOS @"upload_photos"

@interface NDTaskManagerViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,NDTaskCellDelegate>
{
    int photoesCount;
    
    UITableView *m_tableView;
    
    SevenCBoxClient scBox;
    vector<string> paths;
    
    NSMutableArray *m_listArray_uploading;
    NSMutableArray *m_listArray_uploaded;
    NSMutableArray *m_listArray_downloading;
    NSMutableArray *m_listArray_downloaded;
    
    BOOL m_isUpload;
    STSegmentedControl *segment;
    
    NSTimer *m_timer;
    NSTimer *m_timer_upload;
    BOOL m_isContinus;
    
    UIView *m_bottom_view;
    UIButton *m_camerUploadButton;
    
    NSMutableArray *selectedPhotos;
    ATMHud *m_hud;
    NSString *m_parentFID;
    
    UIImagePickerController * imagePickerController;
}
@property (nonatomic,retain) IBOutlet UITableView *m_tableView;
@property (nonatomic,retain) IBOutlet UIView *m_bottom_view;
@property (nonatomic,retain) IBOutlet UIButton *m_camerUploadButton;

@property (nonatomic,retain) STSegmentedControl *segment;
@property (nonatomic,retain) NSMutableArray *selectedPhotos;
@property (nonatomic,retain) NSString *m_parentFID;

- (IBAction)allStart:(id)sender;
- (IBAction)allPause:(id)sender;
- (IBAction)allCancle:(id)sender;
- (IBAction)comeBack:(id)sender;

- (IBAction)uploadFromLib:(id)sender;
- (IBAction)uploadFromCamer:(id)sender;

- (void)valueChanged:(id)sender;

- (void)OnPrepare;
- (void)addListItem:(NSMutableDictionary *)taskItemStr isUpload:(bool)isUpload state:(int)state;
- (void)updateListItem:(NSMutableDictionary *)taskItemStr isUpload:(bool)isUpload;
- (void)openAction;
- (void)showImagePicker:(BOOL)hasCamera;
- (void)createPhotosFm;
- (void)uploadPhotos:(NSString *)sPID;
- (double)getFilesSize;
@end

