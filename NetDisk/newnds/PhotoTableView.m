//
//  PhotoTableView.m
//  NetDisk
//
//  Created by Yangsl on 13-8-22.
//
//

#import "PhotoTableView.h"
#import "PhotoFile.h"
#import "PhotoFileCell.h"
#import "YNFunctions.h"
#import "PhotoLookViewController.h"

#define timeLine1 @"今天"
#define timeLine2 @"昨天"
#define timeLine3 @"本周"
#define timeLine4 @"上一周"
#define timeLine5 @"本月"
#define timeLine6 @"上一月"
#define timeLine7 @"本年"

#define UICellTag 10000000
#define UIImageTag 1000000
#define UIButtonTag 2000000

@implementation PhotoTableView
@synthesize photoManager,_dicReuseCells,editBL,photo_diction,sectionarray,downCellArray,isLoadData,isLoadImage,endFloat,isSort,photo_delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    tablediction = [[NSMutableDictionary alloc] init];
    sectionarray = [[NSMutableArray alloc] init];
    downCellArray = [[NSMutableArray alloc] init];
    //请求时间轴
    photoManager = [[SCBPhotoManager alloc] init];
    [photoManager setPhotoDelegate:self];
    
    self.dataSource = self;
    self.delegate = self;
    [NSThread detachNewThreadSelector:@selector(requestPhotoTimeLine) toTarget:self withObject:nil];
    return self;
}

//请求时间轴
-(void)requestPhotoTimeLine
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [photoManager getPhotoTimeLine:TRUE];
    });
}

#pragma mark SCBPhotoDelegate ------------------

