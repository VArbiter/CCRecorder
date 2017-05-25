//
//  CCRecordProgressBar.m
//  CCRecorder
//
//  Created by 冯明庆 on 16/7/4.
//  Copyright © 2016年 冯明庆. All rights reserved.
//

#import "CCRecordProgressBar.h"
#import "CCCommonDefine.h"

@interface CCRecordProgressBar ()

CGFloat _ccBarHeight();
CGFloat _ccBarMargin();
CGFloat _ccBarMinWidth();
CGFloat _ccIndicatorWidth();
CGFloat _ccIndicatorHeight();
CGFloat _ccTimerInterval();

UIColor *_ccBarRedColor();
UIColor *_ccBarBlueColor();
UIColor *_ccBarBackgroundColor();
UIColor *_ccBackgroundColor();

@property (nonatomic , strong) NSMutableArray *arrayProgressView;
@property (nonatomic , strong) UIView *viewBar;
@property (nonatomic , strong) UIImageView *imageViewIndicatorProgress;
@property (nonatomic , strong) NSTimer *timerShining;

/// 初始化设置
- (void) ccDefaultSettings ;

/// 添加新的 progressView
- (UIView *) ccGetProgressView ;

/// 得到显示的最后一个位置
- (void) ccGetIndicatorPosition ;

/// 开始闪烁
- (void) ccSetTimer : (NSTimer *) timer;

@end

@implementation CCRecordProgressBar

+ (instancetype) initializeWithDefaulyType{
    return [[CCRecordProgressBar alloc] initWithFrame:CGRectMake(0, 0, _ccScreenWidth(), _ccBarHeight() + _ccBarMargin() * 2)];
}

- (void) ccSetLastProgressToStyle:(CCProgressType)style{
    UIView *viewLastProgressView = [_arrayProgressView lastObject];
    if (!viewLastProgressView) {
        return;
    }
    
    switch (style) {
        case CCProgressTypeDelete:{
            viewLastProgressView.backgroundColor = _ccBarRedColor();
            _imageViewIndicatorProgress.hidden = YES;
        }break;
        case CCProgressTypeNormal:{
            viewLastProgressView.backgroundColor = _ccBarBlueColor();
            _imageViewIndicatorProgress.hidden = NO;
        }break;
            
        default:
            break;
    }

}
- (void) ccSetLastProgressToWidth:(CGFloat)width{
    UIView *viewLastProgressView = [_arrayProgressView lastObject];
    if (!viewLastProgressView) {
        return;
    }
    viewLastProgressView.width = width;
    [self ccGetIndicatorPosition];
}

- (void) ccDeleteLastProgress{
    UIView *viewLastProgressView = [_arrayProgressView lastObject];
    if (!viewLastProgressView) {
        return;
    }
    
    [viewLastProgressView removeFromSuperview];
    [_arrayProgressView removeLastObject];
    
    _imageViewIndicatorProgress.hidden = NO;
    
    [self ccGetIndicatorPosition];
}
- (void) ccAddProgressView{
    UIView *viewLastProgressView = [_arrayProgressView lastObject];
    CGFloat newProgressX = 0.0f;
    
    if (viewLastProgressView) {
        CGRect frame = viewLastProgressView.frame;
        frame.size.width -= 1;
        viewLastProgressView.frame = frame;
        
        newProgressX = frame.origin.x + frame.size.width + 1;
    }
    
    UIView *viewNewProgressView = [self ccGetProgressView];
    viewNewProgressView.x = newProgressX;
    
    [_viewBar addSubview:viewNewProgressView];
    
    [_arrayProgressView addObject:viewNewProgressView];
}

- (void) ccStopShining{
    [_timerShining invalidate];
    _timerShining = nil;
    _imageViewIndicatorProgress.alpha = 1.0f;
}
- (void) ccStartShining{
    [NSTimer timerWithTimeInterval:_ccTimerInterval() target:self selector:@selector(ccSetTimer:) userInfo:nil repeats:YES];
}

