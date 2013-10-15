//
//  EmailListViewController.m
//  ndspro
//
//  Created by fengyongning on 13-10-9.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "EmailListViewController.h"
#import "SCBEmailManager.h"
#import "MBProgressHUD.h"
#import "YNFunctions.h"
#import "EmailDetailViewController.h"


@interface EmailListViewController ()<SCBEmailManagerDelegate,UIAlertViewDelegate,UIActionSheetDelegate>
@property (strong,nonatomic) SCBEmailManager *em;
@property(strong,nonatomic) MBProgressHUD *hud;
@property(strong,nonatomic) UISegmentedControl *segmentedControl;
@end

@implementation EmailListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidAppear:(BOOL)animated
{
    self.tableView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView=[[UITableView alloc] init];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.view addSubview:self.tableView];
    self.tableView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.segmentedControl=[[UISegmentedControl alloc] initWithItems:@[@"收件箱",@"发件箱"]];
    self.segmentedControl.frame=CGRectMake(10, 8, 300, 29);
    [self.segmentedControl setTintColor:[UIColor whiteColor]];
    [self.segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    [self.navigationItem setTitleView:self.segmentedControl];
    [self.segmentedControl setSelectedSegmentIndex:0];
}
-(void)viewWillAppear:(BOOL)animated
{
    [self updateEmailList];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 操作方法
- (void)updateEmailList
{
    //加载本地缓存文件
    NSString *dataFilePath=[YNFunctions getDataCachePath];
    dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:@"EmailList"]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataFilePath])
    {
        NSError *jsonParsingError=nil;
        NSData *data=[NSData dataWithContentsOfFile:dataFilePath];
        self.dataDic=[NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
        if (self.dataDic) {
            NSArray *emails=(NSArray *)[self.dataDic objectForKey:@"emails"];
            NSMutableArray *tempInArray=[NSMutableArray array];
            NSMutableArray *tempOutArray=[NSMutableArray array];
            for (NSDictionary *dic in emails)
            {
                int etype=[[dic objectForKey:@"etype"] intValue];
                //etype	邮件类型	String，0为收件箱，1为发件箱
                if (etype ==0) {
                    [tempInArray addObject:dic];
                }else if(etype==1)
                {
                    [tempOutArray addObject:dic];
                }else
                {
                    NSLog(@"邮件类型出错：%d",etype);
                }
            }
            self.inArray=tempInArray;
            self.outArray=tempOutArray;
            [self.tableView reloadData];
        }
    }

    [self.em cancelAllTask];
    self.em=nil;
    self.em=[[SCBEmailManager alloc] init];
    [self.em setDelegate:self];
    [self.em listEmailWithType:@"2"];
}
-(void)segmentAction:(UISegmentedControl *)seg
{
    [self updateEmailList];
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.segmentedControl.selectedSegmentIndex==0) {
        //收件箱
        if (self.inArray) {
            return self.inArray.count;
        }
    }else
    {
        //发件箱
        if (self.outArray) {
            return self.outArray.count;
        }
    }
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
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
    NSDictionary *dic;
    if (self.segmentedControl.selectedSegmentIndex==0) {
        //收件箱
        if (self.inArray) {
            dic=[self.inArray objectAtIndex:indexPath.row];
        }
    }else
    {
        //发件箱
        if (self.outArray) {
            dic=[self.outArray objectAtIndex:indexPath.row];
        }
    }
    if (dic) {
        cell.textLabel.text=[dic objectForKey:@"etitle"];
        cell.detailTextLabel.text=[dic objectForKey:@"sendtime"];
    }
