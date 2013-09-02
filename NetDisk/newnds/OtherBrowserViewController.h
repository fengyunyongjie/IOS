//
//  OtherBrowserViewController.h
//  NetDisk
//
//  Created by fengyongning on 13-5-27.
//
//

#import <UIKit/UIKit.h>
#import "QLBrowserViewController.h"
@interface OtherBrowserViewController : UIViewController<UIDocumentInteractionControllerDelegate,QLPreviewControllerDataSource,QLPreviewControllerDelegate>
@property (strong,nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong,nonatomic) IBOutlet UIBarButtonItem *shareItem;
@property (strong,nonatomic) IBOutlet UIBarButtonItem *openItem;
@property (strong,nonatomic) IBOutlet UIButton *downloadBtn;
@property (strong,nonatomic) IBOutlet UIProgressView *downloadProgress;
@property (strong,nonatomic) IBOutlet UILabel *alertLabel;
@property (strong,nonatomic) IBOutlet UILabel *downloadLabel;
@property (strong,nonatomic) IBOutlet UIImageView *iconImageView;
@property (assign,nonatomic) BOOL isFinished;
@property (strong,nonatomic) NSDictionary *dataDic;
@property (strong,nonatomic) NSString *savePath;
@property (strong,nonatomic) UILabel *titleLabel;
-(IBAction)openWithOthersApp:(id)sender;
-(IBAction)shared:(id)sender;
-(IBAction)download:(id)sender;
@end
