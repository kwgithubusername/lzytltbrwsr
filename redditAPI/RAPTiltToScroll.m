//
//  RAPtiltToScroll.m
//  redditAPI
//
//  Created by Woudini on 2/3/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "RAPTiltToScroll.h"
#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

#define RAPCreateRectSelectorNotification @"RAPCreateRectSelectorNotification"
#define RAPRemoveRectSelectorNotification @"RAPRemoveRectSelectorNotification"
#define RAPSelectARowNotification @"RAPSelectARowNotification"
#define RAPTableViewShouldAdjustToNearestRowAtIndexPathNotification @"RAPTableViewShouldAdjustToNearestRowAtIndexPathNotification"

@interface RAPTiltToScroll ()
@property (nonatomic) CMMotionManager *motionManager;
@property (nonatomic) CGFloat lastContentOffset;
@property BOOL selectModeIsOn;
@property BOOL selectModeHasBeenSwitched;
@property BOOL scrollingSessionHasStarted;
@end

@implementation RAPTiltToScroll

-(void)postCreateRectSelectorNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RAPCreateRectSelectorNotification" object:self];
}

-(void)startTiltToScrollWithSensitivity:(float)sensitivity forScrollView:(UIScrollView *)scrollView
{
    NSLog(@"Contentoffset.y is %f", scrollView.contentOffset.y);
    [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical toQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *motion, NSError *error)
     {
         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
             
             CGFloat tiltAngleLeftOrRight = [self LeftOrRightAngleInDegreesUsingXGravity:motion.gravity.x YGravity:motion.gravity.y andZGravity:motion.gravity.z];
             CGFloat tiltAngleForwardorBackward = [self ForwardOrBackwardAngleInDegreesUsingXGravity:motion.gravity.x YGravity:motion.gravity.y andZGravity:motion.gravity.z];
             [self scrollTableViewWithIntensityOfAnglesLeftOrRight:tiltAngleLeftOrRight ForwardOrBackward:tiltAngleForwardorBackward inScrollView:(UIScrollView *)scrollView];
         }];
         
     }];
}


#pragma mark Scrolling

-(void)scrollTableViewWithIntensityOfAnglesLeftOrRight:(CGFloat)leftOrRightAngle ForwardOrBackward:(CGFloat)forwardOrBackwardAngle inScrollView:(UIScrollView *)scrollView
{
    if (leftOrRightAngle > 10 || leftOrRightAngle < -10)
    {
        //NSLog(@"Tilted %f degrees clockwise", leftOrRightAngle);
        if (scrollView.contentOffset.y + leftOrRightAngle/5 >= -64 && !self.selectModeIsOn)
        {
            CGPoint offsetCGPoint = CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + leftOrRightAngle/5);
            scrollView.contentOffset = offsetCGPoint;
            
            if (!self.scrollingSessionHasStarted)
            {
                // This should happen only ONCE per scrolling session- note when a scrollingsession began and when it ends
                [self.delegate addAdjustToNearestRowNotification];
                self.scrollingSessionHasStarted = YES;
            }

        }
        
        if (self.selectModeIsOn)
        {
            // Post this notification and immediately remove the observer, as we want this to happen only once
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RAPSelectARowNotification" object:self];
        }
        //NSLog(@"Contentoffset.y is %f", scrollView.contentOffset.y);
    }

    if (forwardOrBackwardAngle > 10)
    {
        if (!self.selectModeHasBeenSwitched)
        {
            BOOL change = !self.selectModeIsOn;
            self.selectModeIsOn = change;
            self.selectModeHasBeenSwitched = YES;
        }
        if (self.selectModeIsOn)
        {
            // Post this notification and immediately remove the observer, as we want this to happen only once
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RAPCreateRectSelectorNotification" object:self];
        }
        if (!self.selectModeIsOn)
        {
            // Post this notification and immediately remove the observer, as we want this to happen only once
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RAPRemoveRectSelectorNotification" object:self];
        }
        //NSLog(@"Tilted %f degrees forward", forwardOrBackwardAngle);
    }
    else if (forwardOrBackwardAngle < -10)
    {
        //NSLog(@"Tilted %f degrees backward", forwardOrBackwardAngle);
    }
    
    // if the offset is not a multiple of 44 -> the tableviewcell height
    // make it the closest multiple of 44 -> the tableviewcell height
    
    // Whatever the current contentoffset is
    // Find the closest multiple of 44 -> the tableviewcell height
    
    if (leftOrRightAngle < 10 && forwardOrBackwardAngle < 10)
    {
        // Prevent each millisecond of having device tilted turn select mode on/off repeatedly
        self.selectModeHasBeenSwitched = NO;
        self.scrollingSessionHasStarted = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RAPTableViewShouldAdjustToNearestRowAtIndexPathNotification" object:self];
    }
}

