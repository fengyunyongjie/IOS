//
//  UIRenameViewController.h
//  NetDisk
//
//  Created by jiangwei on 13-1-15.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+SBJSON.h"
#include "SevenCBoxClient.h"
#import "ATMHud.h"
#import "Function.h"
@interface UIRenameViewController : UIViewController
{
    NSMutableDictionary *m_reanmeDic;
    UITextField *m_textField;
    SevenCBoxClient scBox;
    
    ATMHud *m_hud;
}
@property (nonatomic,retain)     NSMutableDictionary *m_reanmeDic;
@property (nonatomic,retain)     IBOutlet UITextField *m_textField;

- (IBAction)comeBack:(id)sender;
- (IBAction)save:(id)sender;

- (void)showFmRenameView:(NSString *)theData;
- (void)popController;
@end
