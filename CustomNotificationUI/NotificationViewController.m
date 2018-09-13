//
//  NotificationViewController.m
//  CustomNotificationUI
//
//  Created by Baitianyu on 2018/9/12.
//  Copyright © 2018 Baitianyu. All rights reserved.
//

#import "NotificationViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>

@interface NotificationViewController () <UNNotificationContentExtension>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) UILabel *bodyLabel;

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any required interface initialization here.
    [self loadSubviews];
}

- (void)loadSubviews {
    _titleLabel = [[UILabel alloc] init];
    [_titleLabel setTextColor:[UIColor blackColor]];
    [_titleLabel setFont:[UIFont systemFontOfSize:16]];
    [self.view addSubview:_titleLabel];
    
    _subTitleLabel = [[UILabel alloc] init];
    [_subTitleLabel setTextColor:[UIColor blackColor]];
    [_subTitleLabel setFont:[UIFont systemFontOfSize:14]];
    [self.view addSubview:_subTitleLabel];
    
    _bodyLabel = [[UILabel alloc] init];
    [_bodyLabel setTextColor:[UIColor blackColor]];
    [_bodyLabel setFont:[UIFont systemFontOfSize:12]];
    [_bodyLabel setNumberOfLines:0];
    [self.view addSubview:_bodyLabel];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _titleLabel.frame = CGRectMake(10, 10, 300, 20);
    _subTitleLabel.frame = CGRectMake(10, 40, 300, 20);
    _bodyLabel.frame = CGRectMake(10, 60, 300, 50);
}
 
- (void)didReceiveNotification:(UNNotification *)notification {
    _titleLabel.text = notification.request.content.title;
    _subTitleLabel.text = notification.request.content.subtitle;
    _bodyLabel.text = notification.request.content.body;
    [_bodyLabel sizeToFit];
}

- (void)didReceiveNotificationResponse:(UNNotificationResponse *)response completionHandler:(void (^)(UNNotificationContentExtensionResponseOption))completion {
    //识别需要被处理的拓展
    if ([response.notification.request.content.categoryIdentifier isEqualToString:@"actiontest"]) {
        //识别用户点击的是哪个 action
        if ([response.actionIdentifier isEqualToString:@"reply"]) {
            
            //假设点击了输入内容的 UNTextInputNotificationAction 把 response 强转类型
            UNTextInputNotificationResponse *textResponse = (UNTextInputNotificationResponse*)response;
            //获取输入内容
            NSString *userText = textResponse.userText;
            NSLog(@"input text: %@", userText);
            _bodyLabel.text = userText;
        } else if ([response.actionIdentifier isEqualToString:@"ignore"]){
            [[UNUserNotificationCenter currentNotificationCenter] removeDeliveredNotificationsWithIdentifiers:@[response.notification.request.identifier]];
            NSLog(@"remove identifier: %@", response.notification.request.identifier);
        }
        
    }
}

@end
