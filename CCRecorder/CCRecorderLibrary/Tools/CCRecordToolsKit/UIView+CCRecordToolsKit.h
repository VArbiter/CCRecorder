//
//  UIView+CCRecordToolsKit.h
//  CCRecorder
//
//  Created by 冯明庆 on 16/7/22.
//  Copyright © 2016年 冯明庆. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CCRecordToolsKit)

/**
 * Shortcut for frame.size.witdth*0.5
 */
@property (nonatomic,readonly) CGFloat inCenterX;
/**
 * Shortcut for frame.size.height*0.5
 */
@property (nonatomic,readonly) CGFloat inCenterY;

/**
 * Shortcut for CGPointMake(self.inCenterX,self.inCenterY)
 */
@property (nonatomic,readonly) CGPoint inCenter;
/**
 * Shortcut for frame.origin.x.
 *
 * Sets frame.origin.x = left
 */
@property (nonatomic) CGFloat left;

/**
 * Shortcut for frame.origin.y
 *
 * Sets frame.origin.y = top
 */
@property (nonatomic) CGFloat top;

/**
 * Shortcut for frame.origin.x + frame.size.width
 *
 * Sets frame.origin.x = right - frame.size.width
 */
@property (nonatomic) CGFloat right;

/**
 * Shortcut for frame.origin.y + frame.size.height
 *
 * Sets frame.origin.y = bottom - frame.size.height
 */
@property (nonatomic) CGFloat bottom;

/**
 * Shortcut for frame.size.width
 *
 * Sets frame.size.width = width
 */
@property (nonatomic) CGFloat width;

/**
 * Shortcut for frame.size.height
 *
 * Sets frame.size.height = height
 */
@property (nonatomic) CGFloat height;

/**
 * Shortcut for bounds.size.width
 *
 * Sets bounds.size.width = width
 */
@property (nonatomic,readonly) CGFloat b_width;
@property (nonatomic, assign) CGFloat b_x;
@property (nonatomic, assign) CGFloat b_y;

#pragma mark - EDIT BY MINGQING
@property (nonatomic , assign) CGFloat x;
@property (nonatomic , assign) CGFloat y;
@property (nonatomic , assign , readonly) CGFloat f_x;
@property (nonatomic , assign , readonly) CGFloat f_y;

/**
 * Shortcut for bounds.size.height
 *
 * Sets bounds.size.height = height
 */
@property (nonatomic,readonly) CGFloat b_height;
/**
 * Shortcut for center.x
 *
 * Sets center.x = centerX
 */
@property (nonatomic) CGFloat centerX;

/**
 * Shortcut for center.y
 *
 * Sets center.y = centerY
 */
@property (nonatomic) CGFloat centerY;

/**
 * Return the x coordinate on the screen.
 */
@property (nonatomic, readonly) CGFloat ttScreenX;

/**
 * Return the y coordinate on the screen.
 */
@property (nonatomic, readonly) CGFloat ttScreenY;

/**
 * Return the x coordinate on the screen, taking into account scroll views.
 */
@property (nonatomic, readonly) CGFloat screenViewX;

/**
 * Return the y coordinate on the screen, taking into account scroll views.
 */
@property (nonatomic, readonly) CGFloat screenViewY;

/**
 * Return the view frame on the screen, taking into account scroll views.
 */
@property (nonatomic, readonly) CGRect screenFrame;

/**
 * Shortcut for frame.origin
 */
@property (nonatomic) CGPoint origin;

/**
 * Shortcut for frame.size
 */
@property (nonatomic) CGSize size;

/**
 * Return the width in portrait or the height in landscape.
 */
@property (nonatomic, readonly) CGFloat orientationWidth;

/**
 * Return the height in portrait or the width in landscape.
 */
@property (nonatomic, readonly) CGFloat orientationHeight;

/**
 * Removes all subviews.
 */
- (void)ccRemoveAllSubviews;
/**
 * Calculates the offset of this view from another view in screen coordinates.
 *
 * otherView should be a parent view of this view.
 */
- (CGPoint)ccOffsetFromView:(UIView*)otherView;

- (UIView *)ccDescendantOrSelfWithClass:(Class)cls;
- (UIView *)ccAncestorOrSelfWithClass:(Class)cls;
- (void)ccSetBorderColor:(UIColor *)borderColor width:(CGFloat)borderWidth;
/**
 * Get the UIViewController for the view.
 *
 */
- (UIViewController*)ccViewController;
- (void)ccAddTargetForTouch:(id)target action:(SEL)action;

-(UIImage *)ccCaptureWithSelfContent:(BOOL)bWithSelf;  // 抓图：当前view的图或者被其所遮挡的部分的图；
-(UIImage *)ccCaptureSelf; // 抓取当前view的截图;


- (UIImage*)ccScreenshotWithOptimization:(BOOL)optimized;
- (UIImage*)ccScreenshot;

@end
