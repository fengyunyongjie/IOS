//
//  UploadViewController.h
//  NetDisk
//
//  Created by fengyongning on 13-5-21.
//
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "SCBPhotoManager.h"
#import "SCBUploader.h"
#import <CommonCrypto/CommonDigest.h>

@interface UploadViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,NewFoldDelegate,UpLoadDelegate>
{
    float allHeight;
    //装载所有图片信息
    NSMutableArray *photoArray;
    //上传集合
    NSMutableArray *uploadArray;
    BOOL isSelected;
    int f_pid;
    int uploadNumber;
    SCBPhotoManager *photoManger;
    NSString *finishName;
    NSString *uploadData;
    BOOL isStop;
    UIImage *imageV;
}
@property (retain, nonatomic) IBOutlet UIImageView *stateImageview;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UIButton *uploadTypeButton;
@property (retain, nonatomic) IBOutlet UIButton *diyUploadButton;
@property (retain, nonatomic) IBOutlet UILabel *basePhotoLabel;
@property (retain, nonatomic) IBOutlet UILabel *formatLabel;
@property (retain, nonatomic) IBOutlet UILabel *uploadNumberLabel;
@property (nonatomic,retain) NSMutableArray *photoArray;

-(NSString *)md5:(NSData *)concat;

@end


@interface photoImage : NSObject
{
    UIImage *image;
    NSString *name;
    NSString *imageSize;
    NSString *image_device;
    NSString *img_createtime;
}

@property(nonatomic,retain) UIImage *image;
@property(nonatomic,retain) NSString *name;
@property(nonatomic,retain) NSString *imageSize;
@property(nonatomic,retain) NSString *image_device;
@property(nonatomic,retain) NSString *img_createtime;


@end