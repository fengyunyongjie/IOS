//
//  MyndsViewController.m
//  NetDisk
//
//  Created by fengyongning on 13-4-28.
//
//

#import "MyndsViewController.h"
#import "SCBFileManager.h"
#import "FileItemTableCell.h"
#import "YNFunctions.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "FavoritesData.h"
#import "PhohoDemo.h"
#import "PhotoDetailViewController.h"
#import "IconDownloader.h"
#import "ImageBrowserViewController.h"

@implementation FileItem

+ (FileItem*) fileItem
{
	return [[[self alloc] init] autorelease];
}

- (void) dealloc
{
	[super dealloc];
}
@end

@interface MyndsViewController ()
@property (strong,nonatomic) SCBFileManager *fm;
@property (strong,nonatomic) NSIndexPath *selectedIndexPath;
@property (strong,nonatomic) UITableViewCell *optionCell;
@property (strong,nonatomic) UIBarButtonItem *editBtn;
@property (strong,nonatomic) UIBarButtonItem *deleteBtn;
@property (assign,nonatomic) BOOL isEditing;
@property (strong,nonatomic) NSMutableArray *m_fileItems;
@property(strong,nonatomic) MBProgressHUD *hud;
@end

@implementation MyndsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.tableView.allowsSelectionDuringEditing=YES;
    }
    return self;
}

- (void)viewDidLoad
{
    self.imageDownloadsInProgress=[NSMutableDictionary dictionary];
    [super viewDidLoad];
    self.optionCell=[[[UITableViewCell alloc] init] autorelease];
    [self.optionCell addSubview:[[[UIToolbar alloc] init] autorelease]];
    self.selectedIndexPath=nil;
}
-(void)viewWillLayoutSubviews
{
}
- (void)viewWillAppear:(BOOL)animated
{
    [self updateFileList];
}
- (void)viewDidAppear:(BOOL)animated
{
    if (self.myndsType==kMyndsTypeDefault) {
        self.editBtn=[[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editAction:)];
        self.deleteBtn=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteAction:)];
        //[self.deleteBtn setEnabled:NO];
        [self.navigationItem setRightBarButtonItems:@[self.editBtn]];
        self.isEditing=NO;
    }else if (self.myndsType==kMyndsTypeSelect)
    {
        UIBarButtonItem *ok_btn=[[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(moveFileToHere:)];
        UIBarButtonItem *cancel_btn=[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(moveCancel:)];
        [self.navigationItem setRightBarButtonItems:@[ok_btn,cancel_btn]];
        [ok_btn release];
        [cancel_btn release];
    }
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [self.fm cancelAllTask];
}
- (void)moveFileToHere:(id)sender
{
    [self.delegate moveFileToID:self.f_id];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)moveCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)deleteAction:(id)sender
{
    NSMutableArray *f_ids=[NSMutableArray array];
    for (int i=0;i<self.m_fileItems.count;i++) {
        FileItem *fileItem=[self.m_fileItems objectAtIndex:i];
        if (fileItem.checked) {
            NSDictionary *dic=[self.listArray objectAtIndex:i];
            NSString *f_id=[dic objectForKey:@"f_id"];
            [f_ids addObject:f_id];
        }
    }
    if (f_ids.count>0) {
        SCBFileManager *fm_temp=[[[SCBFileManager alloc] init] autorelease];
        fm_temp.delegate=self;
        [fm_temp removeFileWithIDs:f_ids];
    }
}
- (void)editAction:(id)sender
{
    [self hideOptionCell];
    [self setIsEditing:!self.isEditing];
    UIBarButtonItem *button = (UIBarButtonItem *)sender;
    if (self.isEditing) {
        [button setTitle:@"完成"];
        //[self.navigationItem setRightBarButtonItems:@[self.editBtn,self.deleteBtn] animated:YES];
        [self.navigationItem setLeftBarButtonItem:self.deleteBtn];
    }else
    {
        [button setTitle:@"编辑"];
        [self.navigationItem setLeftBarButtonItem:nil];
        //[self.navigationItem setRightBarButtonItems:@[self.editBtn] animated:YES];
    }
//   if (!button.selected) {
//        NDAppDelegate *appDelegate =  (NDAppDelegate *)[UIApplication sharedApplication].delegate;
//        [appDelegate clearCopyCache];
//    }
    [self setEditing:self.isEditing animated:YES];
    
    
//    [self hiddenBatchButton:m_editButton.selected];
//    m_editButton.selected = !m_editButton.selected;
    
//    [self.m_tableView.dragRefreshTableView setEditing:m_editButton.selected animated:YES];
    //[self.tableView setEditing:YES animated:YES];
    
    
//    if (m_editButton.selected) {
//        self.items = [NSMutableArray arrayWithCapacity:0];
//        for (int i=0; i<[m_listArray count]; i++) {
//            Item *item = [[Item alloc] init];
//            //     item.title = [NSString stringWithFormat:@"%d",i];
//            item.isChecked = NO;
//            [_items addObject:item];
//            [item release];
//        }
//    }
//    [self.m_tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
}
-(void)loadData
{
    [self updateFileList];
}
- (void)updateFileList
{
    NSString *dataFilePath=[YNFunctions getDataCachePath];
    dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:self.f_id]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataFilePath])
    {
        NSError *jsonParsingError=nil;
        NSData *data=[NSData dataWithContentsOfFile:dataFilePath];
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
        self.dataDic=dic;
        if (self.dataDic) {
            self.listArray=(NSArray *)[self.dataDic objectForKey:@"files"];
            NSMutableArray *a=[NSMutableArray array];
            for (int i=0; i<self.listArray.count; i++) {
                FileItem *fileItem=[[[FileItem alloc]init]autorelease];
                [a addObject:fileItem];
                [fileItem setChecked:NO];
            }
            self.m_fileItems=a;
            [self.tableView reloadData];
        }
    }
