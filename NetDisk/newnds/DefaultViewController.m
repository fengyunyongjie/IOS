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
    UIImage *image=[UIImage imageNamed:@"Default-568h@2x.png"];
    UIImageView *imageView=[[UIImageView alloc] initWithImage:image];
    imageView.frame=CGRectMake(0, -20, 320, 568);
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
