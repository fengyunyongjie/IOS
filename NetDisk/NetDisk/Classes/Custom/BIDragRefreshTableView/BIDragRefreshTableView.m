//
//  BIDragRefreshTableViewController.m
//  EMBA
//
//  Created by haodu on 11-10-13.
//  Copyright 2011 haodu. All rights reserved.
//


#import "BIDragRefreshTableView.h"


const CGFloat kRefreshDeltaY = 65.0f;
const CGFloat ttkDefaultTransitionDuration      = 0.3;
const CGFloat ttkDefaultFastTransitionDuration  = 0.2;
const CGFloat ttkDefaultFlipTransitionDuration  = 0.7;

@interface BIRefreshTableHeaderView (Private)
- (void)setState:(BIPullRefreshState)aState;
@end

@implementation BIRefreshTableHeaderView (Private)

- (void)setState:(BIPullRefreshState)aState{
	
	switch (aState) {
		case BIReleaseToReload:
			_statusLabel.text = NSLocalizedString(@"松开即可更新...", @"松开即可更新...");
			[CATransaction begin];
			[CATransaction setAnimationDuration:ttkDefaultFlipTransitionDuration];
			if (_viewType == BIUpDragRefreshType) {
				_arrowImage.transform = CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f);
			}
			else {
				_arrowImage.transform = CATransform3DMakeRotation(M_PI * 2.0f, 0.0f, 0.0f, 1.0f);
			}
			
			[CATransaction commit];
			
			break;
		case BIDragToReload:
			
			if (_state == BIReleaseToReload) {
				[CATransaction begin];
				[CATransaction setAnimationDuration:ttkDefaultFlipTransitionDuration];
				if (_viewType == BIUpDragRefreshType) {
					_arrowImage.transform = CATransform3DIdentity;
				}
				else {
					_arrowImage.transform = CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f);
				}
				[CATransaction commit];
			}
			if (_viewType == BIUpDragRefreshType) {
				_statusLabel.text = NSLocalizedString(@"上拉即可更新...", @"上拉即可更新...");
			}
			else {
				_statusLabel.text = NSLocalizedString(@"下拉即可更新...", @"下拉即可更新...");
			}
			
			[_activityView stopAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			_arrowImage.hidden = NO;
			if (_viewType == BIUpDragRefreshType) {
				_arrowImage.transform = CATransform3DIdentity;
			}
			else {
				_arrowImage.transform = CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f);
			}
			[CATransaction commit];
			
			break;
		case BILoadingStatus:
			
			_statusLabel.text = NSLocalizedString(@"加载中...", @"加载中...");
			[_activityView startAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			_arrowImage.hidden = YES;
			[CATransaction commit];
			
			break;
		default:
			break;
	}
	
	_state = aState;
}

@end
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BIRefreshTableHeaderView
@synthesize _state;
@synthesize delegate;


- (id)initWithFrame:(CGRect)frame viewType:(BIDragRefreshType) aViewType {
    self = [super initWithFrame: frame];
    if (self) {
		
		self.delegate = nil;
		_viewType = aViewType;
		CGFloat originY = (_viewType == BIUpDragRefreshType ? kRefreshDeltaY : self.frame.size.height);
		
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = [UIColor clearColor]; //RGBCOLOR(226, 231, 237);
		
		_lastUpdatedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, originY - 30.0f, self.frame.size.width, 20.0f)];
		_lastUpdatedLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		_lastUpdatedLabel.font = [UIFont systemFontOfSize:12.0f];
		_lastUpdatedLabel.textColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
		_lastUpdatedLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		_lastUpdatedLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		_lastUpdatedLabel.backgroundColor = [UIColor clearColor];
		_lastUpdatedLabel.textAlignment = UITextAlignmentCenter;
		[self addSubview:_lastUpdatedLabel];
		
		_statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, originY - 48.0f, self.frame.size.width, 20.0f)];
		_statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		_statusLabel.font = [UIFont systemFontOfSize:13.0f]; //boldSystemFontOfSize
		_statusLabel.textColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
		_statusLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		_statusLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		_statusLabel.backgroundColor = [UIColor clearColor];
		_statusLabel.textAlignment = UITextAlignmentCenter;
		[self addSubview:_statusLabel];
		
		_arrowImage = [CALayer layer];
		_arrowImage.frame = CGRectMake(25.0f, originY-kRefreshDeltaY, 30.0f, 55.0f);
		_arrowImage.contentsGravity = kCAGravityResizeAspect;
		_arrowImage.contents = (id)[UIImage imageNamed:@"箭头.png"].CGImage;
		
		if (_viewType == BIDownDragRefreshType) {
			_arrowImage.transform = CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f);
		}
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
			_arrowImage.contentsScale = [[UIScreen mainScreen] scale];
		}