//    if (self.fm) {
//        return;
//    }
    self.fm=[[SCBFileManager alloc] init];
    [self.fm setDelegate:self];
    [self.fm openFinderWithID:self.f_id];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (self.dataDic) {
        NSArray *a= (NSArray *)[self.dataDic objectForKey:@"files"];
        if (self.selectedIndexPath) {
            return [a count]+1;
        }
        return [a count];
    }
    return 1;
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectedIndexPath && self.selectedIndexPath.row==indexPath.row+1) {
        [self hideOptionCell];
        return;
    }
    double delayInSeconds = 0.0;
    BOOL shouldAdjustInsertedRow = YES;
    if(self.selectedIndexPath) {
        NSArray *indexesToDelete = @[self.selectedIndexPath];
        if(self.selectedIndexPath.row <= indexPath.row)
            shouldAdjustInsertedRow = NO;
        self.selectedIndexPath = nil;
        delayInSeconds = 0.2;
        [tableView deleteRowsAtIndexPaths:indexesToDelete withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        if(shouldAdjustInsertedRow)
//            self.selectedIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
//        else
//            self.selectedIndexPath = indexPath;
//        [tableView insertRowsAtIndexPaths:@[self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//    });
    if(shouldAdjustInsertedRow)
    {
        self.selectedIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
    }
    else
    {
        self.selectedIndexPath = indexPath;
    }
    [tableView insertRowsAtIndexPaths:@[self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}
-(void)toRename:(id)sender
{
    NSDictionary *dic=[self.listArray objectAtIndex:self.selectedIndexPath.row-1];
    NSString *name=[dic objectForKey:@"f_name"];
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"重命名" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[alert textFieldAtIndex:0] setText:name];
    [alert show];
}
-(void)toFavorite:(id)sender
{
    NSDictionary *dic=[self.listArray objectAtIndex:self.selectedIndexPath.row-1];
    NSString *f_id=[dic objectForKey:@"f_id"];
    if ([[FavoritesData sharedFavoritesData].favoriteDic objectForKey:f_id]) {
        [[FavoritesData sharedFavoritesData] removeObjectForKey:f_id];
        NSLog(@"%@",[FavoritesData sharedFavoritesData].favoriteDic);
        NSLog(@"删除一个收藏，收藏总数: %d",[[FavoritesData sharedFavoritesData] count]);
//        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:self.selectedIndexPath.row + 1 inSection:self.selectedIndexPath.section];
//        UITableViewCell *cell=[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
//        if (cell.imageView.subviews.count>0) {
//            for (UIView *view in cell.imageView.subviews) {
//                [view removeFromSuperview];
//            }
//        }

    }else
    {
        [[FavoritesData sharedFavoritesData] setObject:dic forKey:f_id];
        NSLog(@"%@",[FavoritesData sharedFavoritesData].favoriteDic);
        NSLog(@"增加一个收藏，收藏总数: %d",[[FavoritesData sharedFavoritesData] count]);
//        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:self.selectedIndexPath.row + 1 inSection:self.selectedIndexPath.section];
//        UITableViewCell *cell=[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
//        if (cell.imageView.subviews.count==0) {
//            UIImageView *tagView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_btn_favorite.png"]];
//            CGRect r=[tagView frame];
//            r.origin.x=0;
//            r.origin.y=20;
//            [tagView setFrame:r];
//            [cell.imageView addSubview:tagView];
//        }
    }
//    [self.tableView reloadData];
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:self.selectedIndexPath.row -1 inSection:self.selectedIndexPath.section];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self hideOptionCell];
}
-(void)toDelete:(id)sender
{
    
    NSDictionary *dic=[self.listArray objectAtIndex:self.selectedIndexPath.row-1];
    NSString *f_id=[dic objectForKey:@"f_id"];
    SCBFileManager *fm_temp=[[[SCBFileManager alloc] init] autorelease];
    fm_temp.delegate=self;
    [fm_temp removeFileWithIDs:@[f_id]];
    [self hideOptionCell];
}
-(void)moveFileToID:(NSString *)f_id
{
    NSDictionary *dic=[self.listArray objectAtIndex:self.selectedIndexPath.row-1];
    NSString *m_fid=[dic objectForKey:@"f_id"];
    SCBFileManager *fm_temp=[[[SCBFileManager alloc] init] autorelease];
    fm_temp.delegate=self;
    if ([f_id intValue]!=[m_fid intValue]) {
        [fm_temp moveFileIDs:@[m_fid] toPID:f_id];
    }
    [self hideOptionCell];
}
-(void)toShared:(id)sender
{
    
    MyndsViewController *moveViewController=[[[MyndsViewController alloc] init] autorelease];
    moveViewController.f_id=@"1";
    moveViewController.myndsType=kMyndsTypeSelect;
    moveViewController.title=@"我的空间";
    moveViewController.delegate=self;
    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:moveViewController];
    [self presentViewController:nav animated:YES completion:nil];
}
-(void)hideOptionCell
{
    if(self.selectedIndexPath) {
        NSArray *indexesToDelete = @[self.selectedIndexPath];
        self.selectedIndexPath = nil;
        [self.tableView deleteRowsAtIndexPaths:indexesToDelete withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectedIndexPath && self.selectedIndexPath.row==indexPath.row && self.selectedIndexPath.section==indexPath.section) {
        static NSString *CellIdentifier = @"Option Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[FileItemTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                             reuseIdentifier:CellIdentifier] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        //cell.textLabel.text=@"收藏   分享   删除";
        UIToolbar *toolbar=[[[UIToolbar alloc] initWithFrame:cell.bounds] autorelease];
        //[toolbar setBackgroundImage:[UIImage imageNamed:@"option_bar.png"] forToolbarPosition:UIToolbarPositionTop barMetrics:UIBarMetricsDefault];
        [toolbar insertSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"option_bar.png"]] atIndex:1];
        //UIBarButtonItem *item0=[[UIBarButtonItem alloc] initWithTitle:@"重命名" style:UIBarButtonItemStyleDone target:self action:@selector(toRename:)];
        UIBarButtonItem *item0=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"option_bar_edit.png"] style:UIBarButtonItemStylePlain target:self action:@selector(toRename:)];
        [item0 setTitle:@"重命名"];
        //UIBarButtonItem *item1=[[UIBarButtonItem alloc] initWithTitle:@"收藏" style:UIBarButtonItemStyleDone target:self action:@selector(toFavorite:)];
        UIBarButtonItem *item1=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"tab_btn_favorite.png"] style:UIBarButtonItemStylePlain target:self action:@selector(toFavorite:)];
        [item1 setTitle:@"收藏"];
        //UIBarButtonItem *item2=[[UIBarButtonItem alloc] initWithTitle:@"移动" style:UIBarButtonItemStyleDone target:self action:@selector(toShared:)];
        UIBarButtonItem *item2=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"option_bar_move.png"] style:UIBarButtonItemStylePlain target:self action:@selector(toShared:)];
        [item2 setTitle:@"移动"];
        //UIBarButtonItem *item3=[[UIBarButtonItem alloc] initWithTitle:@"删除" style:UIBarButtonItemStyleDone target:self action:@selector(toDelete:)];
        UIBarButtonItem *item3=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"option_bar_remove.png"] style:UIBarButtonItemStylePlain target:self action:@selector(toDelete:)];
        [item3 setTitle:@"删除"];
        UIBarButtonItem *flexible=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        NSDictionary *this=(NSDictionary *)[self.listArray objectAtIndex:indexPath.row-1];
        NSString *t_fl = [[this objectForKey:@"f_mime"] lowercaseString];
        if ([t_fl isEqualToString:@"directory"]) {
            [toolbar setItems:@[flexible,item0,flexible,item2,flexible,item3,flexible]];
        }else
        {
            [toolbar setItems:@[flexible,item0,flexible,item1,flexible,item2,flexible,item3,flexible]];
        }
        
        [cell addSubview:toolbar];
        return cell;
    }
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[FileItemTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    int row=indexPath.row;
    if (self.selectedIndexPath && self.selectedIndexPath.row<indexPath.row) {
        row=row-1;
    }
    UILabel *label =cell.textLabel;
    NSString *text;
    if (self.dataDic) {
        NSArray *a= (NSArray *)[self.dataDic objectForKey:@"files"];
        NSDictionary *this=(NSDictionary *)[a objectAtIndex:row];
        NSString *t_fl = [[this objectForKey:@"f_mime"] lowercaseString];
        if (self.myndsType==kMyndsTypeDefault) {
            cell.accessoryType=UITableViewCellAccessoryDetailDisclosureButton;
        }else
        {
            cell.accessoryType=UITableViewCellAccessoryNone;
        }
        
//        UIButton *btn=(UIButton *)cell.accessoryView;
//        [btn setBackgroundImage:[UIImage imageNamed:@"accessory.png"] forState:UIControlStateNormal];
        FileItem* fileItem = [self.m_fileItems objectAtIndex:row];
        [cell setChecked:fileItem.checked];
        
        NSString *name= [this objectForKey:@"f_name"];
        NSString *f_modify=[this objectForKey:@"f_modify"];
        NSString *f_id=[this objectForKey:@"f_id"];
        //cell.detailTextLabel.text=f_modify;
        if ([t_fl isEqualToString:@"directory"]) {
            cell.detailTextLabel.text=f_modify;
            if (cell.imageView.subviews.count>0) {
                UIImageView *tagView=[cell.imageView.subviews objectAtIndex:0];
                [tagView setHidden:YES];
            }
        }else
        {
            NSString *f_size=[this objectForKey:@"f_size"];
            cell.detailTextLabel.text=[NSString stringWithFormat:@"%@ %@B",f_modify,[YNFunctions convertSize:f_size]];
        //是否显示收藏图标
            NSObject *tag=nil;
            tag=[[FavoritesData sharedFavoritesData] objectForKey:f_id];
            if (tag!=nil) {
                if (cell.imageView.subviews.count==0) {
                    UIImageView *tagView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_btn_favorite.png"]];
                    CGRect r=[tagView frame];
                    r.origin.x=20;
                    r.origin.y=20;
                    [tagView setFrame:r];
                    [cell.imageView addSubview:tagView];
                }
                UIImageView *tagView=[cell.imageView.subviews objectAtIndex:0];
                [tagView setHidden:NO];
            }else
            {
                if (cell.imageView.subviews.count==0) {
                    UIImageView *tagView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_btn_favorite.png"]];
                    CGRect r=[tagView frame];
                    r.origin.x=20;
                    r.origin.y=20;
                    [tagView setFrame:r];
                    [cell.imageView addSubview:tagView];
                }
                UIImageView *tagView=[cell.imageView.subviews objectAtIndex:0];
                [tagView setHidden:YES];
            }

        }
        text=name;
        
        if ([t_fl isEqualToString:@"directory"]) {
            cell.imageView.image = [UIImage imageNamed:@"icon_Folder.png"];
        }else if ([t_fl isEqualToString:@"png"]||
                  [t_fl isEqualToString:@"jpg"]||
                  [t_fl isEqualToString:@"jpeg"]||
                  [t_fl isEqualToString:@"bmp"])
        {
            NSDictionary *dic = [self.listArray objectAtIndex:indexPath.row];
            NSString *compressaddr=[dic objectForKey:@"compressaddr"];
            compressaddr =[YNFunctions picFileNameFromURL:compressaddr];
            NSString *path=[YNFunctions getIconCachePath];
            path=[path stringByAppendingPathComponent:compressaddr];
            
            //"compressaddr":"cimage/cs860183fc-81bd-40c2-817a-59653d0dc513.jpg"
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) // avoid the app icon download if the app already has an icon
            {
                //UIImageView *tagView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:path]];
                UIImage *icon=[UIImage imageWithContentsOfFile:path];
                CGSize itemSize = CGSizeMake(40, 40);
                UIGraphicsBeginImageContext(itemSize);
                CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
                [icon drawInRect:imageRect];
                UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                cell.imageView.image = image;
            }else
            {
                [self startIconDownload:dic forIndexPath:indexPath];
                cell.imageView.image = [UIImage imageNamed:@"icon_pic.png"];
            }
        }else if ([t_fl isEqualToString:@"doc"]||
                  [t_fl isEqualToString:@"docx"])
        {
            cell.imageView.image = [UIImage imageNamed:@"icon_doc.png"];
        }else if ([t_fl isEqualToString:@"mp3"])
        {
            cell.imageView.image = [UIImage imageNamed:@"icon_music.png"];
        }else if ([t_fl isEqualToString:@"mov"])
        {
            cell.imageView.image = [UIImage imageNamed:@"icon_movie.png"];
        }else if ([t_fl isEqualToString:@"ppt"])
        {
            cell.imageView.image = [UIImage imageNamed:@"icon_ppt.png"];
        }else
        {
            cell.imageView.image = [UIImage imageNamed:@"icon_unkown.png"];
        }
        
    }else
    {
        text = @"加载中...";
    }
    label.text=text;
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}
// Override to support conditional editing of the table view.
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Return NO if you do not want the specified item to be editable.
//    return YES;
//}


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"Nib name" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    if (self.selectedIndexPath) {
        [self hideOptionCell];
        return;
    }
    
    if (self.dataDic==Nil) {
        return;
    }
    if (self.isEditing) {
        FileItem* fileItem = [self.m_fileItems objectAtIndex:indexPath.row];
        FileItemTableCell *cell = (FileItemTableCell*)[tableView cellForRowAtIndexPath:indexPath];
		fileItem.checked = !fileItem.checked;
		[cell setChecked:fileItem.checked];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    NSDictionary *dic=[self.listArray objectAtIndex:indexPath.row];
    NSString *f_name=[dic objectForKey:@"f_name"];
    NSString *f_id=[dic objectForKey:@"f_id"];
    NSString *f_mime=[[dic objectForKey:@"f_mime"] lowercaseString];
    if ([f_mime isEqualToString:@"directory"]) {
        MyndsViewController *viewController =[[[MyndsViewController alloc] init] autorelease];
        viewController.f_id=f_id;
        viewController.myndsType=self.myndsType;
        if (self.myndsType==kMyndsTypeSelect){
            viewController.delegate=self.delegate;
        }
        [self.navigationController pushViewController:viewController animated:YES];
        viewController.title=f_name;
    }else
    {
        if (self.myndsType!=kMyndsTypeDefault) {
            return;
        }
        if ([f_mime isEqualToString:@"png"]||
            [f_mime isEqualToString:@"jpg"]||
            [f_mime isEqualToString:@"jpeg"]||
            [f_mime isEqualToString:@"bmp"]) {
            NSMutableArray *array=[NSMutableArray array];
            int index=0;
            for (int i=0;i<self.listArray.count;i++) {
                NSDictionary *dict=[self.listArray objectAtIndex:i];
                NSString *f_mime=[[dict objectForKey:@"f_mime"] lowercaseString];
                if ([f_mime isEqualToString:@"png"]||
                    [f_mime isEqualToString:@"jpg"]||
                    [f_mime isEqualToString:@"jpeg"]||
                    [f_mime isEqualToString:@"bmp"]) {
                    PhohoDemo *photo_demo=[[PhohoDemo alloc] init];
                    [photo_demo setF_mime:[dict objectForKey:@"f_mime"]];
                    [photo_demo setF_size:[[dict objectForKey:@"f_size"] intValue]];
                    [photo_demo setF_name:[dict objectForKey:@"f_name"]];
                    [photo_demo setF_pid:[[dict objectForKey:@"f_pid"] intValue]];
                    if([[dict objectForKey:@"img_create"] isKindOfClass:[NSString class]])
                    {
                        [photo_demo setImg_create:[dict objectForKey:@"img_create"]];
                    }
                    
                    [photo_demo setF_create:[dict objectForKey:@"f_create"]];
                    [photo_demo setF_id:[[dict objectForKey:@"f_id"] intValue]];
                    [photo_demo setF_mime:[dict objectForKey:@"f_modify"]];
                    [photo_demo setCompressaddr:[dict objectForKey:@"compressaddr"]];
                    [photo_demo setF_ownerid:[[dict objectForKey:@"f_ownerid"] intValue]];
                    [array addObject:photo_demo];
                    if (i==indexPath.row) {
                        index=array.count-1;
                    }
                    [photo_demo release];
                }
            }
            PhotoDetailViewController *photoDetalViewController = [[PhotoDetailViewController alloc] init];
            photoDetalViewController.deleteDelegate = self;
            [self presentViewController:photoDetalViewController animated:YES completion:^{
                //[photoDetalViewController setTimeLine:image_button.timeLine];
                [photoDetalViewController loadAllDiction:array currtimeIdexTag:index];
                [photoDetalViewController release];
            }];

        }
//        ImageBrowserViewController *browser=[[[ImageBrowserViewController alloc] init] autorelease];
//        browser.listArray=self.listArray;
//        browser.index=indexPath.row;
//        if (self.navigationController.navigationBarHidden) {
//            [self.navigationController setNavigationBarHidden:NO animated:YES];
//        }else
//        {
//            [self.navigationController setNavigationBarHidden:YES animated:YES];
//        }
//        [self.navigationController pushViewController:browser animated:YES];
        //[self.tabBarController.tabBar setHidden:YES];
    }
}

