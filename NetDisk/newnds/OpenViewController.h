//
//  OpenViewController.h
//  NetDisk
//
//  Created by fengyongning on 13-5-29.
//
//

#import <UIKit/UIKit.h>

@interface OpenViewController : UIViewController
@property (strong,nonatomic) NSURL *fileUrl;
-(void)configUrl:(NSURL *)url;
-(IBAction)cancelAction:(id)sender;
@end
