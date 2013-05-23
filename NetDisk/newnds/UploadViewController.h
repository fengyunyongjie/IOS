//
//  UploadViewController.h
//  NetDisk
//
//  Created by fengyongning on 13-5-21.
//
//

#import <UIKit/UIKit.h>

@interface UploadViewController : UIViewController
{
    float allHeight;
}
@property (retain, nonatomic) IBOutlet UIImageView *stateImageview;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UIButton *uploadTypeButton;
@property (retain, nonatomic) IBOutlet UIButton *diyUploadButton;
@property (retain, nonatomic) IBOutlet UILabel *basePhotoLabel;
@property (retain, nonatomic) IBOutlet UILabel *formatLabel;
@property (retain, nonatomic) IBOutlet UILabel *uploadNumber;

@end