-(void)getPhotoTiimeLine:(NSDictionary *)dictionary
{
    [self clearsContextBeforeDrawing];
    [tablediction removeAllObjects];
    [sectionarray removeAllObjects];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *todayDate = [NSDate date];
    NSDateComponents *todayComponent = [calendar components:NSEraCalendarUnit| NSYearCalendarUnit| NSMonthCalendarUnit| NSDayCalendarUnit| NSHourCalendarUnit| NSMinuteCalendarUnit | NSSecondCalendarUnit| NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit | NSQuarterCalendarUnit | NSWeekOfMonthCalendarUnit | NSWeekOfYearCalendarUnit | NSYearForWeekOfYearCalendarUnit fromDate:todayDate];
    
    //今天的起止时间
    NSString *eString  = [NSString stringWithFormat:@"%i-%i-%i %i:%i",todayComponent.year,todayComponent.month,todayComponent.day,todayComponent.hour,todayComponent.minute];
    NSString *sString  = [NSString stringWithFormat:@"%i-%i-%i 00:00",todayComponent.year,todayComponent.month,todayComponent.day];
    PhotoFile *photo_file = [[PhotoFile alloc] init];
    NSArray *timeArray = [photo_file selectMoreTaskTable:sString eDate:eString];
    if([timeArray count]>0)
    {
        [sectionarray addObject:timeLine1];
        [tablediction setObject:timeArray forKey:timeLine1];
    }
    NSLog(@"timeArray:%@ \n count:%i",timeArray,[timeArray count]);
    //昨天的起止时间
    if([self startTimeMoreThanEndTime:sString eTime:eString])
    {
        eString = sString;
    }
    if(todayComponent.day-2 == -1)
    {
        sString  = [NSString stringWithFormat:@"%i-%i-%i 00:00",todayComponent.year,todayComponent.month-1,[self theDaysInYear:todayComponent.year inMonth:todayComponent.month-1]];
    }
    else
    {
        sString  = [NSString stringWithFormat:@"%i-%i-%i 00:00",todayComponent.year,todayComponent.month,todayComponent.day-1];
    }
    
    timeArray = [photo_file selectMoreTaskTable:sString eDate:eString];
    if([timeArray count]>0)
    {
        [sectionarray addObject:timeLine2];
        [tablediction setObject:timeArray forKey:timeLine2];
    }
    NSLog(@"timeArray:%@ \n count:%i",timeArray,[timeArray count]);
    
    //本周的起止时间
    if([self startTimeMoreThanEndTime:sString eTime:eString])
    {
        eString = sString;
    }
    if(todayComponent.day-todayComponent.weekday < 0)
    {
        sString  = [NSString stringWithFormat:@"%i-%i-%i 00:00",todayComponent.year,todayComponent.month-1,[self theDaysInYear:todayComponent.year inMonth:todayComponent.month-1]+(todayComponent.day-todayComponent.weekday)+1];
    }
    else
    {
        sString  = [NSString stringWithFormat:@"%i-%i-%i 00:00",todayComponent.year,todayComponent.month,todayComponent.day-todayComponent.weekday+1];
    }
    timeArray = [photo_file selectMoreTaskTable:sString eDate:eString];
    if([timeArray count]>0)
    {
        [sectionarray addObject:timeLine3];
        [tablediction setObject:timeArray forKey:timeLine3];
    }
    NSLog(@"timeArray:%@ \n count:%i",timeArray,[timeArray count]);
    
    //上一周的起止时间
    if([self startTimeMoreThanEndTime:sString eTime:eString])
    {
        eString = sString;
    }
    if(todayComponent.day-(todayComponent.weekday+7)<0)
    {
        sString  = [NSString stringWithFormat:@"%i-%i-%i 00:00",todayComponent.year,todayComponent.month-1,[self theDaysInYear:todayComponent.year inMonth:todayComponent.month-1]+(todayComponent.day-(todayComponent.weekday+7))+1];
    }
    else
    {
        sString  = [NSString stringWithFormat:@"%i-%i-%i 00:00",todayComponent.year,todayComponent.month,todayComponent.day-(todayComponent.weekday+7)+1];
    }
    timeArray = [photo_file selectMoreTaskTable:sString eDate:eString];
    if([timeArray count]>0)
    {
        [sectionarray addObject:timeLine4];
        [tablediction setObject:timeArray forKey:timeLine4];
    }
    NSLog(@"timeArray:%@ \n count:%i",timeArray,[timeArray count]);
    
    //本月的起止时间
    if([self startTimeMoreThanEndTime:sString eTime:eString])
    {
        eString = sString;
    }
    sString  = [NSString stringWithFormat:@"%i-%i-%i 00:00",todayComponent.year,todayComponent.month,1];
    timeArray = [photo_file selectMoreTaskTable:sString eDate:eString];
    if([timeArray count]>0)
    {
        [sectionarray addObject:timeLine5];
        [tablediction setObject:timeArray forKey:timeLine5];
    }
    NSLog(@"timeArray:%@ \n count:%i",timeArray,[timeArray count]);
    
    //上个月的起止时间
    if([self startTimeMoreThanEndTime:sString eTime:eString])
    {
        eString = sString;
    }
    sString  = [NSString stringWithFormat:@"%i-%i-%i 00:00",todayComponent.year,todayComponent.month-1,1];
    timeArray = [photo_file selectMoreTaskTable:sString eDate:eString];
    if([timeArray count]>0)
    {
        [sectionarray addObject:timeLine6];
        [tablediction setObject:timeArray forKey:timeLine6];
    }
    NSLog(@"timeArray:%@ \n count:%i",timeArray,[timeArray count]);
    
    //本年的起止时间
    if([self startTimeMoreThanEndTime:sString eTime:eString])
    {
        eString = sString;
    }
    sString  = [NSString stringWithFormat:@"%i-%i-%i 00:00",todayComponent.year,1,1];
    timeArray = [photo_file selectMoreTaskTable:sString eDate:eString];
    if([timeArray count]>0)
    {
        [sectionarray addObject:timeLine7];
        [tablediction setObject:timeArray forKey:timeLine7];
    }
    NSLog(@"timeArray:%@ \n count:%i",timeArray,[timeArray count]);
    
    //十年内的数据
    for(int i=1;i<=10;i++)
    {
        if([self startTimeMoreThanEndTime:sString eTime:eString])
        {
            eString = sString;
        }
        sString  = [NSString stringWithFormat:@"%i-%i-%i 00:00",todayComponent.year-i,1,1];
        timeArray = [photo_file selectMoreTaskTable:sString eDate:eString];
        if([timeArray count]>0)
        {
            [sectionarray addObject:[NSString stringWithFormat:@"%i年",todayComponent.year-i]];
            [tablediction setObject:timeArray forKey:[NSString stringWithFormat:@"%i年",todayComponent.year-i]];
        }
        NSLog(@"timeArray:%@ \n count:%i",timeArray,[timeArray count]);
    }
    
    [self reloadData];
    
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(FirstLoad) userInfo:nil repeats:NO];
}