#endif
		
		[[self layer] addSublayer:_arrowImage];
		
		_activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		_activityView.frame = CGRectMake(25.0f, originY - 38.0f, 20.0f, 20.0f);
		[self addSubview:_activityView];
		
		[self setState:BIDragToReload];
		
    }
	
    return self;
	
}


#pragma mark -
#pragma mark Setters

- (void)refreshLastUpdatedDate:(NSDate*)date {
	
	if (nil != date) {
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setAMSymbol:@"上午"];
		[formatter setPMSymbol:@"下午"];
		[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
		_lastUpdatedLabel.text = [NSString stringWithFormat:@"最后更新: %@", [formatter stringFromDate:date]];
        
		[formatter release];
		
	} else {
		
		_lastUpdatedLabel.text = @"最后更新: 未知";
		
	}
	
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark ScrollView Methods

//手指屏幕上不断拖动调用此方法
- (void)RefreshScrollViewDidScroll:(UIScrollView *)scrollView {
	if (delegate && [delegate respondsToSelector:@selector(refreshTableHeaderViewDataSourceCanStartLoad:)]) {
		if (![self.delegate refreshTableHeaderViewDataSourceCanStartLoad]) {
			return;
		}
	}
	
	if (scrollView.isDragging && _state != BILoadingStatus) {
		if (_viewType == BIDownDragRefreshType) {
			if (_state == BIReleaseToReload 
				&& scrollView.contentOffset.y > -kRefreshDeltaY
				&& scrollView.contentOffset.y < 0.0f) { // 往下拖动,但是距离还不够;或者没拖够距离的情况下,又往回拖了.
				[self setState:BIDragToReload];
				
			} else if (_state == BIDragToReload 
					   && scrollView.contentOffset.y < -kRefreshDeltaY) { // 往下拖动的距离够了,只要一释放就会刷新.
				[self setState:BIReleaseToReload];
			}
		}
		else if (_viewType == BIUpDragRefreshType) {
			if (_state == BIReleaseToReload
				&& scrollView.contentOffset.y + scrollView.frame.size.height < scrollView.contentSize.height + kRefreshDeltaY 
				&& scrollView.contentOffset.y > 0.0f) { // 往上拖动,但是距离还不够;或者没拖够距离的情况下,又往回拖了.
				[self setState:BIDragToReload];
			} else if (_state == BIDragToReload 
					   && scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height + kRefreshDeltaY
					   && scrollView.contentOffset.y > 0.0f) {
				// 往上拖动的距离够了,只要一释放就会刷新.
				[self setState:BIReleaseToReload];
			}
		}
	}
	
}


//当用户停止拖动，并且手指从屏幕中拿开的的时候调用此方法
- (void)RefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
	
	if (delegate && [delegate respondsToSelector:@selector(refreshTableHeaderViewDataSourceCanStartLoad:)]) {
		if (![self.delegate refreshTableHeaderViewDataSourceCanStartLoad]) {
			return;
		}
	}
	
	// 如果当前不是正在刷性的状态下, 只要拖动的距离足够显示头部的视图,那么就触发刷新.
	if (_viewType == BIDownDragRefreshType 
		&& scrollView.contentOffset.y < -kRefreshDeltaY 
		&& _state == BIReleaseToReload) {
		[self setState:BILoadingStatus];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:ttkDefaultFastTransitionDuration];
		scrollView.contentInset = UIEdgeInsetsMake(kRefreshDeltaY, 0.0f, 0.0f, 0.0f);
		
		[UIView commitAnimations];
		
		if (delegate && [delegate respondsToSelector:@selector(refreshTableHeaderViewDataSourceDidStartLoad:)]) {
			[self.delegate refreshTableHeaderViewDataSourceDidStartLoad:self];
		}
		
		
	}
	
	else if (_viewType == BIUpDragRefreshType 
			 && scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height + kRefreshDeltaY
			 && scrollView.contentOffset.y > 0
			 && _state == BIReleaseToReload) {
		[self setState:BILoadingStatus];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:ttkDefaultFastTransitionDuration];
		scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, kRefreshDeltaY, 0.0f);
		
		[UIView commitAnimations];
		
		if (delegate && [delegate respondsToSelector:@selector(refreshTableHeaderViewDataSourceDidStartLoad:)]) {
			[self.delegate refreshTableHeaderViewDataSourceDidStartLoad:self];
		}
	}
	
}