#pragma mark - SCBFileManagerDelegate
-(void)openFinderSucess:(NSDictionary *)datadic
{
    self.dataDic=datadic;
    self.listArray=(NSArray *)[self.dataDic objectForKey:@"files"];
    NSMutableArray *a=[NSMutableArray array];
    for (int i=0; i<self.listArray.count; i++) {
        FileItem *fileItem=[[[FileItem alloc]init]autorelease];
        [a addObject:fileItem];
        [fileItem setChecked:NO];
    }
    self.m_fileItems=a;
    if (self.dataDic) {
        [self.tableView reloadData];
    }else
    {
        [self updateFileList];
    }
    NSLog(@"openFinderSucess:");
    if (self.dataDic)
    {
        NSString *dataFilePath=[YNFunctions getDataCachePath];
        dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:self.f_id]];
        
        NSError *jsonParsingError=nil;
        NSData *data=[NSJSONSerialization dataWithJSONObject:self.dataDic options:0 error:&jsonParsingError];
        BOOL isWrite=[data writeToFile:dataFilePath atomically:YES];
        if (isWrite) {
            NSLog(@"写入文件成功：%@",dataFilePath);
        }else
        {
            NSLog(@"写入文件失败：%@",dataFilePath);
        }
    }

}
-(void)openFinderUnsucess
{
    NSLog(@"openFinderUnsucess: 网络连接失败!!");
}
-(void)removeSucess
{
    [self updateFileList];
    if (!self.hud) {
        self.hud=[[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:self.hud];
    }
    [self.hud show:NO];
    self.hud.labelText=@"删除成功！";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:0.5f];
}
-(void)renameSucess
{
    [self updateFileList];
}
-(void)renameUnsucess
{
    NSLog(@"openFinderUnsucess: 网络连接失败!!");
}
-(void)moveSucess
{
    [self updateFileList];
}
#pragma mark - UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
        NSDictionary *dic=[self.listArray objectAtIndex:self.selectedIndexPath.row-1];
        NSString *name=[dic objectForKey:@"f_name"];
        NSString *f_id=[dic objectForKey:@"f_id"];
        NSString *fildtext=[[alertView textFieldAtIndex:0] text];
        if (![fildtext isEqualToString:name]) {
            NSLog(@"重命名");
            SCBFileManager *fm=[[[SCBFileManager alloc] init] autorelease];
            [fm renameWithID:f_id newName:fildtext];
            [fm setDelegate:self];
        }
        NSLog(@"点击确定");
    }else
    {
        NSLog(@"点击其它");
    }
    [self hideOptionCell];
}
#pragma mark -
#pragma mark Deferred image loading (UIScrollViewDelegate)

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    if ([self.listArray count] > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            NSDictionary *dic = [self.listArray objectAtIndex:indexPath.row];
            NSString *compressaddr=[dic objectForKey:@"compressaddr"];
            compressaddr =[YNFunctions picFileNameFromURL:compressaddr];
            NSString *path=[YNFunctions getIconCachePath];
            path=[path stringByAppendingPathComponent:compressaddr];
            
            //"compressaddr":"cimage/cs860183fc-81bd-40c2-817a-59653d0dc513.jpg"
            if (![[NSFileManager defaultManager] fileExistsAtPath:path]) // avoid the app icon download if the app already has an icon
            {
                [self startIconDownload:dic forIndexPath:indexPath];
            }
        }
    }
}
- (void)startIconDownload:(NSDictionary *)dic forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil)
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.data_dic=dic;
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        [self.imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
        [iconDownloader startDownload];
        [iconDownloader release];
    }
}
- (void)appImageDidLoad:(NSIndexPath *)indexPath;
{
    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader != nil)
    {        
        [self.tableView reloadRowsAtIndexPaths:@[iconDownloader.indexPathInTableView] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    // Remove the IconDownloader from the in progress list.
    // This will result in it being deallocated.
    [self.imageDownloadsInProgress removeObjectForKey:indexPath];
}
@end