-(void)getPhotoGeneral:(NSDictionary *)dictionary photoDictioin:(NSMutableDictionary *)photoDic
{
    
}

-(void)getPhotoDetail:(NSDictionary *)dictionary
{
    
}

-(void)requstDelete:(NSDictionary *)dictionary
{
    if([[dictionary objectForKey:@"code"] intValue] == 0)
    {
        
    }
    else
    {
        
    }
}

-(void)getFileDetail:(NSDictionary *)dictionary
{
    
}

-(void)didFailWithError
{
    
}

#pragma mark 常用基本方法

-(void)FirstLoad
{
    isLoadData = TRUE;
    [NSThread detachNewThreadSelector:@selector(getImageLoad) toTarget:self withObject:nil];
}

- (void)appImageDidLoad:(NSInteger)indexTag urlImage:(UIImage *)image index:(NSIndexPath *)indexPath
{
    if(isLoadImage)
    {
        NSObject *obj = [self viewWithTag:indexTag];
        if(!obj)
        {
            return;
        }
        
        UIImageView *image_view = (UIImageView *)obj;
        UIImage *imageV = image;
        if(imageV.size.width>=imageV.size.height)
        {
            if(imageV.size.height<=200)
            {
                CGRect imageRect = CGRectMake((imageV.size.width-imageV.size.height)/2, 0, imageV.size.height, imageV.size.height);
                imageV = [self imageFromImage:imageV inRect:imageRect];
                [image_view performSelectorOnMainThread:@selector(setImage:) withObject:imageV waitUntilDone:YES];
            }
            else
            {
                CGSize newImageSize;
                newImageSize.height = 200;
                newImageSize.width = 200*imageV.size.width/imageV.size.height;
                UIImage *imageS = [self scaleFromImage:imageV toSize:newImageSize];
                CGRect imageRect = CGRectMake((newImageSize.width-200)/2, 0, 200, 200);
                imageS = [self imageFromImage:imageS inRect:imageRect];
                [image_view performSelectorOnMainThread:@selector(setImage:) withObject:imageS waitUntilDone:YES];
            }
        }
        else if(imageV.size.width<=imageV.size.height)
        {
            if(imageV.size.width<=200)
            {
                CGRect imageRect = CGRectMake(0, (imageV.size.height-imageV.size.width)/2, imageV.size.width, imageV.size.width);
                imageV = [self imageFromImage:imageV inRect:imageRect];
                [image_view performSelectorOnMainThread:@selector(setImage:) withObject:imageV waitUntilDone:YES];
            }
            else
            {
                CGSize newImageSize;
                newImageSize.width = 200;
                newImageSize.height = 200*imageV.size.height/imageV.size.width;
                UIImage *imageS = [self scaleFromImage:imageV toSize:newImageSize];
                CGRect imageRect = CGRectMake(0, (newImageSize.height-200)/2, 200, 200);
                imageS = [self imageFromImage:imageS inRect:imageRect];
                [image_view performSelectorOnMainThread:@selector(setImage:) withObject:imageS waitUntilDone:YES];
            }
        }
    }
}

-(void)getImageLoad
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        if(!downCellArray)
        {
            isLoadData = FALSE;
            return;
        }
        for(int i=0;isLoadData && isLoadImage && i<[downCellArray count];i++)
        {
            PhotoFileCell *cell = (PhotoFileCell *)[downCellArray objectAtIndex:i];
            NSArray *array = [cell cellArray];
            if(!array)
            {
                isLoadData = FALSE;
                return;
            }
            for(int j=0;isLoadData && isLoadImage && j<[array count];j++)
            {
                CellTag *cellTag = [array objectAtIndex:j];
                if(!cellTag)
                {
                    isLoadData = FALSE;
                    return;
                }
                if(![self image_exists_at_file_path:[NSString stringWithFormat:@"%i",cellTag.fileTag]])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        DownImage *downImage = [[[DownImage alloc] init] autorelease];
                        [downImage setFileId:cellTag.fileTag];
                        [downImage setImageUrl:[NSString stringWithFormat:@"%i",cellTag.fileTag]];
                        [downImage setImageViewIndex:cellTag.imageTag];
                        [downImage setDelegate:self];
                        [downImage startDownload];
                    });
                }
            }
        }
        //    dispatch_async(dispatch_get_main_queue(), ^{
        isLoadData = FALSE;
        [downCellArray removeAllObjects];
        //    });
        [pool release];
    });
}

