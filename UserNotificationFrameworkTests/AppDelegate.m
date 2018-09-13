//
//  AppDelegate.m
//  UserNotificationFrameworkTests
//
//  Created by Baitianyu on 2018/9/10.
//  Copyright © 2018 Baitianyu. All rights reserved.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate () <UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptions)(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            NSLog(@"granted: %d", granted);
            [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                NSLog(@"%@", settings);
            }];
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Test local basic notification
                    [self testLocalNotification];
                    
                    [application registerForRemoteNotifications];
                });
                NSLog(@"request authorization success");
            } else {
                NSLog(@"request authorization failed");
            }
            
        }];
        
        // Test action
        UNNotificationAction *action = [UNNotificationAction actionWithIdentifier:@"ignore" title:@"Ignore" options:UNNotificationActionOptionDestructive];
        UNTextInputNotificationAction *textAction = [UNTextInputNotificationAction actionWithIdentifier:@"reply" title:@"Reply" options:UNNotificationActionOptionNone];
        
        if (@available(iOS 11.0, *)) {
            UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:@"actiontest" actions:@[action, textAction] intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction | UNNotificationCategoryOptionHiddenPreviewsShowTitle];
            [center setNotificationCategories:[NSSet setWithArray:@[category]]];
        } else {
            // Fallback on earlier versions
        }
        
    }
    return YES;
}

- (void)testLocalNotification {
    if (@available(iOS 10.0, *)) {
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = @"Introduction to User Notification Framework";
        content.subtitle = @"WWDC2016 Session 707";
        content.body = @"Hi, this is a powerful notification framework for iOS10 and later";
        content.badge = @3;
        
        // 10 秒后提醒，如果将 repeats 设为 YES，那就是每 10 秒提醒一次
        UNTimeIntervalNotificationTrigger *trigger1 = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:10 repeats:NO];
        
        // 每周一早8点通知
        //    NSDateComponents *components = [[NSDateComponents alloc] init];
        //    components.weekday = 2;
        //    components.hour = 8;
        //    UNCalendarNotificationTrigger *trigger2 = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:YES];
        
        // 到某位置提醒，这个需要参考 CoreLocation 文档，这里不再赘述
        //    CLRegion *region = [[CLRegion alloc] init];
        // 此处省略设置 CLRegion 的代码
        //    UNLocationNotificationTrigger *trigger3 = [UNLocationNotificationTrigger triggerWithRegion:region repeats:NO];
        
        NSString *requestIdentifier = @"TimeIntervalRequest";
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifier
                                                                              content:content
                                                                              trigger:trigger1];
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            
        }];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    //获得 device token
    //NSLog(@"deviceToken: %@", deviceToken);
    NSString *token = [[[deviceToken description]
                        stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]
                       stringByReplacingOccurrencesOfString:@" "
                       withString:@""];
    NSLog(@"~~~ deviceToken string, %@", token);
     [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
 }

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error) {
        NSLog(@"%@", error);
    }
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    NSLog(@"%@", userInfo);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler NS_AVAILABLE_IOS(10.0) {
    completionHandler(UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
    [center removeAllPendingNotificationRequests];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler NS_AVAILABLE_IOS(10.0) {
    //识别需要被处理的拓展
    if ([response.notification.request.content.categoryIdentifier isEqualToString:@"actiontest"]) {
        //识别用户点击的是哪个 action
        if ([response.actionIdentifier isEqualToString:@"reply"]) {

            //假设点击了输入内容的 UNTextInputNotificationAction 把 response 强转类型
            UNTextInputNotificationResponse *textResponse = (UNTextInputNotificationResponse*)response;
            //获取输入内容
            NSString *userText = textResponse.userText;
            NSLog(@"%@", userText);
        }else{

        }

    }
    NSLog(@"%@", response);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"%@", userInfo);
    completionHandler(UIBackgroundFetchResultNoData);
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
