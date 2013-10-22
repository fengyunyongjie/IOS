//
//  SendEmailViewController.m
//  ndspro
//
//  Created by fengyongning on 13-10-10.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "SendEmailViewController.h"
#import "UserListViewController.h"
#import "SCBEmailManager.h"
#import "MBProgressHUD.h"
#import "YNFunctions.h"

@interface SendEmailViewController ()<SCBEmailManagerDelegate>
@property (strong,nonatomic) SCBEmailManager *em;
@property(strong,nonatomic) MBProgressHUD *hud;
@end

@implementation SendEmailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *cancel=[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)];
    [self.navigationItem setLeftBarButtonItem:cancel];
    UIBarButtonItem *send=[[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(sendAction:)];
    [self.navigationItem setRightBarButtonItem:send];
    
    self.tableView=[[UITableView alloc] init];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.view addSubview:self.tableView];
    self.tableView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}
-(void)viewDidAppear:(BOOL)animated
{
    self.tableView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 操作方法
-(void)cancelAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(BOOL)canSend
{
    self.eTitle=self.eTitleTextField.text;
    if (self.eTitle==nil||[self.eTitle isEqualToString:@""]) {
        if (self.hud) {
            [self.hud removeFromSuperview];
        }
        self.hud=nil;
        self.hud=[[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:self.hud];
        [self.hud show:NO];
        self.hud.labelText=@"请填写标题栏";
        //self.hud.labelText=error_info;
        self.hud.mode=MBProgressHUDModeText;
        self.hud.margin=10.f;
        [self.hud show:YES];
        [self.hud hide:YES afterDelay:1.0f];
        return NO;
    }
    if (self.tyle==kTypeSendEx) {
        self.recevers=self.receversTextField.text;
        if (self.recevers==nil||[self.recevers isEqualToString:@""]) {
            if (self.hud) {
                [self.hud removeFromSuperview];
            }
            self.hud=nil;
            self.hud=[[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:self.hud];
            [self.hud show:NO];
            self.hud.labelText=@"请填写收件人";
            //self.hud.labelText=error_info;
            self.hud.mode=MBProgressHUDModeText;
            self.hud.margin=10.f;
            [self.hud show:YES];
            [self.hud hide:YES afterDelay:1.0f];
            return NO;
        }else if(![self checkIsEmail:self.recevers])
        {
            if (self.hud) {
                [self.hud removeFromSuperview];
            }
            self.hud=nil;
            self.hud=[[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:self.hud];
            [self.hud show:NO];
            self.hud.labelText=@"请输入正确的邮箱帐号";
            //self.hud.labelText=error_info;
            self.hud.mode=MBProgressHUDModeText;
            self.hud.margin=10.f;
            [self.hud show:YES];
            [self.hud hide:YES afterDelay:1.0f];
            return NO;
        }
    }else
    {
        if (self.usrids==nil||self.usrids.count==0) {
            if (self.hud) {
                [self.hud removeFromSuperview];
            }
            self.hud=nil;
            self.hud=[[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:self.hud];
            [self.hud show:NO];
            self.hud.labelText=@"请选择收件人";
            //self.hud.labelText=error_info;
            self.hud.mode=MBProgressHUDModeText;
            self.hud.margin=10.f;
            [self.hud show:YES];
            [self.hud hide:YES afterDelay:1.0f];
            return NO;
        }
    }
    return YES;
}
-(void)sendAction:(id)sender
{
    if (![self canSend]) {
        return;
    }
    
    self.em=[[SCBEmailManager alloc] init];
    self.em.delegate=self;
    self.eTitle=self.eTitleTextField.text;
    self.eContent=self.eContentView.text;
    if (!self.eTitle) {
        self.eTitle=@"";
    }
    if (!self.eContent) {
        self.eContent=@"";
    }
    
    
    if (self.tyle==kTypeSendEx) {
        self.recevers=self.receversTextField.text;
        [self.em sendExternalEmailToUser:self.recevers Title:self.eTitle Content:self.eContent Files:self.fids];
    }else
    {
        NSLog(@"%@",self.eTitleTextField.text);
        [self.em sendInteriorEmailToUser:self.usrids Title:self.eTitle Content:self.eContent Files:self.fids];
    }
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"正在发送...";
    //self.hud.labelText=error_info;
    self.hud.mode=MBProgressHUDModeIndeterminate;
    self.hud.margin=10.f;
    [self.hud show:YES];
    //[self.hud hide:YES afterDelay:1.0f];
}
-(BOOL)checkIsEmail:(NSString *)text
{
    NSString *Regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", Regex];
    
    return [emailTest evaluateWithObject:text];
}
-(void)didSelectUserIDS:(NSArray *)ids Names:(NSArray *)names
{
    self.usrids=ids;
    self.names=[names componentsJoinedByString:@";"];
    [self.tableView reloadData];
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView              // Default is 1 if not implemented
{
    return 4;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //    if (self.segmentedControl.selectedSegmentIndex==0) {
    //        //收件箱
    //        if (self.inArray) {
    //            return self.inArray.count;
    //        }
    //    }else
    //    {
    //        //发件箱
    //        if (self.outArray) {
    //            return self.outArray.count;
    //        }
    //    }
    if (section==3) {
        if (self.fileArray) {
            return self.fileArray.count;
        }
    }
    return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    // fixed font style. use custom view (UILabel) if you want something different
    switch (section) {
        case 0:
            return @"接收人：";
            break;
        case 1:
            return @"标题：";
            break;
        case 2:
            return @"内容：";
            break;
        case 3:
            return @"文件：";
            break;
        default:
            break;
    }
    return nil;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    if (indexPath.section==5) {
        CellIdentifier=@"FileListCell";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
//        NSString *osVersion = [[UIDevice currentDevice] systemVersion];
//        NSString *versionWithoutRotation = @"7.0";
//        BOOL noRotationNeeded = ([versionWithoutRotation compare:osVersion options:NSNumericSearch]
//                                 != NSOrderedDescending);
//        if (noRotationNeeded) {
//            cell.accessoryType=UITableViewCellAccessoryDetailButton;
//        }else
//        {
//            cell.accessoryType=UITableViewCellAccessoryDetailDisclosureButton;
//        }
    }
    switch (indexPath.section) {
        case 0:
//            return @"接收人：";
        {
            if (self.tyle==kTypeSentIn) {
                cell.textLabel.text=self.names;
            }else
            {
                self.recevers=self.receversTextField.text;
                if (self.receversTextField) {
                }else
                {
                    UITextField *textField=[[UITextField alloc] initWithFrame:CGRectMake(20, 0, cell.frame.size.width-20, cell.frame.size.height)];
                    self.receversTextField=textField;
                }
                [cell.contentView addSubview:self.receversTextField];
                self.receversTextField.text=self.recevers;
            }
        }
            break;
        case 1:
//            return @"标题：";
        {
            self.eTitle=self.eTitleTextField.text;
            if (self.eTitleTextField) {
            }else
            {
                UITextField *textField=[[UITextField alloc] initWithFrame:CGRectMake(20, 0, cell.frame.size.width-20, cell.frame.size.height)];
                self.eTitleTextField=textField;
            }
            [cell.contentView addSubview:self.eTitleTextField];
            self.eTitleTextField.text=self.eTitle;
        }
            break;
        case 2:
//            return @"内容：";
        {
            self.eContent=self.eContentView.text;
            if (self.eContentView) {
            }else
            {
                UITextView *textView=[[UITextView alloc] initWithFrame:CGRectMake(20, 10, cell.frame.size.width-20, 180)];
                textView.editable=YES;
                self.eContentView=textView;

            }
            [cell.contentView addSubview:self.eContentView];
            self.eContentView.text=self.eContent;
        }
            break;
        case 3:
//            return @"文件：";
        {
            if (self.fileArray) {
                NSDictionary *dic=[self.fileArray objectAtIndex:indexPath.row];
                if (dic) {
                    cell.textLabel.text=[dic objectForKey:@"fname"];
                    //NSString *fisdir=[dic objectForKey:@"fisdir"];
                    long fsize=[[dic objectForKey:@"fsize"] longValue];
                    if (fsize==0) {
                        //                            cell.detailTextLabel.text=[NSString stringWithFormat:@"%@",[dic objectForKey:@"fmodify"]];
                        cell.imageView.image=[UIImage imageNamed:@"file_folder.png"];
                    }else
                    {
                        cell.imageView.image=[UIImage imageNamed:@"file_other.png"];
                        cell.detailTextLabel.text=[NSString stringWithFormat:@"%@",[YNFunctions convertSize:[dic objectForKey:@"fsize"]]];
                        NSString *fname=[dic objectForKey:@"fname"];
                        NSString *fmime=[[fname pathExtension] lowercaseString];
                        //                NSString *fmime=[[dic objectForKey:@"fmime"] lowercaseString];
                        NSLog(@"fmime:%@",fmime);
                        if ([fmime isEqualToString:@"png"]||
                            [fmime isEqualToString:@"jpg"]||
                            [fmime isEqualToString:@"jpeg"]||
                            [fmime isEqualToString:@"bmp"]||
                            [fmime isEqualToString:@"gif"]){
                            cell.imageView.image = [UIImage imageNamed:@"file_pic.png"];
                        }else if ([fmime isEqualToString:@"doc"]||
                                  [fmime isEqualToString:@"docx"])
                        {
                            cell.imageView.image = [UIImage imageNamed:@"file_doc.png"];
                        }else if ([fmime isEqualToString:@"mp3"])
                        {
                            cell.imageView.image = [UIImage imageNamed:@"file_music.png"];
                        }else if ([fmime isEqualToString:@"mov"])
                        {
                            cell.imageView.image = [UIImage imageNamed:@"file_moving.png"];
                        }else if ([fmime isEqualToString:@"ppt"])
                        {
                            cell.imageView.image = [UIImage imageNamed:@"file_other.png"];
                        }else
                        {
                            cell.imageView.image = [UIImage imageNamed:@"file_other.png"];
                        }
                    }
                }
            }
        }
            break;
        default:
            break;
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==2) {
        return 200;
//        UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
//        return cell.frame.size.height+30;
    }
    return tableView.rowHeight;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    //    self.selectedIndexPath=indexPath;
    //    [self toMore:self];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            //            return @"接收人：";
            if (self.tyle==kTypeSentIn) {
                UserListViewController *ulvc=[[UserListViewController alloc] init];
                ulvc.delegate=self;
                [self.navigationController pushViewController:ulvc animated:YES];
            }
            break;
        case 1:
            //            return @"标题：";
            break;
        case 2:
            //            return @"内容：";
            break;
        case 3:
            //            return @"文件：";
            break;
        default:
            break;
    }
}
#pragma mark - SCBEmailManagerDelegate
-(void)sendEmailSucceed
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"发送成功";
    //self.hud.labelText=error_info;
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
    [self performSelector:@selector(cancelAction:) withObject:self afterDelay:1.0f];
}
-(void)sendEmailFail
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"发送失败";
    //self.hud.labelText=error_info;
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
}
#pragma mark - Deferred image loading (UIScrollViewDelegate)
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[self.eTitleTextField endEditing:YES];
    [self.receversTextField endEditing:YES];
    [self.eContentView endEditing:YES];
    
}
@end
