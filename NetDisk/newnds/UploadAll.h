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
}

@property(nonatomic,retain) NSMutableArray *uploadAllList;

@end
