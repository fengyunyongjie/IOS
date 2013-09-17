//
//  UploadAll.h
//  NetDisk
//
//  Created by Yangsl on 13-7-31.
//
//

#import <Foundation/Foundation.h>

#import "QBImagePickerController.h"
#import "UploadFile.h"

@interface UploadAll : NSObject <QBImagePickerControllerDelegate,UploadFileDelegate>
{
    NSMutableArray *uploadAllList;
    //上传至文件夹目录名称
    NSString *deviceName;
    BOOL isUpload;
    NSString *space_id;
    NSString *f_id;
    NSMutableOrderedSet *asetArray;
}

-(id)init;

@property(nonatomic,retain) NSMutableArray *uploadAllList;
@property(nonatomic,assign) BOOL isUpload;
@property(nonatomic,retain) NSString *space_id;
@property(nonatomic,retain) NSString *f_id;
@property(nonatomic,retain) NSMutableOrderedSet *asetArray;

-(void)startUpload;
-(void)newStartUpload;
-(void)changeUpload:(NSMutableOrderedSet *)array_;
-(void)changeDeviceName:(NSString *)device_name;
-(void)changeFileId:(NSString *)f_id;

@end
