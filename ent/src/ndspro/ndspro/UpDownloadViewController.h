//
//  UpDownloadViewController.h
//  ndspro
//
//  Created by fengyongning on 13-9-29.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomSelectButton.h"
#import "UploadViewCell.h"
#import "QBImagePickerController.h"

@interface UpDownloadViewController : UIViewController<CustomSelectButtonDelegate,UITableViewDelegate,UITableViewDataSource,UploadViewCellDelegate,QBImagePickerControllerDelegate,UIActionSheetDelegate>

@property(strong,nonatomic) UITableView *table_view;
@property(strong,nonatomic) NSMutableArray *upLoading_array;
@property(strong,nonatomic) NSMutableArray *upLoaded_array;
@property(strong,nonatomic) NSMutableArray *downLoading_array;
@property(strong,nonatomic) NSMutableArray *downLoaded_array;
@property(assign,nonatomic) BOOL isShowUpload;
@property(strong,nonatomic) NSObject *deleteObject;

@property(strong,nonatomic) CustomSelectButton *customSelectButton;

-(void)isSelectedLeft:(BOOL)bl;
-(void)updateCount:(NSString *)upload_count downCount:(NSString *)down_count;

@end