#pragma mark 按钮点击事件
-(void)clicked:(id)sender
{
    isLoadImage = FALSE;
    SelectButton *button = sender;
    int fid = button.tag-UIButtonTag;
    if(editBL)
    {
        
        if(button.selected)
        {
            [button setSelected:NO];
            [_dicReuseCells removeObjectForKey:[NSString stringWithFormat:@"%i",fid]];
            [button setBackgroundImage:[UIImage imageNamed:@"111.png"] forState:UIControlStateNormal];
        }
        else
        {
            [button setSelected:YES];
            [_dicReuseCells setObject:[NSNumber numberWithInt:fid] forKey:[NSString stringWithFormat:@"%i",fid]];
            [button setBackgroundImage:[UIImage imageNamed:@"interestSelected.png"] forState:UIControlStateNormal];
        }
    }
    else
    {
        NSString *sectionString = [sectionarray objectAtIndex:button.cell.sectionTag];
        NSArray *array = [tablediction objectForKey:sectionString];
        [photo_delegate showFile:button.cell.pageTag array:[NSMutableArray arrayWithArray:array]];
    }
    NSLog(@"button:%i",button.tag);
}

#pragma mark UIScrollviewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
        isLoadImage = TRUE;
        if(!isLoadData && scrollView.contentOffset.y >= 0 && endFloat > scrollView.contentOffset.y && scrollView.contentOffset.y <= scrollView.contentSize.height)
        {
            isSort = TRUE;
            endFloat = scrollView.contentOffset.y;
            isLoadData = TRUE;
            NSLog(@"isLoadData11111:%i",isLoadData);
            [NSThread detachNewThreadSelector:@selector(getImageLoad) toTarget:self withObject:nil];
        }
        
        if(!isLoadData && scrollView.contentOffset.y >= 0 && endFloat < scrollView.contentOffset.y && scrollView.contentOffset.y <= scrollView.contentSize.height)
        {
            isSort = FALSE;
            endFloat = scrollView.contentOffset.y;
            isLoadData = TRUE;
            NSLog(@"isLoadData11111:%i",isLoadData);
            [NSThread detachNewThreadSelector:@selector(getImageLoad) toTarget:self withObject:nil];
        }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    isLoadImage = TRUE;
    if(!isLoadData && scrollView.contentOffset.y >= 0 && endFloat > scrollView.contentOffset.y && scrollView.contentOffset.y <= scrollView.contentSize.height)
    {
        isSort = TRUE;
        endFloat = scrollView.contentOffset.y;
        isLoadData = TRUE;
        NSLog(@"isLoadData222222:%i",isLoadData);
        [NSThread detachNewThreadSelector:@selector(getImageLoad) toTarget:self withObject:nil];
    }
    
    if(!isLoadData && scrollView.contentOffset.y >= 0 && endFloat < scrollView.contentOffset.y && scrollView.contentOffset.y <= scrollView.contentSize.height)
    {
        isSort = FALSE;
        endFloat = scrollView.contentOffset.y;
        isLoadData = TRUE;
        NSLog(@"isLoadData222222:%i",isLoadData);
        [NSThread detachNewThreadSelector:@selector(getImageLoad) toTarget:self withObject:nil];
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    isLoadImage = FALSE;
}

#pragma mark UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [sectionarray count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [sectionarray objectAtIndex:section];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = [tablediction objectForKey:[sectionarray objectAtIndex:section]];
    int number = [array count];
    if(number%3==0)
    {
        return number/3;
    }
    else
    {
        return number/3+1;
    }
}

