//
//  MyndsViewController.h
//  NetDisk
//
//  Created by fengyongning on 13-4-28.
//
//

#import <UIKit/UIKit.h>

typedef enum {
    kMyndsTypeDefault,
    kMyndsTypeSelect,
} MyndsType;

@interface MyndsViewController : UIViewController<UIDocumentInteractionControllerDelegate,UITableViewDataSource,UITableViewDelegate>
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
-(void)loadData;
@end

@interface FileItem : NSObject
{
}
@property (nonatomic, assign)	BOOL checked;
+ (FileItem*) fileItem;
@end