//当开发者页面页面刷新完毕调用此方法
- (void)RefreshScrollViewDataSourceDidFinishedLoad:(UIScrollView *)scrollView {	
	
	[self refreshLastUpdatedDate:[NSDate date]];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:ttkDefaultTransitionDuration];
	scrollView.contentInset = UIEdgeInsetsZero;
	[UIView commitAnimations];
	
	[self setState:BIDragToReload];
	
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//主动显示“正在加载”的头界面
- (void)modelDidStartLoad:(UIScrollView *)scrollView {
	[self setState:BILoadingStatus];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:ttkDefaultFastTransitionDuration];
	scrollView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 00.0f, 0.0f);
	[UIView commitAnimations];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	self.delegate = nil;
	[_activityView release];
	[_statusLabel release];
	[_lastUpdatedLabel release];
    [super dealloc];
}


@end


//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////

@implementation BIDragRefreshTableView

@synthesize delegate;
@synthesize dragRefreshTableView;
@synthesize headerView,bottomView;
@synthesize isHiddenBottomView;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame: frame]) != nil) {
		// 添加tabelview
		isHiddenBottomView = YES;
		CGRect subframe = frame;
		subframe.origin.x = 0;
		subframe.origin.y = 0;
		
		dragRefreshTableView = [[UITableView alloc] initWithFrame: subframe];
		
		dragRefreshTableView.showsHorizontalScrollIndicator = NO;
		dragRefreshTableView.showsVerticalScrollIndicator = YES;
	//	dragRefreshTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        dragRefreshTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
		dragRefreshTableView.allowsSelection = NO;
		
		dragRefreshTableView.delegate = self;
		dragRefreshTableView.dataSource = self;
		[self addSubview:dragRefreshTableView];
		
		dragRefreshTableView.backgroundColor = [UIColor clearColor];
		
		// 添加头部视图.
		subframe = CGRectMake(0.0f, -dragRefreshTableView.bounds.size.height, 
							  dragRefreshTableView.bounds.size.width, 
							  dragRefreshTableView.bounds.size.height);
		
		headerView = [[BIRefreshTableHeaderView alloc] initWithFrame: subframe 
															viewType:BIDownDragRefreshType];
		
		[dragRefreshTableView addSubview:headerView];
		
		[headerView refreshLastUpdatedDate:nil];
		
		// 添加尾部视图.
		
		subframe = CGRectMake(0.0f, 
							  dragRefreshTableView.contentSize.height > dragRefreshTableView.frame.size.height ? 
							  dragRefreshTableView.contentSize.height : dragRefreshTableView.frame.size.height, 
							  dragRefreshTableView.bounds.size.width, 
							  dragRefreshTableView.bounds.size.height);

//remove by yinhh 2013-1-21 不要上拉
        if (!isHiddenBottomView) {
            bottomView = [[BIRefreshTableHeaderView alloc] initWithFrame: subframe  
                                                                viewType:BIUpDragRefreshType];
            [dragRefreshTableView addSubview:bottomView];
            
            [bottomView refreshLastUpdatedDate:nil];
        }
		
		
	} 
	return self;
}

