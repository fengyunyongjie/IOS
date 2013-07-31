//
//  MyndsViewController.h
//  NetDisk
//
//  Created by fengyongning on 13-4-28.
//
//

#import <UIKit/UIKit.h>
#import "QBImagePickerController.h"

typedef enum {
    kMyndsTypeDefault,
    kMyndsTypeSelect,
    kMyndsTypeMyShare,
    kMyndsTypeShare,
} MyndsType;

@interface MyndsViewController : UIViewController<UIDocumentInteractionControllerDelegate,UITableViewDataSource,UITableViewDelegate,QBImagePickerControllerDelegate>

@property (strong,nonatomic) NSDictionary *dataDic;
@property (strong,nonatomic) NSArray *listArray;
@property (strong,nonatomic) NSArray *finderArray;
@property (strong,nonatomic) NSString *f_id;
@property (assign,nonatomic) MyndsType myndsType;
@property (assign,nonatomic) MyndsViewController *delegate;
@property (strong,nonatomic) NSMutableDictionary *imageDownloadsInProgress;
@property (strong,nonatomic) UIToolbar *toolBar;
@property (strong,nonatomic) UITableView *tableView;
@property (strong,nonatomic) UIControl *ctrlView;
@property (strong,nonatomic) UILabel *lblEdit;
@property (strong,nonatomic) UILabel *titleLabel;
@property (strong,nonatomic) UIView *cellMenu;
@property (strong,nonatomic) UIView *newFinderView;
@property (strong,nonatomic) UITextField *tfdFinderName;
@property (strong,nonatomic) UIButton *btnRename;
@property (strong,nonatomic) UILabel *lblRename;
@property (strong,nonatomic) UIButton *btnDownload;
@property (strong,nonatomic) UILabel *lblDownload;
@property (strong,nonatomic) UIButton *btnDel;
@property (strong,nonatomic) UILabel *lblDel;
@property (strong,nonatomic) UIButton *btnMore;
@property (strong,nonatomic) UILabel *lblMore;
@property (strong,nonatomic) UIButton *btnShare;
@property (strong,nonatomic) UILabel *lblShare;
-(void)loadData;
@end

@interface FileItem : NSObject
{
}
@property (nonatomic, assign)	BOOL checked;
+ (FileItem*) fileItem;
@end