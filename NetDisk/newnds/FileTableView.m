//
//  FileTableView.m
//  NetDisk
//
//  Created by Yangsl on 13-8-22.
//
//

#import "FileTableView.h"
#import "YNFunctions.h"
#import "SCBSession.h"
#import "PhotoFile.h"
#import "PhotoLookViewController.h"
#import "FavoritesData.h"
#import "FileTableViewCell.h"

#define kAlertTagRename 1001
#define kAlertTagDeleteOne 1002
#define FileTableViewCellTag 30000
#define FileTableViewCellCehckTag 30000
#define CheckButtonColor [UIColor colorWithRed:223.0/255.0 green:230.0/255.0 blue:250.0/255.0 alpha:1.0]

@implementation FileTableView
@synthesize photoManager;
@synthesize upDictionary;
@synthesize tableArray;
@synthesize tableDictionary;
@synthesize folderMenu;
@synthesize fileMenu;
@synthesize escButton;
@synthesize allHeight;
@synthesize file_delegate;
@synthesize selectedIndexPath;
@synthesize fileManager;
@synthesize linkManager;
@synthesize p_id;
@synthesize selected_dictionary;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    
    photoManager = [[SCBPhotoManager alloc] init];
    [photoManager setNewFoldDelegate:self];
    fileManager = [[SCBFileManager alloc] init];
    fileManager.delegate = self;
    linkManager = [[SCBLinkManager alloc] init];
    linkManager.delegate = self;
    tableDictionary = [[NSMutableDictionary alloc] init];
    self.dataSource = self;
    self.delegate = self;
    
    return self;
}

#pragma mark NewFoldDelegate ------------------

-(void)newFold:(NSDictionary *)dictionary
{
    
}

-(void)openFile:(NSDictionary *)dictionary
{
    NSDate *now3 = [NSDate new];
    NSLog(@"now3:%@",now3);
    int number = [[dictionary objectForKey:@"code"] intValue];
    if(number == 0)
    {
        if(tableArray == nil)
        {
            tableArray = [[NSMutableArray alloc] initWithArray:[dictionary objectForKey:@"files"]];
        }
        else
        {
            [tableArray removeAllObjects];
            [tableArray addObjectsFromArray:[dictionary objectForKey:@"files"]];
        }
    }
    [self reloadData];
}

//上传失败
-(void)didFailWithError
{
    
}


#pragma mark UITableViewDelegate ------------------

