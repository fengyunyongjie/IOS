//
//  BootViewController.h
//  NetDisk
//
//  Created by fengyongning on 13-11-11.
//
//

#import <UIKit/UIKit.h>

@interface BootViewController : UIViewController
@property(strong,nonatomic)IBOutlet UIScrollView *scrollView;
@property(strong,nonatomic)IBOutlet UIPageControl *pageCtrl;
-(IBAction)toLogVc:(id)sender;
-(IBAction)toRegistVc:(id)sender;
@end
