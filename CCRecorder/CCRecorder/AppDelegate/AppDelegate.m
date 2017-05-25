//
//  AppDelegate.m
//  CCRecorder
//
//  Created by 冯明庆 on 16/7/21.
//  Copyright © 2016年 冯明庆. All rights reserved.
//

#import "AppDelegate.h"
#import "CCCommonDefine.h"
#import "CCRecordViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    CCRecordViewController *controller = [[CCRecordViewController alloc] initWithNibName:@"CCRecordViewController"
                                                                                  bundle:_ccBundle()];
    _window.rootViewController = controller;
    _window.backgroundColor = [UIColor whiteColor];
    [_window makeKeyAndVisible];
    return YES;
}

@end
