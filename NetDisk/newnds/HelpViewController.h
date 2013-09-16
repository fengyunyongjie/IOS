//
//  HelpViewController.h
//  NetDisk
//
//  Created by fengyongning on 13-9-16.
//
//

#import <UIKit/UIKit.h>
typedef enum{
    kTypeMySB,
    kTypeHomeSpace,
} HelpType;
@interface HelpViewController : UIViewController<UIGestureRecognizerDelegate>
@property(nonatomic,assign) HelpType thisType;
@end
