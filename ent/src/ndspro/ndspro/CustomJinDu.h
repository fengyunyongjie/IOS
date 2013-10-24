//
//  CustomJinDu.h
//  NetDisk
//
//  Created by Yangsl on 13-7-30.
//
//

#import <UIKit/UIKit.h>

@interface CustomJinDu : UIView
{
    UIColor *backColor;
    UIColor *currColor;
    float currFloat;
    CGSize customSize;
    
    UILabel *backLabel;
    UIImageView *currLabel;
}

@property(nonatomic,strong) UIColor *backColor;
@property(nonatomic,strong) UIColor *currColor;
@property(nonatomic,assign) float currFloat;
@property(nonatomic,assign) CGSize customSize;
@property(nonatomic,strong) UILabel *backLabel;
@property(nonatomic,strong) UIImageView *currLabel;

-(void)showText:(NSString *)text;
-(void)showDate:(NSString *)date;

@end
