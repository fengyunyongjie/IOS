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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        photoManager = [[SCBPhotoManager alloc] init];
        [photoManager setNewFoldDelegate:self];
    }
    tableDictionary = [[NSMutableDictionary alloc] init];
    self.dataSource = self;
    self.delegate = self;
    return self;
}

//请求文件
-(void)requestFile:(NSString *)f_id space_id:(NSString *)space_id
{
    [photoManager openFinderWithID:f_id space_id:space_id];
}

#pragma mark NewFoldDelegate ------------------

-(void)newFold:(NSDictionary *)dictionary
{
    
}

-(void)openFile:(NSDictionary *)dictionary
{
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
    NSLog(@"dictionary:%@",dictionary);
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
    UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:cellString];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellString];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
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
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dictioinary = [tableArray objectAtIndex:[indexPath row]];
    upDictionary = dictioinary;
    NSString *f_mime = [dictioinary objectForKey:@"f_mime"];
    NSString *f_id = [dictioinary objectForKey:@"f_id"];
    if ([f_mime isEqualToString:@"directory"]) {
        [self requestFile:f_id space_id:[[SCBSession sharedSession] spaceID]];
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
    if ([f_mime isEqualToString:@"directory"]) {
        [self showFolder:indexPath];
    }
    else
    {
        [self showFileload:indexPath];
    }
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
    [super dealloc];
}

@end