- (void) ccDeleteAllProgress {
    NSInteger integerArrayCount = _arrayProgressView.count;
    for (NSInteger i = 0; i < integerArrayCount; i++) {
        [self ccDeleteLastProgress];
    }
}

#pragma mark - Private Method (s)
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self ccDefaultSettings];
    }
    return self;
}

CGFloat _ccBarHeight(){
//    return 22.0f;
    return 4.0f;
}
CGFloat _ccBarMargin(){
    return 2.0f;
}
CGFloat _ccBarMinWidth(){
//    return 80.0f;
    CGFloat floatMinWidth = 0.0f;
    floatMinWidth = _ccScreenWidth() * (_ccMinDuration() / _ccMaxDuration());
    return floatMinWidth;
}
CGFloat _ccIndicatorWidth(){
    return 0.0f;
}
CGFloat _ccIndicatorHeight(){
//    return 22.0f;
    return 4.0f;
}
CGFloat _ccTimerInterval(){
    return 1.0f;
}

UIColor *_ccBarRedColor(){
//    return _ccColor(224, 66, 39, 1);
    return _ccHexColor(0xFF1B5B, 1.0f);
}
UIColor *_ccBarBlueColor(){
//    return _ccColor(68, 214, 254, 1);
    return _ccHexColor(0x6D4BD0, 1.0f);
}
UIColor *_ccBarBackgroundColor(){
//    return _ccColor(38, 38, 38, 1);
    return [UIColor clearColor];
}
UIColor *_ccBackgroundColor(){
//    return _ccColor(11, 11, 11, 1);
    return [UIColor clearColor];
}

- (void) ccDefaultSettings {
    self.autoresizingMask = UIViewAutoresizingNone;
    self.backgroundColor = _ccBackgroundColor();
    _arrayProgressView = [NSMutableArray array];
    
    /// 设置 BarView , 背景色
//    _viewBar = [[UIView alloc] initWithFrame:CGRectMake(0, _ccBarMargin(), self.frame.size.width, _ccBarHeight())];
    _viewBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, _ccBarHeight())];
    _viewBar.backgroundColor = _ccBarBackgroundColor();
    [self addSubview:_viewBar];
    
    /// 设置 分割线 , 显示最短时间的地方
    UIView *viewIndicator = [[UIView alloc] initWithFrame:CGRectMake(_ccBarMinWidth(), 0, 1, _ccBarHeight())];
    viewIndicator.backgroundColor = [UIColor whiteColor];
    [self addSubview:viewIndicator];
    
    /// 设置显示进度的部分
    _imageViewIndicatorProgress = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _ccIndicatorWidth(), _ccIndicatorHeight())];
    _imageViewIndicatorProgress.backgroundColor = [UIColor clearColor];
    _imageViewIndicatorProgress.image = [UIImage imageNamed:@"Icon_Record_Front"];
    _imageViewIndicatorProgress.center = CGPointMake(0, self.frame.size.height / 2);
    [self addSubview:_imageViewIndicatorProgress];
}

- (UIView *) ccGetProgressView {
    UIView *viewProgressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, _ccBarHeight())];
    viewProgressView.backgroundColor = _ccBarBlueColor();
    viewProgressView.autoresizesSubviews = YES;
    return viewProgressView;
}

- (void) ccGetIndicatorPosition {
    UIView *viewLastProgressView = [_arrayProgressView lastObject];
    if (!viewLastProgressView) {
        _imageViewIndicatorProgress.center = CGPointMake(0, self.frame.size.height / 2);
        return;
    }
    _imageViewIndicatorProgress.center = CGPointMake(MIN(viewLastProgressView.frame.origin.x + viewLastProgressView.frame.size.width, self.frame.size.width - _imageViewIndicatorProgress.frame.size.width / 2 + 2), self.frame.size.height / 2);
}

- (void) ccSetTimer : (NSTimer *) timer{
    [UIView animateWithDuration:_ccTimerInterval() animations:^{
        _imageViewIndicatorProgress.alpha = 0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:_ccTimerInterval() animations:^{
            _imageViewIndicatorProgress.alpha = 1;
        }];
    }];
}
@end
