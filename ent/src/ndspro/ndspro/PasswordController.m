//
//  PasswordController.m
//  ndspro
//
//  Created by Yangsl on 13-10-16.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "PasswordController.h"
#import "LTHPasscodeViewController.h"
#import "APService.h"
#import "AppDelegate.h"

@interface PasswordController ()

@end

@implementation PasswordController
@synthesize table_view;

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
    self.title = @"密码锁";
    self.table_view = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.table_view.dataSource = self;
    self.table_view.delegate = self;
    [self.view addSubview:self.table_view];
    
    if ([LTHPasscodeViewController passcodeExistsInKeychain]) {
        [LTHPasscodeViewController saveTimerStartTime];
        if ([LTHPasscodeViewController timerDuration] == 1)
        {
            [[LTHPasscodeViewController sharedUser] showForEnablingPasscodeInViewController: self];
        }
    }
    else
    {
        [[LTHPasscodeViewController sharedUser] showForEnablingPasscodeInViewController: self];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.table_view reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellString = @"PassWordCell";
    UITableViewCell *cell = [self.table_view dequeueReusableHeaderFooterViewWithIdentifier:cellString];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellString];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    }
    int row = indexPath.row;
    switch (row) {
        case 0:
        {
            if ([LTHPasscodeViewController passcodeExistsInKeychain]) {
                [LTHPasscodeViewController saveTimerStartTime];
                if ([LTHPasscodeViewController timerDuration] == 1)
                {
                    [cell.textLabel setText:@"开启密码锁"];
                }
                else
                {
                    [cell.textLabel setText:@"关闭密码锁"];
                }
            }
            else
            {
                [cell.textLabel setText:@"开启密码锁"];
            }
        }
            break;
        case 1:
        {
            
            [cell.textLabel setText:@"修改密码锁"];
        }
            break;
        default:
            break;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = indexPath.row;
    switch (row) {
        case 0:
        {
            UITableViewCell *cell = [self.table_view cellForRowAtIndexPath:indexPath];
            if([cell.textLabel.text isEqualToString:@"开启密码锁"])
            {
                [[LTHPasscodeViewController sharedUser] showForEnablingPasscodeInViewController: self];
            }
            else
            {
                [[LTHPasscodeViewController sharedUser] showForTurningOffPasscodeInViewController: self];
            }
        }
            break;
        case 1:
        {
            [[LTHPasscodeViewController sharedUser] showForChangingPasscodeInViewController: self];
        }
            break;
        case 2:
        {
            UIActionSheet *actionSheet=[[UIActionSheet alloc]  initWithTitle:@"继续操作将退出当前账号" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"是否继续？", nil];
            [actionSheet setActionSheetStyle:UIActionSheetStyleDefault];
            [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
        }
            break;
        default:
            break;
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"usr_name"];
        [[NSUserDefaults standardUserDefaults] setObject:nil  forKey:@"usr_pwd"];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"switch_flag"];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"isAutoUpload"];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"passcodeTimerDuration"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [APService setTags:nil alias:nil];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate finishLogout];
    }
}

@end
