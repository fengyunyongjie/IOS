//
//  SendEmailViewController.h
//  ndspro
//
//  Created by fengyongning on 13-10-10.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
    kTypeSentIn,        //站内发送
    kTypeSendEx,        //站外发送
}SendEmailType;
@interface SendEmailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (strong,nonatomic) NSArray *fids;
@property (strong,nonatomic) NSArray *fileArray;
@property (strong,nonatomic) UITextView *eContentView;
@property (strong,nonatomic) NSString *eContent;
@property (strong,nonatomic) UITextField *eTitleTextField;
@property (strong,nonatomic) NSString *eTitle;
@property (strong,nonatomic) UITextField *receversTextField;
@property (strong,nonatomic) NSString *recevers;
@property (strong,nonatomic) NSArray *usrids;
@property (strong,nonatomic) NSString *names;
@property (assign,nonatomic) SendEmailType tyle;

@property (strong,nonatomic) UITableView *tableView;
@property (strong,nonatomic) NSIndexPath *selectedIndexPath;
@property (strong,nonatomic) NSMutableDictionary *imageDownloadsInProgress;
-(void)didSelectUserIDS:(NSArray *)ids Names:(NSArray *)names;
@end
