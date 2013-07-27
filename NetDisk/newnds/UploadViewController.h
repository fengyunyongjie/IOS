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
#import "BoderView.h"
#import "QBImagePickerController.h"

@interface UploadViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,NewFoldDelegate,UpLoadDelegate,UIAlertViewDelegate,QBImagePickerControllerDelegate,UITableViewDataSource,UITableViewDelegate>
{
    float allHeight;
    //装载所有图片信息
    NSMutableArray *photoArray;
    NSMutableArray *historyArray;
    //上传集合
    NSMutableArray *uploadArray;
    BOOL isSelected;
    int f_pid;
    int f_id;
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
    float y;
    /*
     上传检索
     */
    NSTimer *connectionTimer;
    NSTimer *libaryTimer;
    NSURLConnection *connection;
    
    /*
     准备上传界面
     */
    UIImageView *waitBackGround;
    UILabel *uploadWaitLabel;
    UIButton *uploadWaitButton;
    
    /*
     正在上传界面
     */
    BoderView *uploadImageView;
    UIProgressView *uploadProgressView;
    UILabel *currFileNameLabel;
    UILabel *uploadFinshPageLabel;
    UIImageView *unWifiOrNetWorkImageView;
    
    /*
     等待wifi中界面
     */
    
    /*
     用户无网络界面
     */
    /*
     上传完成界面
     */
    UILabel *uploadFinshLabel;
    UIImageView *uploadFinshImageView;
    
    NSString *deviceName;
    
    //是否提示用户
    BOOL isAlert;
    BOOL isWlanUpload;
    SCBUploader *uploderDemo;
    int netWorkState; //1表示Wi-Fi 2表示WLan 3无网络
    
    BOOL isUpload;
    BOOL isOpenLibray;
    BOOL isGetLibary;
    BOOL isLookLibray;
    
    /*
     自定义navBar
     */
    UIView *topView;
    BOOL isNeedBackButton;
    
    BOOL isNeedChangeUpload;
    UITableView *uploadListTableView;
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

@property (nonatomic,retain) UIImageView *waitBackGround;
@property (nonatomic,retain) UILabel *uploadWaitLabel;
@property (nonatomic,retain) UIButton *uploadWaitButton;

@property (nonatomic,retain) BoderView *uploadImageView;
@property (nonatomic,retain) UIProgressView *uploadProgressView;
@property (nonatomic,retain) UILabel *currFileNameLabel;
@property (nonatomic,retain) UILabel *uploadFinshPageLabel;
@property (nonatomic,retain) UIImageView *unWifiOrNetWorkImageView;

@property (nonatomic,retain) UILabel *uploadFinshLabel;
@property (nonatomic,retain) UIImageView *uploadFinshImageView;
@property (nonatomic,retain) SCBUploader *uploderDemo;
@property (nonatomic,assign) BOOL isNeedChangeUpload;

@property (nonatomic,assign) BOOL isUpload;
@property (nonatomic,assign) BOOL isStop;
@property(nonatomic,assign) BOOL isNeedBackButton;
@property(nonatomic,retain) UITableView *uploadListTableView;

-(NSString *)md5:(NSData *)concat;
-(void)startSouStart;
-(void)stopAllDo;
-(void)stopWiFi;
-(void)changeUpload:(NSMutableOrderedSet *)array_;
-(void)changeDeviceName:(NSString *)device_name;

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