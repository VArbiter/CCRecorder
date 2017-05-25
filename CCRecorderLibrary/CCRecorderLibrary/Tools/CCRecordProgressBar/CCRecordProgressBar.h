//
//  CCRecordProgressBar.h
//  CCRecorder
//
//  Created by 冯明庆 on 16/7/4.
//  Copyright © 2016年 冯明庆. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger , CCProgressType) {
    /// 普通样式
    CCProgressTypeNormal = 0,
    /// 将要删除时候的样式
    CCProgressTypeDelete
};

@interface CCRecordProgressBar : UIView

+ (instancetype) initializeWithDefaulyType;

- (void) ccSetLastProgressToStyle:(CCProgressType)style;
- (void) ccSetLastProgressToWidth:(CGFloat)width;

- (void) ccDeleteLastProgress;
- (void) ccAddProgressView;

- (void) ccStopShining;
- (void) ccStartShining;

- (void) ccDeleteAllProgress ;


@end
