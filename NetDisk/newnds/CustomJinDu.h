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
    UILabel *currLabel;
}

@property(nonatomic,retain) UIColor *backColor;
@property(nonatomic,retain) UIColor *currColor;
@property(nonatomic,assign) float currFloat;
@property(nonatomic,assign) CGSize customSize;

-(void)showText:(NSString *)text;

@end