- (id)initWithFrame:(CGRect)frame isHiddenBottomView:(BOOL)m_bool {
    if ((self = [super initWithFrame: frame]) != nil) {
		// 添加tabelview
		isHiddenBottomView = m_bool;
		CGRect subframe = frame;
		subframe.origin.x = 0;
		subframe.origin.y = 0;
		
		dragRefreshTableView = [[UITableView alloc] initWithFrame: subframe];
		
		dragRefreshTableView.showsHorizontalScrollIndicator = NO;
		dragRefreshTableView.showsVerticalScrollIndicator = YES;
        //	dragRefreshTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        dragRefreshTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
		dragRefreshTableView.allowsSelection = NO;
		
		dragRefreshTableView.delegate = self;
		dragRefreshTableView.dataSource = self;
		[self addSubview:dragRefreshTableView];
		
		dragRefreshTableView.backgroundColor = [UIColor clearColor];
		
		// 添加头部视图.
		subframe = CGRectMake(0.0f, -dragRefreshTableView.bounds.size.height, 
							  dragRefreshTableView.bounds.size.width, 
							  dragRefreshTableView.bounds.size.height);
		
		headerView = [[BIRefreshTableHeaderView alloc] initWithFrame: subframe 
															viewType:BIDownDragRefreshType];
		
		[dragRefreshTableView addSubview:headerView];
		
		[headerView refreshLastUpdatedDate:nil];
		
		// 添加尾部视图.
		
		subframe = CGRectMake(0.0f, 
							  dragRefreshTableView.contentSize.height > dragRefreshTableView.frame.size.height ? 
							  dragRefreshTableView.contentSize.height : dragRefreshTableView.frame.size.height, 
							  dragRefreshTableView.bounds.size.width, 
							  dragRefreshTableView.bounds.size.height);
        
        //remove by yinhh 2013-1-21 不要上拉
        if (!isHiddenBottomView) {
            bottomView = [[BIRefreshTableHeaderView alloc] initWithFrame: subframe  
                                                                viewType:BIUpDragRefreshType];
            [dragRefreshTableView addSubview:bottomView];
            
            [bottomView refreshLastUpdatedDate:nil];
        }
		
		
	} 
	return self;
}

- (void)setDelegate:(id <BIDragRefreshTableViewDelegate>)aDelegate {
	delegate = aDelegate;
	headerView.delegate = self.delegate;

    //remove by yinhh 2013-1-21 不要上拉
    if (!isHiddenBottomView) {
        bottomView.delegate = self.delegate;
    }
	
}

- (void)adjustBottomBIRefreshTableHeaderViewPos {
    if (!isHiddenBottomView) {
        CGRect frame = CGRectMake(0.0f, 
                                  dragRefreshTableView.contentSize.height > dragRefreshTableView.frame.size.height ? 
                                  dragRefreshTableView.contentSize.height : dragRefreshTableView.frame.size.height,
                                  dragRefreshTableView.bounds.size.width, 
                                  dragRefreshTableView.bounds.size.height);
        [bottomView setFrame:frame];
    }
	
 
}

- (void)reloadData {
	[dragRefreshTableView reloadData];
	[self adjustBottomBIRefreshTableHeaderViewPos];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView*)scrollView {	
//remove by yinhh 2013-1-21 不要上拉
    if (!isHiddenBottomView) {
        if ([headerView state] != BILoadingStatus && [bottomView state] != BILoadingStatus) {
            
            [headerView RefreshScrollViewDidScroll:scrollView];
            [bottomView RefreshScrollViewDidScroll:scrollView];
        }
    }
    else{
        //	if ([headerView state] != BILoadingStatus && [bottomView state] != BILoadingStatus) {
        if ([headerView state] != BILoadingStatus ) {
            [headerView RefreshScrollViewDidScroll:scrollView];
            //		[bottomView RefreshScrollViewDidScroll:scrollView];
        }
    }
    

}

- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView willDecelerate:(BOOL)decelerate {
    //remove by yinhh 2013-1-21 不要上拉
    if (!isHiddenBottomView) {
        if ([headerView state] != BILoadingStatus && [bottomView state] != BILoadingStatus) {
            [headerView RefreshScrollViewDidEndDragging:scrollView];
            [bottomView RefreshScrollViewDidEndDragging:scrollView];
        }
    }
    else{
        //	if ([headerView state] != BILoadingStatus && [bottomView state] != BILoadingStatus) {
        if ([headerView state] != BILoadingStatus) {
            [headerView RefreshScrollViewDidEndDragging:scrollView];
            //		[bottomView RefreshScrollViewDidEndDragging:scrollView];
        }
    }


	
}

//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Table view methods
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (delegate && [delegate respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
		return [self.delegate tableView:tableView titleForHeaderInSection:section];
	}
	return nil;
	
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (delegate && [delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)]) {
		return [self.delegate tableView:tableView heightForHeaderInSection:section];
	}
	return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (delegate && [delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
		return [self.delegate tableView:tableView viewForHeaderInSection:section];
	}
	return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (delegate && [delegate respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
		return [self.delegate numberOfSectionsInTableView:tableView];
	}
	return 0;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (delegate && [delegate respondsToSelector:@selector(tableView:numberOfRowsInSection:)]) {
		return [self.delegate tableView:tableView numberOfRowsInSection:section];
	}
	return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (delegate && [delegate respondsToSelector:@selector(tableView:cellForRowAtIndexPath:)]) {
		return [self.delegate tableView:tableView cellForRowAtIndexPath:indexPath];
	}
	return nil;	
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (delegate && [delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
		[self.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (delegate && [delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
		return [self.delegate tableView:tableView heightForRowAtIndexPath:indexPath];
	}
	return 0.0f;	
	
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	// Return NO if you do not want the specified item to be editable.
	if (delegate && [delegate respondsToSelector:@selector(tableView:canEditRowAtIndexPath:)]) {
		return [self.delegate tableView:tableView canEditRowAtIndexPath:indexPath];
	}
	return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (delegate && [delegate respondsToSelector:@selector(tableView:editingStyleForRowAtIndexPath:)]) {
		return (UITableViewCellEditingStyle)[self.delegate tableView:tableView editingStyleForRowAtIndexPath:indexPath];
	}
	return UITableViewCellEditingStyleNone;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (delegate && [delegate respondsToSelector:@selector(tableView:commitEditingStyle:forRowAtIndexPath:)]) {
		[self.delegate tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
	}
}




// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	if (delegate && [delegate respondsToSelector:@selector(tableView:moveRowAtIndexPath:toIndexPath:)]) {
		[self.delegate tableView:tableView moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
	}
}




// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	if (delegate && [delegate respondsToSelector:@selector(tableView:canMoveRowAtIndexPath:)]) {
		return [self.delegate tableView:tableView canMoveRowAtIndexPath:indexPath];
	}
	return NO;
}

//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////

- (void)dataSourceDidFinishedLoad:(BIRefreshTableHeaderView *) refreshTableHeaderView {
	
	[refreshTableHeaderView RefreshScrollViewDataSourceDidFinishedLoad:dragRefreshTableView];
}

-(void)beginShowHeadView{
	[headerView modelDidStartLoad:dragRefreshTableView];
}

-(void)enableSectionSelected:(BOOL)enable{
	dragRefreshTableView.allowsSelection = enable;
}
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////

- (void)dealloc {
	
	[headerView release];
    if (!isHiddenBottomView) {
        [bottomView release];
    }

//	[dragRefreshTableView release];
    [super dealloc];
}

@end
