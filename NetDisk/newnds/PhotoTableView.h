//
//  PhotoTableView.h
//  NetDisk
//
//  Created by Yangsl on 13-8-22.
//
//

#import <UIKit/UIKit.h>
#import "SCBPhotoManager.h"
#import "DownImage.h"

@protocol PhotoTableViewDelegate <NSObject>

-(void)showFile:(int)index array:(NSMutableArray *)tableArray;

@end

@interface PhotoTableView : UITableView <SCBPhotoDelegate,UITableViewDataSource,UITableViewDelegate,DownloaderDelegate>
{
    SCBPhotoManager *photoManager;
	NSMutableDictionary *_dicReuseCells; //选中的数据
    BOOL editBL;  //是否为编辑状态，默认为false
    NSMutableDictionary *tablediction;
    NSMutableArray *sectionarray;
    NSMutableArray *downCellArray;
    
    BOOL isLoadImage;
    BOOL isLoadData;
    
    float endFloat;
    BOOL isSort;
    
    id<PhotoTableViewDelegate> photo_delegate;
}

@property(nonatomic,assign) SCBPhotoManager *photoManager;
@property(nonatomic,retain) NSMutableDictionary *_dicReuseCells; //选中的数据
@property(nonatomic,assign) BOOL editBL;  //是否为编辑状态，默认为false
@property(nonatomic,retain) NSMutableDictionary *photo_diction;
@property(nonatomic,retain) NSMutableArray *sectionarray;
@property(nonatomic,retain) NSMutableArray *downCellArray; // 重用的cell

@property(nonatomic,assign) BOOL isLoadImage;
@property(nonatomic,assign) BOOL isLoadData;

@property(nonatomic,assign) float endFloat;
@property(nonatomic,assign) BOOL isSort;

@property(nonatomic,retain) id<PhotoTableViewDelegate> photo_delegate;

@end


@interface CellTag : NSObject
{
    NSInteger fileTag;
    NSInteger imageTag;
    NSInteger buttonTag;
    NSInteger pageTag;
    NSInteger sectionTag;
}

@property(nonatomic,assign) NSInteger fileTag;
@property(nonatomic,assign) NSInteger imageTag;
@property(nonatomic,assign) NSInteger buttonTag;
@property(nonatomic,assign) NSInteger pageTag;
@property(nonatomic,assign) NSInteger sectionTag;
@end

@interface SelectButton : UIButton
{
    CellTag *cell;
}
@property(nonatomic,retain) CellTag *cell;

@end
