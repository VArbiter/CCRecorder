//
//  UIView+CCRecordToolsKit.m
//  CCRecorder
//
//  Created by 冯明庆 on 16/7/22.
//  Copyright © 2016年 冯明庆. All rights reserved.
//

#import "UIView+CCRecordToolsKit.h"

@interface UIView ()

@end

@implementation UIView (CCRecordToolsKit)

-(CGFloat)inCenterX{
    return self.frame.size.width*0.5;
}

-(CGFloat)inCenterY{
    return self.frame.size.height*0.5;
}

-(CGPoint)inCenter{
    return CGPointMake(self.inCenterX, self.inCenterY);
}

- (CGFloat)left {
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)centerX {
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)centerY {
    return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)b_width{
    return self.bounds.size.width;
}

- (CGFloat)b_height{
    return self.bounds.size.height;
}
- (CGFloat)b_x{
    return self.bounds.origin.x;
}
- (CGFloat)b_y{
    return self.bounds.origin.y;
}
- (void)setB_x:(CGFloat)b_x{
    self.bounds = CGRectMake(b_x, self.b_y, self.b_width, self.b_height);
}
- (void)setB_y:(CGFloat)b_y{
    self.bounds = CGRectMake(self.b_x, b_y, self.b_width, self.b_height);
}

#pragma mark - EDIT BY MINGQING
- (CGFloat)f_x{
    return self.frame.origin.x;
}
- (CGFloat)f_y{
    return self.frame.origin.y;
}
- (CGFloat)x{
    return self.frame.origin.x;
}
- (CGFloat)y{
    return self.frame.origin.y;
}
- (void)setX:(CGFloat)x{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}
- (void)setY:(CGFloat)y{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)ttScreenX {
    CGFloat x = 0;
    for (UIView* view = self; view; view = view.superview) {
        x += view.left;
    }
    return x;
}

- (CGFloat)ttScreenY {
    CGFloat y = 0;
    for (UIView* view = self; view; view = view.superview) {
        y += view.top;
    }
    return y;
}

- (CGFloat)screenViewX {
    CGFloat x = 0;
    for (UIView* view = self; view; view = view.superview) {
        x += view.left;
        
        if (view!=self && [view isKindOfClass:[UIScrollView class]]) {
            UIScrollView* scrollView = (UIScrollView*)view;
            x -= scrollView.contentOffset.x;
        }
        if (![view isKindOfClass:[UIScrollView class]]) {
            x -= view.b_x;
        }
    }
    
    return x;
}

- (CGFloat)screenViewY {
    CGFloat y = 0;
    for (UIView* view = self; view; view = view.superview) {
        y += view.top;
        
        if (view!=self && [view isKindOfClass:[UIScrollView class]]) {
            UIScrollView* scrollView = (UIScrollView*)view;
            y -= scrollView.contentOffset.y;
        }
        if (![view isKindOfClass:[UIScrollView class]]) {
            y -= view.b_y;
        }
    }
    return y;
}

- (CGRect)screenFrame {
    return CGRectMake(self.screenViewX, self.screenViewY, self.width, self.height);
}

- (CGPoint)origin {
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGFloat)orientationWidth {
    return UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)
    ? self.height : self.width;
}

- (CGFloat)orientationHeight {
    return UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)
    ? self.width : self.height;
}

- (void)ccRemoveAllSubviews {
    while (self.subviews.count) {
        UIView* child = self.subviews.lastObject;
        [child removeFromSuperview];
    }
}

- (CGPoint)ccOffsetFromView:(UIView*)otherView {
    CGFloat x = 0, y = 0;
    for (UIView* view = self; view && view != otherView; view = view.superview) {
        x += view.left;
        y += view.top;
    }
    return CGPointMake(x, y);
}

- (UIView*)ccDescendantOrSelfWithClass:(Class)cls {
    if ([self isKindOfClass:cls])
        return self;
    
    for (UIView* child in self.subviews) {
        UIView* it = [child ccDescendantOrSelfWithClass:cls];
        if (it)
            return it;
    }
    
    return nil;
}

