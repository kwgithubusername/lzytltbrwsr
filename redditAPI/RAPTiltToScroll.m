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

#define RAPSelectRowNotification @"RAPSelectRowNotification"
#define RAPCreateRectSelectorNotification @"RAPCreateRectSelectorNotification"
#define RAPTableViewShouldAdjustToNearestRowAtIndexPathNotification @"RAPTableViewShouldAdjustToNearestRowAtIndexPathNotification"
#define RAPRemoveRectSelectorNotification @"RAPRemoveRectSelectorNotification"
#define RAPSegueBackNotification @"RAPSegueBackNotification"
#define RAPCalibrateNotification @"RAPCalibrateNotification"

@interface RAPTiltToScroll ()
@property (nonatomic) CMMotionManager *motionManager;
@property (nonatomic) CGFloat lastContentOffset;
@property (nonatomic) BOOL selectModeIsOn;
@property (nonatomic) BOOL selectModeHasBeenSwitched;
@property (nonatomic) BOOL scrollingSessionHasStarted;
@property (nonatomic) float calibratedAngle;
@end

@implementation RAPTiltToScroll

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        self.calibratedAngle = [[[NSUserDefaults standardUserDefaults] objectForKey:@"calibratedAngle"] floatValue];
        NSLog(@"calibratedangle is %f", self.calibratedAngle);
    }
    return self;
}

-(void)setCalibratedAngle:(float)calibratedAngle
{
    if (calibratedAngle < -30)
    {
        _calibratedAngle = -30;
    }
    else
    {
        _calibratedAngle = calibratedAngle;
    }
}

-(void)postCreateRectSelectorNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:RAPCreateRectSelectorNotification object:self];
}

-(void)setScrollingSessionHasStarted:(BOOL)scrollingSessionHasStarted
{
    //NSLog(@"scrollingsessionstarted is being set to %d", scrollingSessionHasStarted);
    _scrollingSessionHasStarted = scrollingSessionHasStarted;
}
-(void)startTiltToScrollWithSensitivity:(float)sensitivity forScrollView:(UIScrollView *)scrollView inWebView:(BOOL)isInWebView
{
    //NSLog(@"Contentoffset.y is %f", scrollView.contentOffset.y);
    [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical toQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *motion, NSError *error)
     {
         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
             
             CGFloat tiltAngleLeftOrRight = [self LeftOrRightAngleInDegreesUsingXGravity:motion.gravity.x
                                                                                YGravity:motion.gravity.y
                                                                             andZGravity:motion.gravity.z];
             CGFloat tiltAngleForwardorBackward = [self ForwardOrBackwardAngleInDegreesUsingXGravity:motion.gravity.x
                                                                                            YGravity:motion.gravity.y
                                                                                         andZGravity:motion.gravity.z];
             NSLog(@"forwardorbackward is %f", tiltAngleForwardorBackward);
             
             if (self.isCalibrating)
             {
                 //remove rects
                 //turn selectmode off
                 self.selectModeIsOn = NO;
                 self.selectModeHasBeenSwitched = NO;
                 self.scrollingSessionHasStarted = NO;
                 [[NSNotificationCenter defaultCenter] postNotificationName:RAPRemoveRectSelectorNotification object:self];
                 
                 if (self.hasCalibrated)
                 {
                     self.calibratedAngle = tiltAngleForwardorBackward;
                     [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:self.calibratedAngle] forKey:@"calibratedAngle"];
                     NSLog(@"calibratedangle is %f", self.calibratedAngle);
                     self.isCalibrating = NO;
                     self.hasCalibrated = NO;
                 }
             }
             
             if (!self.isCalibrating && tiltAngleLeftOrRight != 90.0 && tiltAngleForwardorBackward != 90.0)
             {
                 [self scrollTableViewWithIntensityOfAnglesLeftOrRight:tiltAngleLeftOrRight
                                                     ForwardOrBackward:tiltAngleForwardorBackward
                                                          inScrollView:(UIScrollView *)scrollView
                                                             inWebView:isInWebView];
             }
         }];
         
     }];
}

-(void)stopTiltToScroll
{
    [self.motionManager stopDeviceMotionUpdates];
}

#pragma mark Scrolling

-(BOOL)floatIsPositive:(CGFloat)number
{
    return number >= 0 ? YES : NO;
}

-(BOOL)angleIsForward:(CGFloat)angle
{
    NSLog(@"calibratedangle is %f", self.calibratedAngle);
    return angle > (20 + self.calibratedAngle) ? YES : NO;
}

