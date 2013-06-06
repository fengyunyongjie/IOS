//
//  FavoritesViewController.m
//  NetDisk
//
//  Created by fengyongning on 13-5-16.
//
//

#import "FavoritesViewController.h"
#import "FavoritesData.h"
#import "PhotoLookViewController.h"
#import "YNFunctions.h"
#import "IconDownloader.h"
#import "OtherBrowserViewController.h"
#import "PhotoFile.h"
@interface FavoritesViewController ()

@end

@implementation FavoritesViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)dealloc
{
    [super dealloc];
    self.imageDownloadsInProgress=nil;
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    [self setHidesBottomBarWhenPushed:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[FavoritesData sharedFavoritesData] reloadData];
    [self.tableView reloadData];
    [super viewDidAppear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    int count=[[FavoritesData sharedFavoritesData] count];
    return count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                         reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text=@"fane";
    NSDictionary *dic=[[[FavoritesData sharedFavoritesData] allValues] objectAtIndex:indexPath.row];
    NSString *name= [dic objectForKey:@"f_name"];
    //NSString *f_modify=[dic objectForKey:@"f_modify"];
    NSString *t_fl = [[dic objectForKey:@"f_mime"] lowercaseString];
    cell.textLabel.text=name;
    NSString *f_size=[dic objectForKey:@"f_size"];
    cell.detailTextLabel.text=[NSString stringWithFormat:@"%@",[YNFunctions convertSize:f_size]];
    //cell.detailTextLabel.text=f_modify;
    if (cell.imageView.subviews.count==0) {
        UIImageView *tagView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"favorite_tag.png"]];
        CGRect r=[tagView frame];
        r.origin.x=20;
        r.origin.y=20;
        [tagView setFrame:r];
        [cell.imageView addSubview:tagView];
    }
//    UIImageView *tagView=[cell.imageView.subviews objectAtIndex:0];
    
    if ([t_fl isEqualToString:@"directory"]) {
        cell.imageView.image = [UIImage imageNamed:@"icon_Folder.png"];
    }else if ([t_fl isEqualToString:@"png"]||
              [t_fl isEqualToString:@"jpg"]||
              [t_fl isEqualToString:@"jpeg"]||
              [t_fl isEqualToString:@"bmp"])
    {
        //NSDictionary *dic = [self.listArray objectAtIndex:indexPath.row];
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
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSArray *listArray=[[FavoritesData sharedFavoritesData] allValues];
        NSDictionary *dic=[listArray objectAtIndex:indexPath.row];
        NSString *f_id=[dic objectForKey:@"f_id"];
        [[FavoritesData sharedFavoritesData] removeObjectForKey:f_id];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


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
    NSArray *listArray=[[FavoritesData sharedFavoritesData] allValues];
    NSDictionary *dic=[listArray objectAtIndex:indexPath.row];
    NSString *f_mime=[[dic objectForKey:@"f_mime"] lowercaseString];
    if ([f_mime isEqualToString:@"png"]||
        [f_mime isEqualToString:@"jpg"]||
        [f_mime isEqualToString:@"jpeg"]||
        [f_mime isEqualToString:@"bmp"]) {
        NSMutableArray *array=[NSMutableArray array];
        int index=0;
        for (int i=0;i<listArray.count;i++) {
            NSDictionary *dict=[listArray objectAtIndex:i];
            NSString *f_mime=[[dict objectForKey:@"f_mime"] lowercaseString];
            if ([f_mime isEqualToString:@"png"]||
                [f_mime isEqualToString:@"jpg"]||
                [f_mime isEqualToString:@"jpeg"]||
                [f_mime isEqualToString:@"bmp"]) {
                PhotoFile *demo = [[PhotoFile alloc] init];
                [demo setF_date:[dict objectForKey:@"f_create"]];
                [demo setF_id:[[dict objectForKey:@"f_id"] intValue]];
                [array addObject:demo];
                if (i==indexPath.row) {
                    index=array.count-1;
                }
                [demo release];
            }
        }
        PhotoLookViewController *photoLookViewController = [[PhotoLookViewController alloc] init];
        [photoLookViewController setHidesBottomBarWhenPushed:YES];
        [photoLookViewController setIsCliped:YES];
        [photoLookViewController setCurrPage:index];
        [photoLookViewController setTableArray:array];
        [self.navigationController pushViewController:photoLookViewController animated:YES];
        [photoLookViewController release];
    }else
    {
        if ([YNFunctions isUnlockFeature]) {
            OtherBrowserViewController *otherBrowser=[[[OtherBrowserViewController alloc] initWithNibName:@"OtherBrowser" bundle:nil]  autorelease];
            [otherBrowser setHidesBottomBarWhenPushed:YES];
            otherBrowser.dataDic=dic;
            NSString *f_name=[dic objectForKey:@"f_name"];
            otherBrowser.title=f_name;
            [self.navigationController pushViewController:otherBrowser animated:YES];
        }
    }

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
    NSArray *listArray=[[FavoritesData sharedFavoritesData] allValues];
    if ([listArray count] > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            NSDictionary *dic = [listArray objectAtIndex:indexPath.row];
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
