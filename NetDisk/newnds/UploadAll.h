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
}

-(id)init;

@property(nonatomic,retain) NSMutableArray *uploadAllList;
@property(nonatomic,assign) BOOL isUpload;
@property(nonatomic,retain) NSString *space_id;

-(void)startUpload;
-(void)changeUpload:(NSMutableOrderedSet *)array_;
-(void)changeDeviceName:(NSString *)device_name;

@end
