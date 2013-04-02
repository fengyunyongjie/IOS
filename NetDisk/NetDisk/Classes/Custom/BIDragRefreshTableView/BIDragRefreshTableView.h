//
//  BIDragRefreshTableView.h
//  EMBA
//
//  Created by haodu on 11-10-13.
//  Copyright 2011 haodu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
typedef enum{
	BIUpDragRefreshType = 1,
	BIDownDragRefreshType,
} BIDragRefreshType;

typedef enum{
	BIDragToReload = 1, // 拖动可以更新
	BIReleaseToReload, // 释放即可更新
	BILoadingStatus, // 正在更新
} BIPullRefreshState;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
@protocol BIDragRefreshTableViewDelegate;
@interface BIRefreshTableHeaderView : UIView {
	
	BIPullRefreshState _state;
	//头部下拉刷新，尾部上拉刷新
	BIDragRefreshType _viewType;
	id delegate;
	
	UILabel *_lastUpdatedLabel;
	UILabel *_statusLabel;
	CALayer *_arrowImage;
	UIActivityIndicatorView *_activityView;
	
}

@property(nonatomic, assign) id <BIDragRefreshTableViewDelegate> delegate;
@property(nonatomic, readonly, getter=state) BIPullRefreshState _state;

- (id)initWithFrame:(CGRect)frame viewType:(BIDragRefreshType) aViewType;
- (void)refreshLastUpdatedDate:(NSDate *)date;
- (void)RefreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)RefreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)RefreshScrollViewDataSourceDidFinishedLoad:(UIScrollView *)scrollView;
- (void)modelDidStartLoad:(UIScrollView *)scrollView ;
@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
@protocol BIDragRefreshTableViewDelegate
//modify by yinhh 2011-11-27 add tag:(int)tag
- (void)refreshTableHeaderViewDataSourceDidStartLoad:(BIRefreshTableHeaderView *) refreshTableHeaderView;
//Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath;
@optional
- (BOOL)refreshTableHeaderViewDataSourceCanStartLoad;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath;
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
@end
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
@interface BIDragRefreshTableView : UIView <UITableViewDelegate, UITableViewDataSource> {
    
	UITableView              *dragRefreshTableView;
	//动态刷新视图
	BIRefreshTableHeaderView *bottomView;
	BIRefreshTableHeaderView *headerView;
	id delegate;
    
    BOOL isHiddenBottomView;
}

@property(nonatomic, assign) id <BIDragRefreshTableViewDelegate> delegate;
@property(nonatomic, retain) UITableView *dragRefreshTableView;
@property(nonatomic, retain) BIRefreshTableHeaderView *bottomView;
@property(nonatomic, retain) BIRefreshTableHeaderView *headerView;
@property(nonatomic, assign) BOOL isHiddenBottomView;

//[tableView reloadData]后需要重新计算设置上拉刷新视图的位置
- (void)adjustBottomBIRefreshTableHeaderViewPos;
- (void)reloadData;
//加载数据完成，子类可以不重载;实现了默认动画行为，子类重载时必须调用父类方法
- (void)dataSourceDidFinishedLoad:(BIRefreshTableHeaderView *) refreshTableHeaderView;

-(void)beginShowHeadView;
//add by yinhh 2011-11-30 设置tableView是否可以被点击
-(void)enableSectionSelected:(BOOL)enable;

- (id)initWithFrame:(CGRect)frame isHiddenBottomView:(BOOL)m_bool;
@end