-(float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *array = [tablediction objectForKey:[sectionarray objectAtIndex:[indexPath section]]];
    int number = [array count];
    if(([indexPath row]+1)*3 >= number)
    {
        return 110;
    }
    return 105;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        int section = [indexPath section];
        int row = [indexPath row];
        static NSString *cellString = @"cellString";
        PhotoFileCell *cell = [self dequeueReusableCellWithIdentifier:cellString];
        if(cell == nil)
        {
            cell = [[[PhotoFileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellString] autorelease];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        else
        {
            while ([cell.contentView.subviews lastObject] != nil) {
                [(UIView*)[cell.contentView.subviews lastObject] removeFromSuperview];  //删除并进行重新分配
            }
        }
        
        NSString *sectionNumber = [sectionarray objectAtIndex:section];
        NSArray *array = [tablediction objectForKey:sectionNumber];
        if([array count]/3 == row)
        {
            cell.tag = row+UICellTag*section;
            int number = 3;
            if([array count]%3>0)
            {
                number = [array count]%3;
            }
            NSMutableArray *cellArray = [[NSMutableArray alloc] init];
            NSMutableArray *imageArray = [[NSMutableArray alloc] init];
            for(int i=0;i<number;i++)
            {
                if(row*3+i>=[array count])
                {
                    break;
                }
                CellTag *cellT = [[CellTag alloc] init];
                PhotoFile *demo = [array objectAtIndex:row*3+i];
                [cellT setFileTag:demo.f_id];
                CGRect rect = CGRectMake(i*105+5, 5, 100, 100);
                UIImageView *image = [[UIImageView alloc] initWithFrame:rect];
                image.tag = UIImageTag+demo.f_id;
                [cellT setImageTag:image.tag];
                
                
                
                {
                    UIImage *imageV = [UIImage imageNamed:@"icon_Load.png"];
                    [image performSelectorOnMainThread:@selector(setImage:) withObject:imageV waitUntilDone:YES];
                }
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    if([self image_exists_at_file_path:[NSString stringWithFormat:@"%i",demo.f_id]])
                    {
                        NSString *path = [self get_image_save_file_path:[NSString stringWithFormat:@"%i",demo.f_id]];
                        UIImage *imageV = [UIImage imageWithContentsOfFile:path];
                        
                        if(imageV.size.width>=imageV.size.height)
                        {
                            if(imageV.size.height<=200)
                            {
                                CGRect imageRect = CGRectMake((imageV.size.width-imageV.size.height)/2, 0, imageV.size.height, imageV.size.height);
                                imageV = [self imageFromImage:imageV inRect:imageRect];
                                [image performSelectorOnMainThread:@selector(setImage:) withObject:imageV waitUntilDone:YES];
                            }
                            else
                            {
                                CGSize newImageSize;
                                newImageSize.height = 200;
                                newImageSize.width = 200*imageV.size.width/imageV.size.height;
                                UIImage *imageS = [self scaleFromImage:imageV toSize:newImageSize];
                                CGRect imageRect = CGRectMake((newImageSize.width-200)/2, 0, 200, 200);
                                imageS = [self imageFromImage:imageS inRect:imageRect];
                                [image performSelectorOnMainThread:@selector(setImage:) withObject:imageS waitUntilDone:YES];
                            }
                        }
                        else if(imageV.size.width<=imageV.size.height)
                        {
                            if(imageV.size.width<=200)
                            {
                                CGRect imageRect = CGRectMake(0, (imageV.size.height-imageV.size.width)/2, imageV.size.width, imageV.size.width);
                                imageV = [self imageFromImage:imageV inRect:imageRect];
                                [image performSelectorOnMainThread:@selector(setImage:) withObject:imageV waitUntilDone:YES];
                            }
                            else
                            {
                                CGSize newImageSize;
                                newImageSize.width = 200;
                                newImageSize.height = 200*imageV.size.height/imageV.size.width;
                                UIImage *imageS = [self scaleFromImage:imageV toSize:newImageSize];
                                CGRect imageRect = CGRectMake(0, (newImageSize.height-200)/2, 200, 200);
                                imageS = [self imageFromImage:imageS inRect:imageRect];
                                [image performSelectorOnMainThread:@selector(setImage:) withObject:imageS waitUntilDone:YES];
                            }
                        }
                    }
                });
                
                [cell.contentView addSubview:image];
                [imageArray addObject:image];
                
                SelectButton *button = [[SelectButton alloc] initWithFrame:rect];
                [button setTag:UIButtonTag+demo.f_id];
                [cellT setButtonTag:button.tag];
                [cellT setSectionTag:section];
                [cellT setPageTag:row*3+i];
                [cellArray addObject:cellT];
                [button setCell:cellT];
                
                [image release];
                [cellT release];
                [button addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
                if(editBL)
                {
                    for(int i=0;i<[[_dicReuseCells allKeys] count];i++)
                    {
                        int fid = [[_dicReuseCells objectForKey:[[_dicReuseCells allKeys] objectAtIndex:i]] intValue];
                        if(demo.f_id == fid)
                        {
                            [button setBackgroundImage:[UIImage imageNamed:@"interestSelected.png"] forState:UIControlStateNormal];
                        }
                    }
                }
                [cell.contentView addSubview:button];
                [button release];
                
                NSLog(@"imageCount:%i",image.retainCount);
            }
            if([downCellArray count]>5)
            {
                [downCellArray removeObjectAtIndex:0];
            }
            [downCellArray addObject:cell];
            //        operation *queue = [[operation alloc] init];
            //        [queue cellArray:cellArray imagev:imageArray];
            //        [operationQueue addOperation:queue];
            //        [queue release];
            [cell setCellArray:cellArray];
            [cellArray release];
            [imageArray release];
        }
        else
        {
            cell.tag = row+UICellTag*section;
            NSMutableArray *cellArray = [[NSMutableArray alloc] init];
            NSMutableArray *imageArray = [[NSMutableArray alloc] init];
            for(int i=0;i<3;i++)
            {
                CellTag *cellT = [[CellTag alloc] init];
                PhotoFile *demo = [array objectAtIndex:row*3+i];
                [cellT setFileTag:demo.f_id];
                CGRect rect = CGRectMake(i*105+5, 5, 100, 100);
                UIImageView *image = [[UIImageView alloc] initWithFrame:rect];
                image.tag = UIImageTag+demo.f_id;
                [cellT setImageTag:image.tag];
                
                {
                    UIImage *imageV = [UIImage imageNamed:@"icon_Load.png"];
                    [image performSelectorOnMainThread:@selector(setImage:) withObject:imageV waitUntilDone:YES];
                }
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    if([self image_exists_at_file_path:[NSString stringWithFormat:@"%i",demo.f_id]])
                    {
                        NSString *path = [self get_image_save_file_path:[NSString stringWithFormat:@"%i",demo.f_id]];
                        UIImage *imageV = [UIImage imageWithContentsOfFile:path];
                        if(imageV.size.width>=imageV.size.height)
                        {
                            if(imageV.size.height<=200)
                            {
                                CGRect imageRect = CGRectMake((imageV.size.width-imageV.size.height)/2, 0, imageV.size.height, imageV.size.height);
                                imageV = [self imageFromImage:imageV inRect:imageRect];
                                [image performSelectorOnMainThread:@selector(setImage:) withObject:imageV waitUntilDone:YES];
                            }
                            else
                            {
                                CGSize newImageSize;
                                newImageSize.height = 200;
                                newImageSize.width = 200*imageV.size.width/imageV.size.height;
                                UIImage *imageS = [self scaleFromImage:imageV toSize:newImageSize];
                                CGRect imageRect = CGRectMake((newImageSize.width-200)/2, 0, 200, 200);
                                imageS = [self imageFromImage:imageS inRect:imageRect];
                                [image performSelectorOnMainThread:@selector(setImage:) withObject:imageS waitUntilDone:YES];
                            }
                        }
                        else if(imageV.size.width<=imageV.size.height)
                        {
                            if(imageV.size.width<=200)
                            {
                                CGRect imageRect = CGRectMake(0, (imageV.size.height-imageV.size.width)/2, imageV.size.width, imageV.size.width);
                                imageV = [self imageFromImage:imageV inRect:imageRect];
                                [image performSelectorOnMainThread:@selector(setImage:) withObject:imageV waitUntilDone:YES];
                            }
                            else
                            {
                                CGSize newImageSize;
                                newImageSize.width = 200;
                                newImageSize.height = 200*imageV.size.height/imageV.size.width;
                                UIImage *imageS = [self scaleFromImage:imageV toSize:newImageSize];
                                CGRect imageRect = CGRectMake(0, (newImageSize.height-200)/2, 200, 200);
                                imageS = [self imageFromImage:imageS inRect:imageRect];
                                [image performSelectorOnMainThread:@selector(setImage:) withObject:imageS waitUntilDone:YES];
                            }
                        }
                    }
                });
                
                [cell.contentView addSubview:image];
                [imageArray addObject:image];
                
                SelectButton *button = [[SelectButton alloc] initWithFrame:rect];
                [button setTag:UIButtonTag+demo.f_id];
                [cellT setButtonTag:button.tag];
                [cellT setSectionTag:section];
                [cellT setPageTag:row*3+i];
                [cellArray addObject:cellT];
                [button setCell:cellT];
                
                [image release];
                [cellT release];
                [button addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
                if(editBL)
                {
                    for(int i=0;i<[[_dicReuseCells allKeys] count];i++)
                    {
                        int fid = [[_dicReuseCells objectForKey:[[_dicReuseCells allKeys] objectAtIndex:i]] intValue];
                        if(demo.f_id == fid)
                        {
                            [button setBackgroundImage:[UIImage imageNamed:@"interestSelected.png"] forState:UIControlStateNormal];
                        }
                    }
                }
                [cell.contentView addSubview:button];
                [button release];
                
                NSLog(@"imageCount:%i",image.retainCount);
            }
            if([downCellArray count]>5)
            {
                [downCellArray removeObjectAtIndex:0];
            }
            [downCellArray addObject:cell];
            //        operation *queue = [[operation alloc] init];
            //        [queue cellArray:cellArray imagev:imageArray];
            //        [operationQueue addOperation:queue];
            //        [queue release];
            [cell setCellArray:cellArray];
            [cellArray release];
            [imageArray release];
        }
        NSLog(@"countdd:%i",cell.retainCount);
        return cell;
}