//    if (self.listArray) {
//        NSDictionary *dic=[self.listArray objectAtIndex:indexPath.row];
//        if (dic) {
//            cell.textLabel.text=[dic objectForKey:@"fname"];
//            NSString *fisdir=[dic objectForKey:@"fisdir"];
//            if ([fisdir isEqualToString:@"0"]) {
//                cell.detailTextLabel.text=[NSString stringWithFormat:@"%@",[dic objectForKey:@"fmodify"]];
//                cell.imageView.image=[UIImage imageNamed:@"Bt_UsercentreNo.png"];
//            }else
//            {
//                cell.imageView.image=[UIImage imageNamed:@"Bt_UsercentreCh.png"];
//                cell.detailTextLabel.text=[NSString stringWithFormat:@"%@ %@",[dic objectForKey:@"fmodify"],[YNFunctions convertSize:[dic objectForKey:@"fsize"]]];
//                NSString *fname=[dic objectForKey:@"fname"];
//                NSString *fmime=[[fname pathExtension] lowercaseString];
//                //                NSString *fmime=[[dic objectForKey:@"fmime"] lowercaseString];
//                NSLog(@"fmime:%@",fmime);
//                if ([fmime isEqualToString:@"png"]||
//                    [fmime isEqualToString:@"jpg"]||
//                    [fmime isEqualToString:@"jpeg"]||
//                    [fmime isEqualToString:@"bmp"]||
//                    [fmime isEqualToString:@"gif"]){
//                    NSString *fthumb=[dic objectForKey:@"fthumb"];
//                    NSString *localThumbPath=[YNFunctions getIconCachePath];
//                    fthumb =[YNFunctions picFileNameFromURL:fthumb];
//                    localThumbPath=[localThumbPath stringByAppendingPathComponent:fthumb];
//                    NSLog(@"是否存在文件：%@",localThumbPath);
//                    if ([[NSFileManager defaultManager] fileExistsAtPath:localThumbPath]) {
//                        NSLog(@"存在文件：%@",localThumbPath);
//                        UIImage *icon=[UIImage imageWithContentsOfFile:localThumbPath];
//                        CGSize itemSize = CGSizeMake(100, 100);
//                        UIGraphicsBeginImageContext(itemSize);
//                        CGRect theR=CGRectMake(0, 0, itemSize.width, itemSize.height);
//                        if (icon.size.width>icon.size.height) {
//                            theR.size.width=icon.size.width/(icon.size.height/itemSize.height);
//                            theR.origin.x=-(theR.size.width/2)-itemSize.width;
//                        }else
//                        {
//                            theR.size.height=icon.size.height/(icon.size.width/itemSize.width);
//                            theR.origin.y=-(theR.size.height/2)-itemSize.height;
//                        }
//                        CGRect imageRect = CGRectMake(2, 2, 96, 96);
//                        //                        CGSize size=icon.size;
//                        //                        if (size.width>size.height) {
//                        //                            imageRect.size.height=size.height*(30.0f/imageRect.size.width);
//                        //                            imageRect.origin.y+=(30-imageRect.size.height)/2;
//                        //                        }else{
//                        //                            imageRect.size.width=size.width*(30.0f/imageRect.size.height);
//                        //                            imageRect.origin.x+=(30-imageRect.size.width)/2;
//                        //                        }
//                        [icon drawInRect:imageRect];
//                        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//                        UIGraphicsEndImageContext();
//                        cell.imageView.image = image;
//                        CGRect r=cell.imageView.frame;
//                        r.size.width=r.size.height=30;
//                        cell.imageView.frame=r;
//                        
//                    }else{
//                        NSLog(@"将要下载的文件：%@",localThumbPath);
//                        [self startIconDownload:dic forIndexPath:indexPath];
//                    }
//                }
//            }
//        }
//    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
//    self.selectedIndexPath=indexPath;
//    [self toMore:self];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic;
    if (self.segmentedControl.selectedSegmentIndex==0) {
        //收件箱
        if (self.inArray) {
            dic=[self.inArray objectAtIndex:indexPath.row];
        }
    }else
    {
        //发件箱
        if (self.outArray) {
            dic=[self.outArray objectAtIndex:indexPath.row];
        }
    }
    if (dic) {
        NSString *eid=[dic objectForKey:@"eid"];
        NSString *etype=[dic objectForKey:@"etype"];
        EmailDetailViewController *edvc=[[EmailDetailViewController alloc] init];
        edvc.eid=eid;
        edvc.etype=etype;
        edvc.title=[dic objectForKey:@"etitle"];
        [self.navigationController pushViewController:edvc animated:YES];
    }

}
#pragma mark - SCBEmailManagerDelegate
-(void)listEmailSucceed:(NSDictionary *)datadic
{
    self.dataDic=datadic;
    if (self.dataDic) {
        NSArray *emails=(NSArray *)[self.dataDic objectForKey:@"emails"];
        NSMutableArray *tempInArray=[NSMutableArray array];
        NSMutableArray *tempOutArray=[NSMutableArray array];
        for (NSDictionary *dic in emails)
        {
            int etype=[[dic objectForKey:@"etype"] intValue];
            //etype	邮件类型	String，0为收件箱，1为发件箱
            if (etype ==0) {
                [tempInArray addObject:dic];
            }else if(etype==1)
            {
                [tempOutArray addObject:dic];
            }else
            {
                NSLog(@"邮件类型出错：%d",etype);
            }
        }
        self.inArray=tempInArray;
        self.outArray=tempOutArray;
        [self.tableView reloadData];

        NSString *dataFilePath=[YNFunctions getDataCachePath];
        dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:@"EmailList"]];
        
        NSError *jsonParsingError=nil;
        NSData *data=[NSJSONSerialization dataWithJSONObject:self.dataDic options:0 error:&jsonParsingError];
        BOOL isWrite=[data writeToFile:dataFilePath atomically:YES];
        if (isWrite) {
            NSLog(@"写入文件成功：%@",dataFilePath);
        }else
        {
            NSLog(@"写入文件失败：%@",dataFilePath);
        }
    }else
    {
        [self updateEmailList];
    }
    NSLog(@"openFinderSucess:");
//    if (self.dataDic)
//    {
//        NSString *dataFilePath=[YNFunctions getDataCachePath];
//        dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:self.f_id]];
//        
//        NSError *jsonParsingError=nil;
//        NSData *data=[NSJSONSerialization dataWithJSONObject:self.dataDic options:0 error:&jsonParsingError];
//        BOOL isWrite=[data writeToFile:dataFilePath atomically:YES];
//        if (isWrite) {
//            NSLog(@"写入文件成功：%@",dataFilePath);
//        }else
//        {
//            NSLog(@"写入文件失败：%@",dataFilePath);
//        }
//    }
}
@end
