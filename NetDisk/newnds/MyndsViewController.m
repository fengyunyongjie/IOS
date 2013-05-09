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
@property (assign,nonatomic) BOOL isEditing;
@property (strong,nonatomic) NSMutableArray *m_fileItems;
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
    
    [super viewDidLoad];
    self.optionCell=[[[UITableViewCell alloc] init] autorelease];
    self.selectedIndexPath=nil;
    self.editBtn=[[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStyleDone target:self action:@selector(editAction:)];
    [self.navigationItem setRightBarButtonItem:self.editBtn];
    self.isEditing=NO;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
}
-(void)viewWillDisappear:(BOOL)animated
{
    [self.fm cancelAllTask];
}
- (void)editAction:(id)sender
{
    [self setIsEditing:!self.isEditing];
    UIBarButtonItem *button = (UIBarButtonItem *)sender;
    if (self.isEditing) {
        [button setTitle:@"完成"];
    }else
    {
        [button setTitle:@"编辑"];
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
    if (self.dataDic) {
        [self.tableView reloadData];
        return;
    }
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
    if (self.fm) {
        return;
    }
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
        }else
        {
            return [a count];
        }
    }
    return 1;
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
//    double delayInSeconds = 0.2;
//    BOOL shouldAdjustInsertedRow = YES;
//    if(self.selectedIndexPath && self.selectedIndexPath.row == indexPath.row) {
//        shouldAdjustInsertedRow = NO;
//        self.selectedIndexPath = nil;
//    }else
//    {
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            if(shouldAdjustInsertedRow)
//                self.selectedIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
//            else
//                self.selectedIndexPath = indexPath;
//            [tableView insertRowsAtIndexPaths:@[self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//        });
//    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectedIndexPath && self.selectedIndexPath.row==indexPath.row && self.selectedIndexPath.section==indexPath.section) {
        return self.optionCell;
    }
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[FileItemTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    UILabel *label =cell.textLabel;
    NSString *text;
    if (self.dataDic) {
        NSArray *a= (NSArray *)[self.dataDic objectForKey:@"files"];
        NSDictionary *this=(NSDictionary *)[a objectAtIndex:indexPath.row];
        NSString *t_fl = [[this objectForKey:@"f_mime"] lowercaseString];
        cell.accessoryType=UITableViewCellAccessoryDetailDisclosureButton;
        FileItem* fileItem = [self.m_fileItems objectAtIndex:indexPath.row];
        [cell setChecked:fileItem.checked];
        
        NSString *name= [this objectForKey:@"f_name"];
        NSString *f_modify=[this objectForKey:@"f_modify"];
        cell.detailTextLabel.text=f_modify;
//        if ([t_fl isEqualToString:@"directory"]) {
//            cell.detailTextLabel.text=f_modify;
//        }else
//        {
//            NSString *f_size=[this objectForKey:@"f_size"];
//            cell.detailTextLabel.text=[NSString stringWithFormat:@"%@ %@B",f_modify,f_size];
//        }
        text=name;
        if ([t_fl isEqualToString:@"directory"]) {
            cell.imageView.image = [UIImage imageNamed:@"icon_Folder.png"];  
        }else if ([t_fl isEqualToString:@"png"]||
                  [t_fl isEqualToString:@"jpg"]||
                  [t_fl isEqualToString:@"jpeg"]||
                  [t_fl isEqualToString:@"bmp"])
        {
            cell.imageView.image = [UIImage imageNamed:@"icon_pic.png"];
            
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
    CGRect cellFrame = [cell frame];
    cellFrame.origin = CGPointMake(0, 0);
    
    label.text = text;
    CGRect rect = CGRectInset(cellFrame, 2, 2);
    label.frame = rect;
    [label sizeToFit];
    if (label.frame.size.height > 46) {
        cellFrame.size.height = 50 + label.frame.size.height - 46;
    }
    else {
        cellFrame.size.height = 50;
    }
    [cell setFrame:cellFrame];
    
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
        [self.navigationController pushViewController:viewController animated:YES];
        viewController.title=f_name;
    }else
    {
        AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        UIViewController *viewController=[[[UIViewController alloc] init] autorelease];
        [self.navigationController pushViewController:viewController animated:YES];
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
@end