//这个路径下是否存在此图片
- (BOOL)image_exists_at_file_path:(NSString *)image_path
{
    NSFileManager *file_manager = [NSFileManager defaultManager];
    NSString *documentDir = [YNFunctions getProviewCachePath];
    NSArray *array=[image_path componentsSeparatedByString:@"/"];
    NSString *path=[NSString stringWithFormat:@"%@/%@",documentDir,[array lastObject]];
    return [file_manager fileExistsAtPath:path];
}


//获取图片路径
- (NSString*)get_image_save_file_path:(NSString*)image_path
{
    NSString *documentDir = [YNFunctions getProviewCachePath];
    NSArray *array=[image_path componentsSeparatedByString:@"/"];
    NSString *path=[NSString stringWithFormat:@"%@/%@",documentDir,[array lastObject]];
    return path;
}

-(BOOL)startTimeMoreThanEndTime:(NSString *)sTime eTime:(NSString *)eTime
{
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *sDate = [dateFormatter dateFromString:sTime];
    NSDate *eDate = [dateFormatter dateFromString:eTime];
    if([sDate timeIntervalSince1970]<[eDate timeIntervalSince1970])
    {
        return YES;
    }
    return NO;
}

#pragma mark 得到月份天数
-(int)theDaysInYear:(int)year inMonth:(int)month
{
    if (month == 1||month == 3||month == 5||month == 7||month == 8||month == 10||month == 12) {
        return 31;
    }
    if (month == 4||month == 6||month == 9||month == 11) {
        return 30;
    }
    if ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0) {
        return 29;
    }
    return 28;
}

-(UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect{
	CGImageRef sourceImageRef = [image CGImage];
	CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
	UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
	return newImage;
}

-(UIImage *)scaleFromImage:(UIImage *)image toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void)dealloc
{
    [photoManager release];
    [_dicReuseCells release];
    [photo_diction release];
    [sectionarray release];
    [downCellArray release];
    [super dealloc];
}

@end
