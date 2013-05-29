//
//  OpenViewController.m
//  NetDisk
//
//  Created by fengyongning on 13-5-29.
//
//

#import "OpenViewController.h"
#import "YNFunctions.h"

@interface OpenViewController ()

@end

@implementation OpenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(IBAction)cancelAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)configUrl:(NSURL *)url
{
    self.fileUrl=url;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
