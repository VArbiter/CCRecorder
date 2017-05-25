//
//  PlayViewController.h
//  SBVideoCaptureDemo
//
//  Created by Pandara on 14-8-18.
//  Copyright (c) 2014年 Pandara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCPlayViewController : UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withVideoFileURL:(NSURL *)videoFileURL;

- (id) initWithVideoFileURL:(NSURL *)videoFileURL;

@end
