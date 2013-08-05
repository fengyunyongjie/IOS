//
//  FirstLoadViewController.m
//  NetDisk
//
//  Created by Yangsl on 13-8-2.
//
//

#import "FirstLoadViewController.h"
#import "AppDelegate.h"
#define WIDTH self.view.frame.size.width
#define HEIGHT self.view.frame.size.height

@interface FirstLoadViewController ()

@end

@implementation FirstLoadViewController
@synthesize delegate;
@synthesize scroll_view;
@synthesize page_controller;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        scroll_view = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        [scroll_view setContentSize:CGSizeMake(WIDTH*4, HEIGHT)];
        [scroll_view setPagingEnabled:YES];
        [scroll_view setShowsHorizontalScrollIndicator:NO];
        [scroll_view setDelegate:self];
        [scroll_view setBackgroundColor:[UIColor clearColor]];
        NSString *deviece = [AppDelegate deviceString];
        BOOL isIPhone5 = NO;
        if([deviece rangeOfString:@"iPhone 5"].length>0)
        {
            isIPhone5 = YES;
        }
        for(int i=0;i<4;i++)
        {
            CGRect image_rect = CGRectMake(WIDTH*i, 0, WIDTH, HEIGHT);
            UIImageView *image_view = [[UIImageView alloc] initWithFrame:image_rect];
            if(isIPhone5)
            {
                [image_view setImage:[UIImage imageNamed:[NSString stringWithFormat:@"Page_%i@iPhone5.png",i+1]]];
            }
            else
            {
                [image_view setImage:[UIImage imageNamed:[NSString stringWithFormat:@"Page_%i.png",i+1]]];
            }
            
            [scroll_view addSubview:image_view];
            [image_view release];
        }
        [self.view addSubview:scroll_view];
        CGRect page_rect = CGRectMake((WIDTH-200)/2, HEIGHT-49, 200, 49);
        page_controller = [[UIPageControl alloc] initWithFrame:page_rect];
        [page_controller setNumberOfPages:3];
        [page_controller addTarget:self action:@selector(clicked_page:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:page_controller];
        
    }
    return self;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger page = scroll_view.contentOffset.x/WIDTH;
    if(scroll_view.contentOffset.x>WIDTH*2)
    {
        [page_controller setHidden:YES];
    }
    else
    {
        [page_controller setHidden:NO];
    }
    [page_controller setCurrentPage:page];
    if(scroll_view.contentOffset.x>WIDTH*3 || page==3)
    {
        [self.delegate uploadFinish];
        [self.view setHidden:YES];
    }
}

-(void)clicked_page:(id)sender
{
    UIPageControl *page = sender;
    if([page isKindOfClass:[UIPageControl class]])
    {
        [scroll_view setContentOffset:CGPointMake(WIDTH*page_controller.currentPage, 0) animated:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [scroll_view release];
    [page_controller release];
    [super dealloc];
}

@end
