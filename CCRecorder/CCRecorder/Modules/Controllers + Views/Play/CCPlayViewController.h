//
//  PlayViewController.h
//  SBVideoCaptureDemo
//
//  Created by Pandara on 14-8-18.
//  Copyright (c) 2014年 Pandara. All rights reserved.
//

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import <UIKit/UIKit.h>

@interface CCPlayViewController : UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withVideoFileURL:(NSURL *)videoFileURL;

- (id) initWithVideoFileURL:(NSURL *)videoFileURL;

@end
