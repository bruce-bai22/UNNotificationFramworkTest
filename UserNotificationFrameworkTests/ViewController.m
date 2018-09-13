//
//  ViewController.m
//  UserNotificationFrameworkTests
//
//  Created by Baitianyu on 2018/9/10.
//  Copyright © 2018 Baitianyu. All rights reserved.
//

#import "ViewController.h"
#import <UserNotifications/UserNotifications.h>

@interface ViewController ()

@property (nonatomic, strong) UIButton *button;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _button = [[UIButton alloc] initWithFrame:CGRectMake(100, 200, 100, 50)];
    _button.titleLabel.font = [UIFont systemFontOfSize:15];
    [_button setTitle:@"刷新本地通知" forState:UIControlStateNormal];
    [_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(refreshLocalNotification) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
}

- (void)refreshLocalNotification {
    UNMutableNotificationContent *content1 = [[UNMutableNotificationContent alloc] init];
    content1.subtitle = @"WWDC2016 Session 707";
    content1.body = @"Hi, this is a powerful notification framework for iOS10 and later";
    content1.title = @"Refreshed Introduction to User Notification Framework";
    content1.badge = @2;
    UNTimeIntervalNotificationTrigger *trigger5 = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:10 repeats:NO];
    NSString *requestIdentifier = @"TimeIntervalRequest";
    UNNotificationRequest *request1 = [UNNotificationRequest requestWithIdentifier:requestIdentifier
                                                                           content:content1
                                                                           trigger:trigger5];
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request1 withCompletionHandler:^(NSError * _Nullable error) {
        
    }];
}

@end
