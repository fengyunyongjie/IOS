//
//  PhotoViewController.m
//  NetDisk
//
//  Created by Yangsl on 13-5-2.
//
//

#import "PhotoViewController.h"
#import "SBJSON.h"

@interface PhotoViewController ()

@end

@implementation PhotoViewController
@synthesize photoManager;

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
    //添加分享按钮
    UINavigationItem *nav_item = [self navigationItem];
    UIButton *right_button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect rect = CGRectMake(300, 7, 24, 24);
    [right_button setFrame:rect];
    [right_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [right_button.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0]];
    [right_button setBackgroundImage:[UIImage imageNamed:@"u102_normal"] forState:UIControlStateNormal];
    [right_button setTitle:@"提交" forState:UIControlStateNormal];
    [right_button addTarget:self action:@selector(right_button_cilcked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *right_item = [[UIBarButtonItem alloc] initWithCustomView:right_button];
    [nav_item setRightBarButtonItem:right_item];
    photoManager = [[SCBPhotoManager alloc] init];
    [photoManager setPhotoDelegate:self];
    [photoManager getPhotoTimeLine];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -标题栏的提交按钮
-(void)right_button_cilcked:(id)sender
{
    
}

#pragma mark -得到时间轴的列表
-(void)getPhotoTiimeLine:(NSDictionary *)dictionary
{
    //解析时间轴
    //今天,请求今天的概要图片
    NSString *timeLine = [dictionary objectForKey:@"timeline"];
    timeLine = @"[2013,[05]],[2013,[06]],[2013,[07]],[2013,[08]],[2013,[09]],[2013,[10]],[2013,[11]]";
    NSMutableArray *tableArray = [[NSMutableArray alloc] init];
    NSRange range = [timeLine rangeOfString:@"],"];
//    while (range.location>0) {
//        NSString *time_string = [timeLine substringToIndex:range.location+1];
//        [tableArray addObject:time_string];
//        timeLine = [timeLine substringFromIndex:12];
//        range = [timeLine rangeOfString:@"],"];
//    }
//    if([timeLine length]>0)
//    {
//        NSString *time_string = [NSString stringWithFormat:@"%@-%@",[[timeLine substringToIndex:5] substringFromIndex:1],[[timeLine substringToIndex:9] substringFromIndex:7]];
//        [tableArray addObject:time_string];
//    }
    //昨天
    //本周
    //上一周
    //本月
    //上一月
    //本年
    //xxxx年
}

-(void)getPhotoGeneral:(NSDictionary *)dictionary
{

}

-(void)getPhotoDetail:(NSDictionary *)dictionary
{
    
}

-(void)dealloc
{
    [photoManager release];
    [super dealloc];
}

@end
