//
//  FavoritesViewController.m
//  NetDisk
//
//  Created by fengyongning on 13-5-16.
//
//

#import "FavoritesViewController.h"
#import "FavoritesData.h"

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

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (void)viewDidAppear:(BOOL)animated
{
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
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
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
    NSDictionary *dic=[[[[FavoritesData sharedFavoritesData] favoriteDic] allValues] objectAtIndex:indexPath.row];
    NSString *name= [dic objectForKey:@"f_name"];
    NSString *f_modify=[dic objectForKey:@"f_modify"];
    NSString *t_fl = [[dic objectForKey:@"f_mime"] lowercaseString];
    cell.textLabel.text=name;
    cell.detailTextLabel.text=f_modify;
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
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

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
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
