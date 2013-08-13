//
//  ReportViewController.h
//  NetDisk
//
//  Created by fengyongning on 13-8-12.
//
//

#import <UIKit/UIKit.h>

@interface ReportViewController : UIViewController
@property(strong,nonatomic) IBOutlet UILabel *titleLabel;
@property(strong,nonatomic) IBOutlet UITextView *reportView;
-(IBAction)back:(id)sender;
-(IBAction)send:(id)sender;
- (IBAction)endEdit:(id)sender;

@end
