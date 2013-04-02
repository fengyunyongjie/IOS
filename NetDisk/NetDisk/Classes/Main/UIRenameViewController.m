//
//  UIRenameViewController.m
//  NetDisk
//
//  Created by jiangwei on 13-1-15.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "UIRenameViewController.h"
void callBackRenameFunc(Value &jsonValue,void *s_pv);

@implementation UIRenameViewController
@synthesize m_reanmeDic,m_textField;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;    
}

- (void)dealloc
{
    [m_textField release];
    [m_reanmeDic release];
    [m_hud release];
    
    [super dealloc];
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    m_hud = [[ATMHud alloc] initWithDelegate:self];
	[self.view addSubview:m_hud.view];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.m_textField.text=[m_reanmeDic objectForKey:@"f_name"];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)comeBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender
{
    if (m_reanmeDic) {
        [m_textField resignFirstResponder];
        [m_hud setCaption:@"正在重命名"];
        [m_hud setActivity:YES];
        [m_hud show];
        NSString *f_id = [Function covertNumberToString:[m_reanmeDic objectForKey:@"f_id"]];
        NSString *newName = m_textField.text;
        scBox.FmReName([f_id cStringUsingEncoding:NSUTF8StringEncoding], [newName cStringUsingEncoding:NSUTF8StringEncoding],callBackRenameFunc,self);
    }
   
}
void callBackRenameFunc(Value &jsonValue,void *s_pv)
{
    string vall = jsonValue.toStyledString().c_str();
    NSString *vallStr = [NSString stringWithCString:vall.c_str() encoding:NSUTF8StringEncoding];
    [s_pv showFmRenameView:vallStr];
}
- (void)showFmRenameView:(NSString *)theData
{
    NSDictionary *valueDic = [theData JSONValue];
    
    int code = [[valueDic objectForKey:@"code"]intValue];
    if (code==0) {
        [m_hud setCaption:@"重命名成功"];
        [m_hud setImage:[UIImage imageNamed:@"19-check"]];
        [m_reanmeDic setObject:m_textField.text forKey:@"f_name"];
    }
    else{
        [m_hud setCaption:@"重命名失败"];
        [m_hud setImage:[UIImage imageNamed:@"11-x"]];
    }
    [m_hud setActivity:NO];
    [m_hud update];
    if (code==0) {
        [self performSelectorOnMainThread:@selector(popController) withObject:nil waitUntilDone:YES];
    }
    else
    {
        [self performSelectorOnMainThread:@selector(hiddenHub) withObject:nil waitUntilDone:NO];
    }
    
}
- (void)hiddenHub
{
    [m_hud hideAfter:0.8f];
}
- (void)popController
{
    [self performSelector:@selector(popME) withObject:nil afterDelay:0.8f];
}
- (void)popME
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
