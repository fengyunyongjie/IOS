//
//  PhotoDetailViewController.m
//  NetDisk
//
//  Created by Yangsl on 13-5-6.
//
//

#import "PhotoDetailViewController.h"
#import "PhohoDemo.h"
#import "PhotoDetailView.h"

@interface PhotoDetailViewController ()

@end

@implementation PhotoDetailViewController
@synthesize scrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    CGRect scrollRect = CGRectMake(0, 0, 320, 480);
    scrollView = [[UIScrollView alloc] initWithFrame:scrollRect];
    [self.view addSubview:scrollView];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)dealloc
{
    [scrollView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 加载所有数据
-(void)loadAllDiction:(NSArray *)allArray currtimeIdexTag:(int)indexTag
{
    for(int i=0;i<[allArray count];i++)
    {
        PhohoDemo *demo = (PhohoDemo *)[allArray objectAtIndex:i];
        CGRect detailRect =  CGRectMake(0, 0, 320, 480);
        PhotoDetailView *detailView = [[PhotoDetailView alloc] initWithFrame:detailRect];
//        [detailView.topButton setTitle:@"返回" forState:<#(UIControlState)#>]
//        detailView
    }
}

@end
