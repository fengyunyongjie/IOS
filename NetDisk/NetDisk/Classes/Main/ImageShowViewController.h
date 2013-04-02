

#import <UIKit/UIKit.h>
@interface ImageShowViewController : UIViewController<UIScrollViewDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate,UIGestureRecognizerDelegate>
{
    UIScrollView *scrollView;
    UIView *containerView;
    NSString *picPath;
    
    UIBarButtonItem *leftBtn;
    UIBarButtonItem *rightBtn;
    UINavigationItem *titleItem;
    UINavigationBar *navBar;
    
    UIActivityIndicatorView *indicatorView;
    
    UIImageView *imageView;
    NSDictionary *newsData;
    
    UIView *m_bottomView;
    UIView *m_topView;
    
    NSString *m_title;
    NSTimer *updateTimer;
    UILabel *m_titleLabel;
    NSMutableArray *m_imgListArray;
    int new_index;
    int last_index;
}
@property (nonatomic,retain) NSArray *m_listArray;
@property (nonatomic,assign) int m_index;
@property (nonatomic,retain) NSString *picPath;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *leftBtn;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *rightBtn;
@property (nonatomic,retain) IBOutlet UINavigationItem *titleItem;
@property (nonatomic,retain) IBOutlet UINavigationBar *navBar;
@property (nonatomic,retain) IBOutlet UIScrollView *scrollView;

@property (nonatomic,retain) IBOutlet UIView *m_bottomView;
@property (nonatomic,retain) IBOutlet UIView *m_topView;
@property (nonatomic,retain) NSString *m_title;
@property (nonatomic,retain) IBOutlet UILabel *m_titleLabel;
- (IBAction)comeBack:(id)sender;
-(IBAction)pushButtonAction:(id)sender;
-(IBAction)restoreButtonAction:(id)sender;
- (void)setData:(NSDictionary *)theNewsData;
@end