-(NSInteger)numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellString = @"cellstring";
    FileTableViewCell *cell = [self dequeueReusableCellWithIdentifier:cellString];
    if(cell == nil)
    {
        cell = [[[FileTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellString] autorelease];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.accessoryType=UITableViewCellAccessoryDetailDisclosureButton;
    }
    
    NSDictionary *dictioinary = [tableArray objectAtIndex:[indexPath row]];
    NSString *f_mime = [dictioinary objectForKey:@"f_mime"];
    NSString *f_id = [dictioinary objectForKey:@"f_id"];
    NSString *name= [dictioinary objectForKey:@"f_name"];
    NSString *f_modify=[dictioinary objectForKey:@"f_modify"];
    cell.textLabel.text=name;
    cell.detailTextLabel.text=f_modify;
    
    if ([f_mime isEqualToString:@"directory"]) {
        cell.imageView.image = [UIImage imageNamed:@"Ico_FolderF.png"];
    }else if([f_mime isEqualToString:@"PNG"]||
             [f_mime isEqualToString:@"JPG"]||
             [f_mime isEqualToString:@"JPEG"]||
             [f_mime isEqualToString:@"BMP"]||
             [f_mime isEqualToString:@"GIF"])
    {
        NSString *path = [self get_image_save_file_path:[NSString stringWithFormat:@"%@",f_id]];
        
        //"compressaddr":"cimage/cs860183fc-81bd-40c2-817a-59653d0dc513.jpg"
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) // avoid the app icon download if the app already has an icon
        {
            //UIImageView *tagView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:path]];
            UIImage *icon=[UIImage imageWithContentsOfFile:path];
            CGSize itemSize = CGSizeMake(160, 100);
            UIGraphicsBeginImageContext(itemSize);
            CGRect theR=CGRectMake(0, 0, itemSize.width, itemSize.height);
            if (icon.size.width>icon.size.height) {
                theR.size.width=icon.size.width/(icon.size.height/itemSize.height);
                theR.origin.x=-(theR.size.width/2)-itemSize.width;
            }else
            {
                theR.size.height=icon.size.height/(icon.size.width/itemSize.width);
                theR.origin.y=-(theR.size.height/2)-itemSize.height;
            }
            CGRect imageRect = CGRectMake(35, 5, 90, 90);
            [icon drawInRect:imageRect];
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            cell.imageView.image = image;
        }
        else
        {
            [self startDownLoad:f_id indexPath:indexPath];
            cell.imageView.image = [UIImage imageNamed:@"Ico_PicF.png"];
        }
    }else if ([f_mime isEqualToString:@"doc"]||
              [f_mime isEqualToString:@"docx"])
    {
        cell.imageView.image = [UIImage imageNamed:@"Ico_DocF.png"];
    }else if ([f_mime isEqualToString:@"mp3"])
    {
        cell.imageView.image = [UIImage imageNamed:@"Ico_MusicF.png"];
    }else if ([f_mime isEqualToString:@"mov"])
    {
        cell.imageView.image = [UIImage imageNamed:@"Ico_MovF.png"];
    }else if ([f_mime isEqualToString:@"ppt"])
    {
        cell.imageView.image = [UIImage imageNamed:@"icon_ppt.png"];
    }else
    {
        cell.imageView.image = [UIImage imageNamed:@"Ico_OtherF.png"];
    }
    
    //是否显示收藏图标
    BOOL bl = [[FavoritesData sharedFavoritesData] isExistsWithFID:f_id];
    if (bl) {
        if (cell.imageView.subviews.count==0) {
            UIImageView *tagView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Ico_CoverF.png"]];
            CGRect r=[tagView frame];
            r.origin.x=15;
            r.origin.y=25;
            [tagView setFrame:r];
            [cell.imageView addSubview:tagView];
        }
        UIImageView *tagView=[cell.imageView.subviews objectAtIndex:0];
        [tagView setHidden:NO];
    }
    else
    {
        if (cell.imageView.subviews.count==0) {
            UIImageView *tagView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Ico_CoverF.png"]];
            CGRect r=[tagView frame];
            r.origin.x=15;
            r.origin.y=25;
            [tagView setFrame:r];
            [cell.imageView addSubview:tagView];
        }
        UIImageView *tagView=[cell.imageView.subviews objectAtIndex:0];
        [tagView setHidden:YES];
    }
    cell.tag = FileTableViewCellTag+indexPath.row;
    return cell;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath\n\n\n----------------------------------------------------------------------------------------");
    NSDictionary *dictioinary = [tableArray objectAtIndex:[indexPath row]];
    upDictionary = dictioinary;
    NSString *f_mime = [dictioinary objectForKey:@"f_mime"];
    NSString *f_id = [dictioinary objectForKey:@"f_id"];
    if ([f_mime isEqualToString:@"directory"]) {
        [file_delegate downController:f_id];
    }
    else if([f_mime isEqualToString:@"PNG"]||
            [f_mime isEqualToString:@"JPG"]||
            [f_mime isEqualToString:@"JPEG"]||
            [f_mime isEqualToString:@"BMP"]||
            [f_mime isEqualToString:@"GIF"])
    {
        NSMutableArray *array=[NSMutableArray array];
        int index=0;
        for (int i=0;i<tableArray.count;i++) {
            NSDictionary *dict=[tableArray objectAtIndex:i];
            NSString *f_mime=[[dict objectForKey:@"f_mime"] lowercaseString];
            if ([f_mime isEqualToString:@"png"]||
                [f_mime isEqualToString:@"jpg"]||
                [f_mime isEqualToString:@"jpeg"]||
                [f_mime isEqualToString:@"bmp"]||
                [f_mime isEqualToString:@"gif"]) {
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
        [file_delegate showFile:index array:array];
    }
    else
    {
        [file_delegate showAllFile:nil];
    }
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    selectedIndexPath = indexPath;
    if(escButton == nil)
    {
        CGRect rect = CGRectMake(0, 0, 320, allHeight);
        escButton = [[UIButton alloc] initWithFrame:rect];
        [escButton addTarget:self action:@selector(EscMenu) forControlEvents:UIControlEventTouchDown];
        [self addSubview:escButton];
    }
    else
    {
        escButton.hidden = NO;
    }
    
    NSDictionary *dictioinary = [tableArray objectAtIndex:[indexPath row]];
    NSString *f_mime = [dictioinary objectForKey:@"f_mime"];
    if ([f_mime isEqualToString:@"directory"])
    {
        [self showFolder:indexPath];
    }
    else
    {
        [self showFileload:indexPath];
    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

#pragma mark 文件夹点击状态

-(void)showFolder:(NSIndexPath *)indexPath
{
    if(folderMenu == nil)
    {
        //表格操作菜单
        folderMenu = [[CustomControl alloc] init];
        folderMenu.frame=CGRectMake(0, 70, 320, 65);
        UIImageView *imageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Bk_OptionBar.png" ]];
        imageView.frame=CGRectMake(0, 0, 320, 65);
        [imageView setTag:2012];
        [folderMenu addSubview:imageView];
        
        //移动按钮
        UIButton *btnMove=[UIButton buttonWithType:UIButtonTypeCustom];
        btnMove.frame=CGRectMake(10, 8, 60, 60);
        [btnMove setImage:[UIImage imageNamed:@"Bt_MoveF.png"] forState:UIControlStateNormal];
        [btnMove addTarget:self action:@selector(toMove:) forControlEvents:UIControlEventTouchUpInside];
        [folderMenu addSubview:btnMove];
        UILabel *lblMove=[[[UILabel alloc] init] autorelease];
        lblMove.text=@"移动";
        lblMove.textAlignment=UITextAlignmentCenter;
        lblMove.font=[UIFont systemFontOfSize:12];
        lblMove.textColor=[UIColor whiteColor];
        lblMove.backgroundColor=[UIColor clearColor];
        lblMove.frame=CGRectMake(19, 45, 42, 21);
        [folderMenu addSubview:lblMove];
        
        //重命名按钮
        UIButton *btnRename=[UIButton buttonWithType:UIButtonTypeCustom];
        btnRename.frame=CGRectMake(130, 8, 60, 60);
        [btnRename setImage:[UIImage imageNamed:@"Bt_RenameF.png"] forState:UIControlStateNormal];
        [btnRename addTarget:self action:@selector(toRename:) forControlEvents:UIControlEventTouchUpInside];
        [folderMenu addSubview:btnRename];
        UILabel *lblRename=[[[UILabel alloc] init] autorelease];
        lblRename.text=@"重命名";
        lblRename.textAlignment=UITextAlignmentCenter;
        lblRename.font=[UIFont systemFontOfSize:12];
        lblRename.textColor=[UIColor whiteColor];
        lblRename.backgroundColor=[UIColor clearColor];
        lblRename.frame=CGRectMake(139, 45, 42, 21);
        [folderMenu addSubview:lblRename];
        
        //删除按钮
        UIButton *btnDel=[UIButton buttonWithType:UIButtonTypeCustom];
        btnDel.frame=CGRectMake(250, 8, 60, 60);
        [btnDel setImage:[UIImage imageNamed:@"Bt_DelF.png"] forState:UIControlStateNormal];
        [btnDel addTarget:self action:@selector(toDelete:) forControlEvents:UIControlEventTouchUpInside];
        [folderMenu addSubview:btnDel];
        UILabel *lblDel=[[[UILabel alloc] init] autorelease];
        lblDel.text=@"删除";
        lblDel.textAlignment=UITextAlignmentCenter;
        lblDel.font=[UIFont systemFontOfSize:12];
        lblDel.textColor=[UIColor whiteColor];
        lblDel.backgroundColor=[UIColor clearColor];
        lblDel.frame=CGRectMake(259, 45, 42, 21);
        [folderMenu addSubview:lblDel];
        
        [self addSubview:folderMenu];
    }
    
    CGRect r=folderMenu.frame;
    r.origin.y=(indexPath.row+1) * 50-8;
    if (r.origin.y+r.size.height>self.frame.size.height &&r.origin.y+r.size.height > self.contentSize.height) {
        r.origin.y=(indexPath.row+1)*50-r.size.height-50;
        UIImageView *imageView=(UIImageView *)[folderMenu viewWithTag:2012];
        imageView.transform=CGAffineTransformMakeScale(1.0, -1.0);
        CGRect r=imageView.frame;
        r.origin.y=10;
        imageView.frame=r;
    }else
    {
        UIImageView *imageView=(UIImageView *)[folderMenu viewWithTag:2012];
        imageView.transform=CGAffineTransformMakeScale(1.0, 1.0);
        CGRect r=imageView.frame;
        r.origin.y=0;
        imageView.frame=r;
        [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    folderMenu.frame=r;
    folderMenu.indexPath = indexPath;
    folderMenu.hidden = NO;
    fileMenu.hidden = YES;
}

#pragma mark 文件点击状态

-(void)showFileload:(NSIndexPath *)indexPath
{
    if(fileMenu == nil)
    {
        //表格操作菜单
        fileMenu=[[CustomControl alloc] init];
        fileMenu.frame=CGRectMake(0, 70, 320, 65);
        UIImageView *imageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Bk_OptionBar.png" ]];
        imageView.frame=CGRectMake(0, 0, 320, 65);
        [imageView setTag:2012];
        [fileMenu addSubview:imageView];
        
        //下载按钮
        UIButton *btnDownload=[UIButton buttonWithType:UIButtonTypeCustom];
        btnDownload.frame=CGRectMake(10, 8, 60, 60);
        [btnDownload setImage:[UIImage imageNamed:@"Bt_DownloadF.png"] forState:UIControlStateNormal];
        [btnDownload addTarget:self action:@selector(toFavorite:) forControlEvents:UIControlEventTouchUpInside];
        [fileMenu addSubview:btnDownload];
        UILabel *lblDownload=[[[UILabel alloc] init] autorelease];
        lblDownload.text=@"下载";
        lblDownload.textAlignment=UITextAlignmentCenter;
        lblDownload.font=[UIFont systemFontOfSize:12];
        lblDownload.textColor=[UIColor whiteColor];
        lblDownload.backgroundColor=[UIColor clearColor];
        lblDownload.frame=CGRectMake(19, 45, 42, 21);
        [fileMenu addSubview:lblDownload];
        //分享按钮
        UIButton *btnShare=[UIButton buttonWithType:UIButtonTypeCustom];
        btnShare.frame=CGRectMake(90, 8, 60, 60);
        [btnShare setImage:[UIImage imageNamed:@"Bt_ShareF.png"] forState:UIControlStateNormal];
        [btnShare addTarget:self action:@selector(toShared:) forControlEvents:UIControlEventTouchUpInside];
        [fileMenu addSubview:btnShare];
        UILabel *lblShare=[[[UILabel alloc] init] autorelease];
        lblShare.text=@"分享";
        lblShare.textAlignment=UITextAlignmentCenter;
        lblShare.font=[UIFont systemFontOfSize:12];
        lblShare.textColor=[UIColor whiteColor];
        lblShare.backgroundColor=[UIColor clearColor];
        lblShare.frame=CGRectMake(99, 45, 42, 21);
        [fileMenu addSubview:lblShare];
        //删除按钮
        UIButton *btnDel=[UIButton buttonWithType:UIButtonTypeCustom];
        btnDel.frame=CGRectMake(170, 8, 60, 60);
        [btnDel setImage:[UIImage imageNamed:@"Bt_DelF.png"] forState:UIControlStateNormal];
        [btnDel addTarget:self action:@selector(toDelete:) forControlEvents:UIControlEventTouchUpInside];
        [fileMenu addSubview:btnDel];
        UILabel *lblDel=[[[UILabel alloc] init] autorelease];
        lblDel.text=@"删除";
        lblDel.textAlignment=UITextAlignmentCenter;
        lblDel.font=[UIFont systemFontOfSize:12];
        lblDel.textColor=[UIColor whiteColor];
        lblDel.backgroundColor=[UIColor clearColor];
        lblDel.frame=CGRectMake(179, 45, 42, 21);
        [fileMenu addSubview:lblDel];
        //更多按钮
        UIButton *btnMore=[UIButton buttonWithType:UIButtonTypeCustom];
        btnMore.frame=CGRectMake(250, 8, 60, 60);
        [btnMore setImage:[UIImage imageNamed:@"Bt_MoreF.png"] forState:UIControlStateNormal];
        [btnMore addTarget:self action:@selector(toMore:) forControlEvents:UIControlEventTouchUpInside];
        [fileMenu addSubview:btnMore];
        UILabel *lblMore=[[[UILabel alloc] init] autorelease];
        lblMore.text=@"更多";
        lblMore.textAlignment=UITextAlignmentCenter;
        lblMore.font=[UIFont systemFontOfSize:12];
        lblMore.textColor=[UIColor whiteColor];
        lblMore.backgroundColor=[UIColor clearColor];
        lblMore.frame=CGRectMake(259, 45, 42, 21);
        [fileMenu addSubview:lblMore];
        
        [self addSubview:fileMenu];
    }
    CGRect r=fileMenu.frame;
    r.origin.y=(indexPath.row+1) * 50-8;
    if (r.origin.y+r.size.height>self.frame.size.height &&r.origin.y+r.size.height > self.contentSize.height) {
        r.origin.y=(indexPath.row+1)*50-r.size.height-50;
        UIImageView *imageView=(UIImageView *)[fileMenu viewWithTag:2012];
        imageView.transform=CGAffineTransformMakeScale(1.0, -1.0);
        CGRect r=imageView.frame;
        r.origin.y=10;
        imageView.frame=r;
    }else
    {
        UIImageView *imageView=(UIImageView *)[fileMenu viewWithTag:2012];
        imageView.transform=CGAffineTransformMakeScale(1.0, 1.0);
        CGRect r=imageView.frame;
        r.origin.y=0;
        imageView.frame=r;
        [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    fileMenu.frame=r;
    fileMenu.indexPath = indexPath;
    fileMenu.hidden = NO;
    folderMenu.hidden = YES;
}

#pragma mark 移动文件
-(void)toMove:(id)sender
{
//    NSDictionary *dic=[tableArray objectAtIndex:selectedIndexPath.row];
//    NSString *f_id=[dic objectForKey:@"f_id"];
//    NSString *fileName=[dic objectForKey:@"f_name"];
    [file_delegate showController:p_id titleString:@"我的空间"];
}

#pragma mark 重命名文件
-(void)toRename:(id)sender
{
    NSDictionary *dic=[tableArray objectAtIndex:selectedIndexPath.row];
    NSString *name=[dic objectForKey:@"f_name"];
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"重命名" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[alert textFieldAtIndex:0] setText:name];
    [alert setTag:kAlertTagRename];
    [alert show];
    [alert release];
}

#pragma mark 删除文件
-(void)toDelete:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否要删除文件" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
    [alertView setTag:kAlertTagDeleteOne];
    [alertView release];
}

#pragma mark 下载文件
-(void)toFavorite:(id)sender
{
    NSDictionary *dic=[tableArray objectAtIndex:selectedIndexPath.row];
    NSString *f_id=[dic objectForKey:@"f_id"];
    if ([[FavoritesData sharedFavoritesData] isExistsWithFID:f_id]) {
        [[FavoritesData sharedFavoritesData] removeObjectForKey:f_id];
        NSString *fileName=[dic objectForKey:@"f_name"];
        NSString *filePath=[YNFunctions getFMCachePath];
        filePath=[filePath stringByAppendingPathComponent:fileName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSError *error=[[NSError alloc] init];
            if ([[NSFileManager defaultManager] removeItemAtPath:filePath error:&error]) {
                NSLog(@"删除本地收藏文件成功：%@",filePath);
            }else
            {
                NSLog(@"删除本地收藏文件失败：%@",filePath);
            }
        }
    }else
    {
        [[FavoritesData sharedFavoritesData] setObject:dic forKey:f_id];
    }
}

#pragma mark 分享文件
-(void)toShared:(id)sender
{
    NSDictionary *dic=[tableArray objectAtIndex:selectedIndexPath.row];
    NSString *f_id=[dic objectForKey:@"f_id"];
    [linkManager linkWithIDs:@[f_id]];
}

#pragma mark 更多文件
-(void)toMore:(id)sender
{
    
}

#pragma mark clickMenu

-(void)EscMenu
{
    if(!folderMenu.hidden)
    {
        folderMenu.hidden = YES;
    }
    if(!fileMenu.hidden)
    {
        fileMenu.hidden = YES;
    }
    escButton.hidden = YES;
}

#pragma mark UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        NSDictionary *dic=[tableArray objectAtIndex:selectedIndexPath.row];
        NSString *name=[dic objectForKey:@"f_name"];
        NSString *f_id=[dic objectForKey:@"f_id"];
        if(alertView.tag == kAlertTagRename)
        {
            NSString *fildtext=[[alertView textFieldAtIndex:0] text];
            if (![fildtext isEqualToString:name]) {
                [fileManager renameWithID:f_id newName:fildtext];
            }
        }
        else if(alertView.tag == kAlertTagDeleteOne)
        {
            [fileManager removeFileWithIDs:@[f_id]];
        }
    }
}

#pragma mark SCBLinkManagerDelegate -------------

-(void)releaseLinkSuccess:(NSString *)l_url
{
    NSLog(@"releaseLinkSuccess:%@",l_url);
}

-(void)releaseLinkUnsuccess:(NSString *)error_info
{
    
}

#pragma mark SCBFileManagerDelegate -------------

-(void)searchSucess:(NSDictionary *)datadic
{
    
}

-(void)operateSucess:(NSDictionary *)datadic
{

}

-(void)openFinderSucess:(NSDictionary *)datadic
{

}

-(void)openFinderUnsucess
{

}

-(void)removeSucess
{
    NSLog(@"removeSucess");
    [self EscMenu];
    [self requestFile:p_id space_id:[[SCBSession sharedSession] spaceID]];
}

-(void)removeUnsucess
{
    
}

-(void)renameSucess
{
    NSLog(@"renameSucess");
    [self EscMenu];
    [self requestFile:p_id space_id:[[SCBSession sharedSession] spaceID]];
}

-(void)renameUnsucess
{
    
}

-(void)moveSucess
{

}

-(void)moveUnsucess
{

}

-(void)newFinderSucess
{

}

-(void)newFinderUnsucess
{
    
}

#pragma mark 外部调用事件

//编辑事件
-(void)editAction
{
    for(FileTableViewCell *cell in self.visibleCells)
    {
        cell.select_button.tag = cell.tag - FileTableViewCellTag + FileTableViewCellCehckTag;
        [cell.select_button addTarget:self action:@selector(checkSelected:) forControlEvents:UIControlEventTouchUpInside];
        cell.select_button.hidden = NO;
    }
}

//取消事件
-(void)escAction
{
    for(FileTableViewCell *cell in self.visibleCells)
    {
        cell.image_view.hidden = YES;
        cell.select_button.hidden = YES;
    }
}

//选择事件
-(void)checkSelected:(id)sender
{
    UIButton *imageView = sender;
    
    if(selected_dictionary == nil)
    {
        selected_dictionary = [[NSMutableDictionary alloc] init];
    }
    
    BOOL bl = [[selected_dictionary objectForKey:[NSString stringWithFormat:@"%i",imageView.tag-FileTableViewCellCehckTag]] boolValue];
    if(bl)
    {
        [imageView setImage:[UIImage imageNamed:@"Unselected.png"] forState:UIControlStateNormal];
        [selected_dictionary removeObjectForKey:[NSString stringWithFormat:@"%i",imageView.tag-FileTableViewCellCehckTag]];
        FileTableViewCell *cell = (FileTableViewCell *)[self viewWithTag:imageView.tag-FileTableViewCellCehckTag+FileTableViewCellTag];
        cell.image_view.hidden = YES;
    }
    else
    {
        [imageView setImage:[UIImage imageNamed:@"Selected.png"] forState:UIControlStateNormal];
        [selected_dictionary setObject:@"1" forKey:[NSString stringWithFormat:@"%i",imageView.tag-FileTableViewCellCehckTag]];
        FileTableViewCell *cell = (FileTableViewCell *)[self viewWithTag:imageView.tag-FileTableViewCellCehckTag+FileTableViewCellTag];
        cell.image_view.hidden = NO;
    }
}

//请求文件
-(void)requestFile:(NSString *)f_id space_id:(NSString *)space_id
{
    p_id = f_id;
    [photoManager openFinderWithID:f_id space_id:space_id];
}

#pragma mark 文件下载

-(void)startDownLoad:(NSString *)f_id indexPath:(NSIndexPath *)indexPath
{
    if(![tableDictionary objectForKey:indexPath])
    {
        DownImage *downImage = [[[DownImage alloc] init] autorelease];
        [downImage setFileId:[f_id intValue]];
        [downImage setImageUrl:[NSString stringWithFormat:@"%i",[f_id intValue]]];
        [downImage setImageViewIndex:0];
        [downImage setIndexPath:indexPath];
        [downImage setShowType:1];
        [tableDictionary setObject:downImage forKey:indexPath];
        [downImage setDelegate:self];
        [downImage startDownload];
    }
}

#pragma mark 文件下载代理

-(void)appImageDidLoad:(NSInteger)indexTag urlImage:(UIImage *)image index:(NSIndexPath *)indexPath
{
    DownImage *down = [tableDictionary objectForKey:indexPath];
    if(down)
    {
        UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
        NSString *path = [self get_image_save_file_path:[NSString stringWithFormat:@"%i",down.fileId]];
        UIImage *icon=[UIImage imageWithContentsOfFile:path];
        CGSize itemSize = CGSizeMake(160, 100);
        UIGraphicsBeginImageContext(itemSize);
        CGRect theR=CGRectMake(0, 0, itemSize.width, itemSize.height);
        if (icon.size.width>icon.size.height) {
            theR.size.width=icon.size.width/(icon.size.height/itemSize.height);
            theR.origin.x=-(theR.size.width/2)-itemSize.width;
        }else
        {
            theR.size.height=icon.size.height/(icon.size.width/itemSize.width);
            theR.origin.y=-(theR.size.height/2)-itemSize.height;
        }
        CGRect imageRect = CGRectMake(35, 5, 90, 90);
        [icon drawInRect:imageRect];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        cell.imageView.image = image;
        [tableDictionary removeObjectForKey:indexPath];
    }
}


//获取图片路径
- (NSString*)get_image_save_file_path:(NSString*)image_path
{
    NSString *documentDir = [YNFunctions getProviewCachePath];
    NSArray *array=[image_path componentsSeparatedByString:@"/"];
    NSString *path=[NSString stringWithFormat:@"%@/%@",documentDir,[array lastObject]];
    return path;
}

-(void)dealloc
{
    [photoManager release];
    [upDictionary release];
    [tableArray release];
    [tableDictionary release];
    [folderMenu release];
    [fileMenu release];
    [escButton release];
    [fileManager release];
    [linkManager release];
    [p_id release];
    [selected_dictionary release];
    [super dealloc];
}

@end