-(void)scrollTableViewWithIntensityOfAnglesLeftOrRight:(CGFloat)leftOrRightAngle ForwardOrBackward:(CGFloat)forwardOrBackwardAngle inScrollView:(UIScrollView *)scrollView inWebView:(BOOL)isInWebView
{
    if (leftOrRightAngle > 10 || leftOrRightAngle < -10)
    {
        //NSLog(@"Tilted %f degrees clockwise", leftOrRightAngle);
        if (!isInWebView)
        {
            if (scrollView.contentOffset.y + leftOrRightAngle/5 >= -64 && !self.selectModeIsOn)
            {
                CGPoint offsetCGPoint = CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + leftOrRightAngle/5);
                scrollView.contentOffset = offsetCGPoint;
                //NSLog(@"Contentoffset.y is %f", scrollView.contentOffset.y);
                if (!self.scrollingSessionHasStarted)
                {
                    // This should happen only ONCE per scrolling session- note when a scrollingsession began and when it ends
                    [self.delegate addObserverForAdjustToNearestRowNotification];
                    NSLog(@"delegate called");
                    self.scrollingSessionHasStarted = YES;
                }
                
            }
        }
        else if (isInWebView)
        {
            if (scrollView.frame.size.height > scrollView.contentOffset.y + leftOrRightAngle/5 >= -64 && !self.selectModeIsOn)
            {
                CGPoint offsetCGPoint = CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + leftOrRightAngle/5);
                scrollView.contentOffset = offsetCGPoint;
                //NSLog(@"Contentoffset.y is %f", scrollView.contentOffset.y);
                if (!self.scrollingSessionHasStarted)
                {
                    self.scrollingSessionHasStarted = YES;
                }
            }
        }
        
        if (self.selectModeIsOn)
        {
            if (leftOrRightAngle > 10)
            {
                // Post this notification and immediately remove the observer, as we want this to happen only once
                [[NSNotificationCenter defaultCenter] postNotificationName:RAPSelectRowNotification object:self];
                self.selectModeIsOn = NO;
            }
            else if (leftOrRightAngle < -10)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:RAPSegueBackNotification object:self];
                self.selectModeIsOn = NO;
            }
            
        }
        //NSLog(@"Contentoffset.y is %f", scrollView.contentOffset.y);
    }
    if (forwardOrBackwardAngle > 20 + self.calibratedAngle || forwardOrBackwardAngle < -20 + self.calibratedAngle)
    {
        //NSLog(@"Tilted %f degrees", forwardOrBackwardAngle);
        if (!self.selectModeHasBeenSwitched) // selectModeHasBeenSwitched is needed to differentiate between neutral state and selecting state. selectModeIsOn is used to toggle between creating the rect selector and removing it.
        {
            BOOL change = !self.selectModeIsOn;
            self.selectModeIsOn = change;
            self.selectModeHasBeenSwitched = YES;
        }
        if (self.selectModeIsOn)
        {
            //NSDictionary *dictionaryWithBools = @{[NSNumber numberWithBool:[self floatIsPositive:forwardOrBackwardAngle]]:@"atTop",[NSNumber numberWithBool:isInWebView]:@"inWebView"};
            // Post this notification and immediately remove the observer, as we want this to happen only once
            [[NSNotificationCenter defaultCenter] postNotificationName:RAPCreateRectSelectorNotification object:self userInfo:[NSDictionary dictionaryWithObjects:@[[NSNumber numberWithBool:[self angleIsForward:forwardOrBackwardAngle]], [NSNumber numberWithBool:isInWebView]] forKeys:@[@"atTop",@"inWebView"]]];
            //NSLog(@"Attop is %d", [self floatIsPositive:forwardOrBackwardAngle]);
            //NSLog(@"Tilted %f degrees forward", forwardOrBackwardAngle);
        }
        if (!self.selectModeIsOn)
        {
            // Post this notification and immediately remove the observer, as we want this to happen only once
            [[NSNotificationCenter defaultCenter] postNotificationName:RAPRemoveRectSelectorNotification object:self];
        }
        
    }
    
    if (forwardOrBackwardAngle < 20 + self.calibratedAngle && forwardOrBackwardAngle > -20 + self.calibratedAngle && leftOrRightAngle < 10 && leftOrRightAngle > -10)
        {
            // Prevent each millisecond of having device tilted turn select mode on/off repeatedly
            self.selectModeHasBeenSwitched = NO;
            self.scrollingSessionHasStarted = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:RAPTableViewShouldAdjustToNearestRowAtIndexPathNotification object:self];
        }

}

-(void)segueSuccessful
{
    // If segue succeeds, turn off selectMode. If it was unsuccessful, leave selectMode on
    self.selectModeIsOn = NO;
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
