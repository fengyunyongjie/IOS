//
//  QLBrowserViewController.h
//  NetDisk
//
//  Created by fengyongning on 13-6-24.
//
//

#import <QuickLook/QuickLook.h>

@interface QLBrowserViewController : QLPreviewController<QLPreviewControllerDataSource,QLPreviewControllerDelegate>
@property (nonatomic,strong) NSString *filePath;
@property (nonatomic,strong) NSString *fileName;
@end
