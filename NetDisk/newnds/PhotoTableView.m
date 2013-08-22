//
//  PhotoTableView.m
//  NetDisk
//
//  Created by Yangsl on 13-8-22.
//
//

#import "PhotoTableView.h"

@implementation PhotoTableView
@synthesize show_height;
@synthesize allDictionary;
@synthesize imageTa;
@synthesize table_view;
@synthesize activity_indicator;
@synthesize user_id;
@synthesize user_token;
@synthesize allKeys;
@synthesize _arrVisibleCells;
@synthesize _dicReuseCells;
@synthesize editBL;
@synthesize bottonView;
@synthesize photo_diction;
@synthesize photoManager;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark SCBPhotoDelegate ------------------

-(void)getPhotoTiimeLine:(NSDictionary *)dictionary
{
    
}

-(void)getPhotoGeneral:(NSDictionary *)dictionary photoDictioin:(NSMutableDictionary *)photoDic
{
    
}

-(void)getPhotoDetail:(NSDictionary *)dictionary
{
    
}

-(void)requstDelete:(NSDictionary *)dictionary
{
    
}

-(void)getFileDetail:(NSDictionary *)dictionary
{
    
}

-(void)didFailWithError
{
    
}

@end
