//
//  SCBReportManager.h
//  NetDisk
//
//  Created by fengyongning on 13-8-14.
//
//

#import <Foundation/Foundation.h>
typedef enum{
    kReportSend,
} kReportType;
@protocol SCBReportManagerDelegate
-(void)sendReportSucceed;
-(void)sendReportUnsucceed;
@end
@interface SCBReportManager : NSObject<NSURLConnectionDelegate>
@property(strong,nonatomic) NSMutableString *activeData;
@property(nonatomic,weak) id<SCBReportManagerDelegate> delegate;
@property(nonatomic,assign) kReportType type;
-(void)callAllTask;
-(void)sendReport:(NSString *)report;
@end
