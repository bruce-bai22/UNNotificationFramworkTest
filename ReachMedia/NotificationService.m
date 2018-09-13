//
//  NotificationService.m
//  ReachMedia
//
//  Created by Baitianyu on 2018/9/11.
//  Copyright © 2018 Baitianyu. All rights reserved.
//

#import "NotificationService.h"

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    // Modify the notification content here...
    // 本地图片
    //    [self setLocalImageAttachmentWithRequest:request content:self.bestAttemptContent];
    
    // 远程图片
    [self setRemoteImageAttachmentWithRequest:request content:self.bestAttemptContent];
    
    // 简单的修改标题
    //    self.bestAttemptContent.title = [NSString stringWithFormat:@"%@ [modified]", self.bestAttemptContent.title];
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

# pragma mark - Helper methods

- (void)setLocalImageAttachmentWithRequest:(UNNotificationRequest *)request
                                   content:(UNMutableNotificationContent *)content {
    NSString *urlStr = [request.content.userInfo valueForKey:@"attachment"];
    NSArray *urls = [urlStr componentsSeparatedByString:@"."];
    NSURL *urlValue = [[NSBundle mainBundle] URLForResource:urls[0] withExtension:urls[1]];
    
    UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:urlStr URL:urlValue options:nil error:nil];
    self.bestAttemptContent.attachments = @[attachment];
}

- (void)setRemoteImageAttachmentWithRequest:(UNNotificationRequest *)request
                                    content:(UNMutableNotificationContent *)content {
//    content.title = [NSString stringWithFormat:@"%@ [world]", content.title];
    //1. 获取 url 字符串，处理不合法字符
    NSString *urlStr = [request.content.userInfo valueForKey:@"attachment"];
    //    urlStr =[urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet new]];
    NSURL *url=[NSURL URLWithString:urlStr];
    //2.创建请求
    NSMutableURLRequest *fileRequest=[NSMutableURLRequest requestWithURL:url];
    
    //3.创建会话（这里使用了一个全局会话）并且启动任务
    NSURLSession *session=[NSURLSession sharedSession];
    
    NSString *cachePath=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *savePath=[cachePath stringByAppendingPathComponent:@"remote.jpg"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:savePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:savePath error:nil];
    }
    NSURLSessionDownloadTask *downloadTask=[session downloadTaskWithRequest:fileRequest completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        if (!error) {
            //注意location是下载后的临时保存路径,需要将它移动到需要保存的位置
            NSError *saveError;
            NSString *cachePath=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
            NSString *savePath=[cachePath stringByAppendingPathComponent:@"remote.jpg"];
            NSLog(@"%@",savePath);
            NSURL *saveUrl=[NSURL fileURLWithPath:savePath];
            [[NSFileManager defaultManager] copyItemAtURL:location toURL:saveUrl error:&saveError];
            if (!saveError) {
                NSLog(@"save sucess.");
            }else{
                NSLog(@"error is :%@",saveError.localizedDescription);
            }
            
            // 添加附件
            UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"remote-image" URL:saveUrl options:nil error:nil];
            self.bestAttemptContent.attachments = @[attachment];
            self.contentHandler(content);
        }else{
            NSLog(@"error is :%@",error.localizedDescription);
            self.contentHandler(content);
        }
    }];
    [downloadTask resume];
    
}

@end
