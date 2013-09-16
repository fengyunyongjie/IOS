//
//  HelpViewController.m
//  NetDisk
//
//  Created by fengyongning on 13-9-16.
//
//

#import "HelpViewController.h"
#import "AppDelegate.h"
@interface HelpViewController ()

@end

@implementation HelpViewController

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
        image=[UIImage imageNamed:@"Bk_Tip@iPhone5.png"];
    }else
    {
        image=[UIImage imageNamed:@"Bk_Tip.png"];
    }
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    imageView.image=image;
    [self.view addSubview:imageView];
    UITapGestureRecognizer *t=[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(finished:)] autorelease];
    t.delegate=self;
    [self.view addGestureRecognizer:t];
}
-(void)finished:(UITapGestureRecognizer*)tap
{
    CGPoint p=[tap locationInView:tap.view];
    NSLog(@"single tap:%f %f",p.x,p.y);
    switch (self.thisType) {
        case kTypeMySB:
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"showHelpInMSB"];
            break;
        case kTypeHomeSpace:
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"showHelpInHS"];
            break;
        default:
            break;
    }
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    [delegate finished];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
