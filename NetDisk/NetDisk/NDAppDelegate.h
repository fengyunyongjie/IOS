//
//  NDAppDelegate.h
//  NetDisk
//
//  Created by jiangwei on 12-11-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NDTaskManagerViewController.h"
#include <vector>
#include <string>
#include <sys/stat.h>
#include <sys/mount.h>

//#include "SevenCBoxClient.h"
using namespace std;

#define TAG_ACTIONSHEET_PHOTO 101
#define TAG_ACTIONSHEET_SHARE 102
#define TAG_ACTIONSHEET_SINGLE 103

typedef enum{
    PasteTypeFM =1,
    PasteTypeSHARE,
} PasteType;

@class NDViewController;

@interface NDAppDelegate : UIResponder <UIApplicationDelegate>
{
    
    NSMutableArray *m_listArray_uploading;
    NSMutableArray *m_listArray_uploaded;
    NSMutableArray *m_listArray_downloading;
    NSMutableArray *m_listArray_downloaded;
    
    NDTaskManagerViewController *_taskMangeView;

    
@public
    vector<string> member_account;
    
    NSString *m_copyId;
    NSMutableArray *m_copyArray;
    NSString *m_copyParentId;
    bool m_isCut;
    int m_pasteType;//0无复制 1 FM 2 SHARE
    NSString *m_parentIdForFresh;//用于剪切成功后刷新父目录
    
}
@property (nonatomic,assign) NSMutableArray *m_listArray_uploading;
@property (nonatomic,assign) NSMutableArray *m_listArray_uploaded;
@property (nonatomic,assign) NSMutableArray *m_listArray_downloading;
@property (nonatomic,assign) NSMutableArray *m_listArray_downloaded;

@property (nonatomic,assign) NDTaskManagerViewController *_taskMangeView;

@property (nonatomic,copy) NSString *m_copyId;
@property (nonatomic,copy) NSMutableArray *m_copyArray;
@property (nonatomic,copy) NSString *m_copyParentId;
@property (nonatomic,assign) bool m_isCut;
@property (nonatomic,assign) int m_pasteType;
@property (nonatomic,retain) NSString *m_parentIdForFresh;

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NDViewController *viewController;

-(void)clearCopyCache;
-(void)clearFreshID;
-(void)setTaskUploadedList:(NSMutableArray *)theUploadedList 
          theUploadingList:(NSMutableArray *)theUploadingList 
         theDownloadedList:(NSMutableArray *)theDownloadedList 
         theDownloadingList:(NSMutableArray *)theDownloadingList ;
@end