-(void)croll:(UIScrollView *)scrollView
{
    if (self.lastContentOffset > scrollView.contentOffset.y)
    {
        //        [self maintainFixedPositionOfScrollRectInDirectionDown:NO inScrollView:scrollView];
    }
    else if (self.lastContentOffset < scrollView.contentOffset.y)
    {
        //        [self maintainFixedPositionOfScrollRectInDirectionDown:YES inScrollView:scrollView];
    }
    self.lastContentOffset = scrollView.contentOffset.y;
    //NSLog(@"ScrollviewDidScroll contentOffSet is %f", scrollView.contentOffset.y);
}

#pragma mark Motion Manager

-(CMMotionManager *)motionManager
{
    if (!_motionManager)
    {
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.deviceMotionUpdateInterval = 5.0 / 60.0;
    }
    return _motionManager;
}

-(void)setupTiltToScrollTableView
{
    
}

-(CGFloat)LeftOrRightAngleInDegreesUsingXGravity:(CGFloat)xGravity YGravity:(CGFloat)yGravity andZGravity:(CGFloat)zGravity
{
    CGFloat angle = 0;
    
    switch ([[UIDevice currentDevice] orientation])
    {
        case UIDeviceOrientationLandscapeLeft:
        {
            angle = atan2(xGravity, -yGravity);
            break;
        }
        case UIDeviceOrientationLandscapeRight:
        {
            angle = atan2(-xGravity, yGravity);
            break;
        }
        case UIDeviceOrientationPortrait:
        {
            angle = atan2(yGravity, xGravity);
            break;
        }
        case UIDeviceOrientationPortraitUpsideDown:
        {
            angle = atan2(-yGravity, -xGravity);
            break;
        }
        case UIDeviceOrientationFaceUp:
        {
            break;
        }
        case UIDeviceOrientationFaceDown:
        {
            break;
        }
        case UIDeviceOrientationUnknown:
        {
            break;
        }
    }
    CGFloat angleToReturn = (angle + M_PI_2) * 180.0f / M_PI;
    return angleToReturn;
}

-(CGFloat)ForwardOrBackwardAngleInDegreesUsingXGravity:(CGFloat)xGravity YGravity:(CGFloat)yGravity andZGravity:(CGFloat)zGravity
{
    CGFloat angle = 0;
    switch ([[UIDevice currentDevice] orientation])
    {
        case UIDeviceOrientationLandscapeLeft:
        {
            angle = atan2(xGravity, zGravity);
            break;
        }
        case UIDeviceOrientationLandscapeRight:
        {
            angle = atan2(-xGravity, zGravity);
            break;
        }
        case UIDeviceOrientationPortrait:
        {
            angle = atan2(yGravity, zGravity);
            break;
        }
        case UIDeviceOrientationPortraitUpsideDown:
        {
            angle = atan2(-yGravity, zGravity);
        }
        case UIDeviceOrientationFaceUp:
        {
            break;
        }
        case UIDeviceOrientationFaceDown:
        {
            break;
        }
        case UIDeviceOrientationUnknown:
        {
            break;
        }
    }
    CGFloat angleToReturn = (angle + M_PI_2) * 180.0f / M_PI;
    return angleToReturn;
}




@end
