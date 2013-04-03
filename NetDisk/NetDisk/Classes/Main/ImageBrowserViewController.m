//
//  ImageBrowserViewController.m
//  NetDisk
//
//  Created by fengyongning on 13-4-3.
//
//
#define PADDING                 10
#import "ImageBrowserViewController.h"

@interface ImageBrowserViewController (){
    UIScrollView *_pagingScrollView;
    NSUInteger _photoCount;
    UIToolbar * _toolbar;
    UIBarButtonItem *_previousViewControllerBackButton;
}
@property (nonatomic, retain) UIBarButtonItem *previousViewControllerBackButton;
@end

@implementation ImageBrowserViewController
@synthesize previousViewControllerBackButton = _previousViewControllerBackButton;
- (id)init {
    if ((self = [super init])) {
        
        // Defaults
        self.wantsFullScreenLayout = YES;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}
- (CGRect)frameForPagingScrollView {
    CGRect frame = self.view.bounds;// [[UIScreen mainScreen] bounds];
    frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);
    return frame;
}
- (CGSize)contentSizeForPagingScrollView {
    // We have to use the paging scroll view's bounds to calculate the contentSize, for the same reason outlined above.
    CGRect bounds = _pagingScrollView.bounds;
    return CGSizeMake(bounds.size.width * 100, bounds.size.height);
}
- (CGRect)frameForToolbarAtOrientation:(UIInterfaceOrientation)orientation {
    CGFloat height = 44;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone &&
        UIInterfaceOrientationIsLandscape(orientation)) height = 32;
	return CGRectMake(0, self.view.bounds.size.height - height, self.view.bounds.size.width, height);
}
- (void)viewDidLoad
{
    // View
	self.view.backgroundColor = [UIColor blackColor];
    
    // Setup paging scrolling view
	CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
	_pagingScrollView = [[UIScrollView alloc] initWithFrame:pagingScrollViewFrame];
	_pagingScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_pagingScrollView.pagingEnabled = YES;
	_pagingScrollView.delegate = self;
	_pagingScrollView.showsHorizontalScrollIndicator = YES;
	_pagingScrollView.showsVerticalScrollIndicator = NO;
	_pagingScrollView.backgroundColor = [UIColor blackColor];
    _pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
	[self.view addSubview:_pagingScrollView];
    // Toolbar
    _toolbar = [[UIToolbar alloc] initWithFrame:[self frameForToolbarAtOrientation:self.interfaceOrientation]];
    _toolbar.tintColor = nil;
    if ([[UIToolbar class] respondsToSelector:@selector(appearance)]) {
        [_toolbar setBackgroundImage:nil forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        [_toolbar setBackgroundImage:nil forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsLandscapePhone];
    }
    _toolbar.barStyle = UIBarStyleBlackTranslucent;
    _toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_toolbar];
    
    // Navigation buttons
    if ([self.navigationController.viewControllers objectAtIndex:0] == self) {
        // We're first on stack so show done button
        UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonPressed:)] autorelease];
        // Set appearance
        if ([UIBarButtonItem respondsToSelector:@selector(appearance)]) {
            [doneButton setBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
            [doneButton setBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
            [doneButton setBackgroundImage:nil forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
            [doneButton setBackgroundImage:nil forState:UIControlStateHighlighted barMetrics:UIBarMetricsLandscapePhone];
            [doneButton setTitleTextAttributes:[NSDictionary dictionary] forState:UIControlStateNormal];
            [doneButton setTitleTextAttributes:[NSDictionary dictionary] forState:UIControlStateHighlighted];
        }
        self.navigationItem.rightBarButtonItem = doneButton;
    } else {
        // We're not first so show back button
        UIViewController *previousViewController = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
        NSString *backButtonTitle = previousViewController.navigationItem.backBarButtonItem ? previousViewController.navigationItem.backBarButtonItem.title : previousViewController.title;
        UIBarButtonItem *newBackButton = [[[UIBarButtonItem alloc] initWithTitle:backButtonTitle style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
        // Appearance
        if ([UIBarButtonItem respondsToSelector:@selector(appearance)]) {
            [newBackButton setBackButtonBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
            [newBackButton setBackButtonBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
            [newBackButton setBackButtonBackgroundImage:nil forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
            [newBackButton setBackButtonBackgroundImage:nil forState:UIControlStateHighlighted barMetrics:UIBarMetricsLandscapePhone];
            [newBackButton setTitleTextAttributes:[NSDictionary dictionary] forState:UIControlStateNormal];
            [newBackButton setTitleTextAttributes:[NSDictionary dictionary] forState:UIControlStateHighlighted];
        }
        self.previousViewControllerBackButton = previousViewController.navigationItem.backBarButtonItem; // remember previous
        previousViewController.navigationItem.backBarButtonItem = newBackButton;
    }

    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
- (void)viewWillDisappear:(BOOL)animated {
    
    // Check that we're being popped for good
    if ([self.navigationController.viewControllers objectAtIndex:0] != self &&
        ![self.navigationController.viewControllers containsObject:self]) {
        
        // State
        //_viewIsActive = NO;
        
        // Bar state / appearance
        [self restorePreviousNavBarAppearance:animated];
        
    }
    
    // Controls
    [self.navigationController.navigationBar.layer removeAllAnimations]; // Stop all animations on nav bar
    [NSObject cancelPreviousPerformRequestsWithTarget:self]; // Cancel any pending toggles from taps
    [self setControlsHidden:NO animated:NO permanent:YES];
    
    // Status bar
    if (self.wantsFullScreenLayout && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        //[[UIApplication sharedApplication] setStatusBarStyle:_previousStatusBarStyle animated:animated];
    }
    
	// Super
	[super viewWillDisappear:animated];
    
}
#pragma mark - Nav Bar Appearance

- (void)setNavBarAppearance:(BOOL)animated {
    self.navigationController.navigationBar.tintColor = nil;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    if ([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsLandscapePhone];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
