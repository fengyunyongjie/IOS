//
//  ImageBrowserViewController.m
//  NetDisk
//
//  Created by fengyongning on 13-5-10.
//
//

#import "ImageBrowserViewController.h"

@interface ImageBrowserViewController ()

@end

@implementation ImageBrowserViewController

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
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.scrollView=[[[UIScrollView alloc] initWithFrame:self.view.bounds] autorelease];
    [self.view addSubview:self.scrollView];
    self.fileDownloaders=[[[NSMutableDictionary alloc] init] autorelease];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
