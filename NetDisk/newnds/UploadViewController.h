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

@interface UploadViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,NewFoldDelegate,UpLoadDelegate,UIAlertViewDelegate>
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
    
    
    UIImageView *stateImageview;
    UILabel *nameLabel;
    UIButton *uploadTypeButton;
    UIButton *diyUploadButton;
    UILabel *basePhotoLabel;
    UILabel *formatLabel;
    UILabel *uploadNumberLabel;
    NSString *user_id;
    NSString *user_token;
    
    //网络异常
    bool isConnectionBl;
    BOOL timerBL;
    BOOL baseBL;
    BOOL isConnection;
    BOOL isOnce;
    /*
     上传检索
     */
    NSTimer *connectionTimer;
    NSTimer *libaryTimer;
    NSURLConnection *connection;
}
@property (retain, nonatomic) UIImageView *stateImageview;
@property (retain, nonatomic) UILabel *nameLabel;
@property (retain, nonatomic) UIButton *uploadTypeButton;
@property (retain, nonatomic) UIButton *diyUploadButton;
@property (retain, nonatomic) UILabel *basePhotoLabel;
@property (retain, nonatomic) UILabel *formatLabel;
@property (retain, nonatomic) UILabel *uploadNumberLabel;
@property (nonatomic,retain) NSMutableArray *photoArray;
@property (nonatomic,retain) NSString *user_id;
@property (nonatomic,retain) NSString *user_token;

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