- (UIView*)ccAncestorOrSelfWithClass:(Class)cls {
    if ([self isKindOfClass:cls]) {
        return self;
        
    } else if (self.superview) {
        return [self.superview ccAncestorOrSelfWithClass:cls];
        
    } else {
        return nil;
    }
}

- (void)ccSetBorderColor:(UIColor *)borderColor width:(CGFloat)borderWidth
{
    self.layer.borderColor = borderColor.CGColor;
    self.layer.borderWidth = borderWidth;
}

- (UIViewController*)ccViewController {
    for (UIView* next = self; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}
- (void)ccAddTargetForTouch:(id)target action:(SEL)action
{
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]
                                         initWithTarget:target action:action];
    [self addGestureRecognizer:singleTap];
    
}

-(UIImage *)ccCaptureWithSelfContent:(BOOL)bWithSelf
{
    // Create the image context
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, self.window.screen.scale);
    
    // Get the snapshot
    UIImage *snapshotImage = nil;
    
#ifdef __IPHONE_7_0
    NSString *systemVersion = [UIDevice currentDevice].systemVersion;
    if ([systemVersion rangeOfString:@"7"].length > 0 && !bWithSelf) {
        // 系统版本号包含 7
        // There he is! The new API method
        [self drawViewHierarchyInRect:self.frame afterScreenUpdates:NO];
        // Get the snapshot
        snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    }else{
#endif
        UIView *view = [[self.window subviews] objectAtIndex:0];
        self.hidden = !bWithSelf;
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        //        CGContextTranslateCTM(context, 0, view.bounds.size.height);
        //        CGContextScaleCTM (context, 1, -1);
        CGContextClipToRect(context, [self convertRect:self.bounds toView:view]);
        [view.layer renderInContext:context];
        
        snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
        self.hidden = NO;
#ifdef __IPHONE_7_0
    }
#endif
    
    // Be nice and clean your mess up
    UIGraphicsEndImageContext();
    
    return snapshotImage;
}

-(UIImage *)ccCaptureSelf
{
    // Create the image context
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, self.window.screen.scale);
    
    // Get the snapshot
    UIImage *snapshotImage = nil;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    //    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    //    CGContextScaleCTM (context, 1, -1);
    [self.layer renderInContext:context];
    
    snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Be nice and clean your mess up
    UIGraphicsEndImageContext();
    
    return snapshotImage;
}

- (UIImage*)ccScreenshotWithOptimization:(BOOL)optimized
{
    if (optimized)
    {
        // take screenshot of the view
        if ([self isKindOfClass:NSClassFromString(@"MKMapView")])
        {
            if ([[[UIDevice currentDevice] systemVersion] floatValue]>=6.0)
            {
                // in iOS6, there is no problem using a non-retina screenshot in a retina display screen
                UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 1.0);
            }
            else
            {
                // if the view is a mapview in iOS5.0 and below, screenshot has to take the screen scale into consideration
                // else, the screen shot in retina display devices will be of a less detail map (note, it is not the size of the screenshot, but it is the level of detail of the screenshot
                UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0);
            }
        }
        else
        {
            // for performance consideration, everything else other than mapview will use a lower quality screenshot
            UIGraphicsBeginImageContext(self.frame.size);
        }
    }
    else
    {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0);
    }
    
    
    
    if (UIGraphicsGetCurrentContext()==nil)
    {
        NSLog(@"UIGraphicsGetCurrentContext() is nil. You may have a UIView with CGRectZero");
        return nil;
    }
    else
    {
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        
        UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//        NSString *documentsDirectory = [paths objectAtIndex:0];
//        NSString *testScreenshot = [documentsDirectory stringByAppendingPathComponent:@"test.png"];
//        NSData *imageData = UIImagePNGRepresentation(screenshot);
//        [imageData writeToFile:testScreenshot atomically:YES];
        
        return screenshot;
    }
    
}

- (UIImage*)ccScreenshot
{
    return [self ccScreenshotWithOptimization:YES];
}

@end
