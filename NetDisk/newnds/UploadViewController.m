//
//  UploadViewController.m
//  NetDisk
//
//  Created by fengyongning on 13-5-21.
//
//

#import "UploadViewController.h"

@interface UploadViewController ()

@end

@implementation UploadViewController

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
    allHeight = self.view.frame.size.height - 49;
    CGRect rect =  _uploadNumber.frame;
    rect.origin.y =  (allHeight-(519-rect.origin.y));
    [_uploadNumber setFrame:rect];
    
    rect =  self.stateImageview.frame;
    rect.origin.y =  (allHeight-(519-rect.origin.y));
    [self.stateImageview setFrame:rect];
    
    rect =  self.nameLabel.frame;
    rect.origin.y =  (allHeight-(519-rect.origin.y));
    [self.nameLabel setFrame:rect];
    
    rect =  self.diyUploadButton.frame;
    rect.origin.y =  (allHeight-(519-rect.origin.y));
    [self.diyUploadButton setFrame:rect];
    
    rect =  self.basePhotoLabel.frame;
    rect.origin.y =  (allHeight-(519-rect.origin.y));
    [self.basePhotoLabel setFrame:rect];
    
    rect =  self.formatLabel.frame;
    rect.origin.y =  (allHeight-(519-rect.origin.y));
    [self.formatLabel setFrame:rect];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)upLoad
{
    
}

- (void)dealloc {
    [_uploadNumber release];
    [_basePhotoLabel release];
    [_formatLabel release];
    [_uploadTypeButton release];
    [_stateImageview release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setUploadNumber:nil];
    [super viewDidUnload];
}
@end
