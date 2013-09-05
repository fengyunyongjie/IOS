//
//  MyndsViewController.h
//  NetDisk
//
//  Created by fengyongning on 13-4-28.
//
//

#import <UIKit/UIKit.h>
#import "QBImagePickerController.h"
#import "QLBrowserViewController.h"

typedef enum {
    kMyndsTypeDefault,
    kMyndsTypeSelect,
    kMyndsTypeMyShareSelect,
    kMyndsTypeShareSelect,
    kMyndsTypeMyShare,
    kMyndsTypeShare,
    kMyndsTypeDefaultSearch,
    kMyndsTypeMyShareSearch,
    kMyndsTypeShareSearch,
} MyndsType;
typedef enum {
    kSharedTypeMessage,
    kSharedTypeMail,
    kSharedTypeCopy,
    kSharedTypeWeixin,
    kSharedTypeFrends,
}SharedType;
@interface MyndsViewController : UIViewController<UIDocumentInteractionControllerDelegate,UITableViewDataSource,UITableViewDelegate,QBImagePickerControllerDelegate,UIActionSheetDelegate,QLPreviewControllerDataSource,QLPreviewControllerDelegate>

@property (strong,nonatomic) NSDictionary *dataDic;
@property (strong,nonatomic) NSArray *listArray;
@property (strong,nonatomic) NSArray *finderArray;
@property (strong,nonatomic) NSString *f_id;
@property (assign,nonatomic) MyndsType myndsType;
@property (assign,nonatomic) MyndsViewController *delegate;
@property (strong,nonatomic) NSMutableDictionary *imageDownloadsInProgress;
@property (strong,nonatomic) UIToolbar *toolBar;
@property (strong,nonatomic) UITableView *tableView;
@property (strong,nonatomic) UIImageView *spaceImgView;
@property (strong,nonatomic) UIControl *ctrlView;
@property (strong,nonatomic) UILabel *lblEdit;
@property (strong,nonatomic) UILabel *titleLabel;
@property (strong,nonatomic) UIView *cellMenu;
@property (strong,nonatomic) UIControl *newFinderView;
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
@property (strong,nonatomic) UIView *searchView;
@property (strong,nonatomic) UITextField *tfdSearch;
@property (strong,nonatomic) UIButton *more_button;
@property (strong,nonatomic) UIControl *selectView;
@property (strong,nonatomic) NSArray *selectBtns;
@property (strong,nonatomic) UIView *editView;
@property (strong,nonatomic) UIButton *btnNewFinder;
@property (strong,nonatomic) UIButton *btnUpload;
@property (strong,nonatomic) UIButton *btnEdit;
@property (strong,nonatomic) UIButton *btnSearch;
@property (strong,nonatomic) UIButton *btnMove;
@property (strong,nonatomic) UILabel *lblMove;
@property (strong,nonatomic) UIButton *btnHide;
@property (strong,nonatomic) UIButton *btnAllSelect;
@property (strong,nonatomic) UILabel *lblAllSelect;
@property (strong,nonatomic) UIButton *btnNoSelect;
@property (strong,nonatomic) UILabel *lblNoSelect;
@property (assign,nonatomic) SharedType sharedType;
@property (strong,nonatomic) UIView *selectToolView;
@property (strong,nonatomic) NSArray *movefIds;
-(void)loadData;
- (void)viewWillAppear:(BOOL)animated;
@end

@interface FileItem : NSObject
{
}
@property (nonatomic, assign)	BOOL checked;
+ (FileItem*) fileItem;
@end