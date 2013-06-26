//
//  DefaultViewController.m
//  NetDisk
//
//  Created by fengyongning on 13-6-6.
//
//

#import "DefaultViewController.h"

@interface DefaultViewController ()

@end

@implementation DefaultViewController

- (BOOL)shouldAutorotate{
    return NO;
}

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
    CGSize wsize=[[UIScreen mainScreen] bounds].size;
    UIImage *image;
    if (wsize.height>500) {
        image=[UIImage imageNamed:@"Default-568h@2x.png"];
    }else
    {
        image=[UIImage imageNamed:@"Default@2x.png"];
    }
    
    UIImageView *imageView=[[UIImageView alloc] initWithImage:image];
    imageView.frame=[[UIScreen mainScreen] bounds];
    self.view=imageView;
    //[imageView release];
    //[image release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
