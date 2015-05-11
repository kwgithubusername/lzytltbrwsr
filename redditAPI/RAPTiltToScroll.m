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

const CGFloat FORWARD_BACKWARD_TILT_ANGLE_LIMIT = 20;
const CGFloat CALIBRATED_ANGLE_LIMIT = 30;
const CGFloat LEFT_RIGHT_TILT_ANGLE_LIMIT = 10;
const CGFloat CONTENTOFFSET_LIMIT = -64;

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
        // NSLog(@"calibratedangle is %f", self.calibratedAngle);
    }
    return self;
}

-(void)setCalibratedAngle:(float)calibratedAngle
{
    if (calibratedAngle < -CALIBRATED_ANGLE_LIMIT)
    {
        _calibratedAngle = -CALIBRATED_ANGLE_LIMIT;
    }
    else if (calibratedAngle > CALIBRATED_ANGLE_LIMIT)
    {
        _calibratedAngle = CALIBRATED_ANGLE_LIMIT;
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
    self.selectModeIsOn = NO;
    
    self.hasStarted = YES;
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
             // NSLog(@"forwardorbackward is %f", tiltAngleForwardorBackward);
             
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
                     // NSLog(@"calibratedangle is %f", self.calibratedAngle);
                     self.isCalibrating = NO;
                     self.hasCalibrated = NO;
                 }
             }
             
             // Invalid angles
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
    self.selectModeIsOn = NO;
    self.selectModeHasBeenSwitched = NO;
    self.scrollingSessionHasStarted = NO;
    self.hasStarted = NO;
}

#pragma mark Scrolling

-(BOOL)floatIsPositive:(CGFloat)number
{
    return number >= 0 ? YES : NO;
}

-(BOOL)angleIsForward:(CGFloat)angle
{
    //NSLog(@"calibratedangle is %f", self.calibratedAngle);
    return angle > (FORWARD_BACKWARD_TILT_ANGLE_LIMIT + self.calibratedAngle) ? YES : NO;
}

-(void)scrollTableViewWithIntensityOfAnglesLeftOrRight:(CGFloat)leftOrRightAngle ForwardOrBackward:(CGFloat)forwardOrBackwardAngle inScrollView:(UIScrollView *)scrollView inWebView:(BOOL)isInWebView
{
    if (forwardOrBackwardAngle < -80 || forwardOrBackwardAngle > 200)
    {
        // invalid angles!
        return;
    }
    
    if ((forwardOrBackwardAngle < FORWARD_BACKWARD_TILT_ANGLE_LIMIT + self.calibratedAngle || forwardOrBackwardAngle > -FORWARD_BACKWARD_TILT_ANGLE_LIMIT + self.calibratedAngle) && (leftOrRightAngle > LEFT_RIGHT_TILT_ANGLE_LIMIT || leftOrRightAngle < -LEFT_RIGHT_TILT_ANGLE_LIMIT))
    {
        //NSLog(@"Tilted %f degrees clockwise", leftOrRightAngle);
        if (!isInWebView)
        {
            if (scrollView.contentOffset.y + leftOrRightAngle/5 >= CONTENTOFFSET_LIMIT && !self.selectModeIsOn)
            {
                CGPoint offsetCGPoint = CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + leftOrRightAngle/5);
                scrollView.contentOffset = offsetCGPoint;
                //NSLog(@"Contentoffset.y is %f", scrollView.contentOffset.y);
                if (!self.scrollingSessionHasStarted)
                {
                    // This should happen only ONCE per scrolling session- note when a scrollingsession began and when it ends
                    [self.delegate addObserverForAdjustToNearestRowNotification];
                    // NSLog(@"delegate method addObserverForAdjustToNearestRowNotification called");
                    self.scrollingSessionHasStarted = YES;
                }
                
            }
        }
        else if (isInWebView)
        {
            if (scrollView.frame.size.height > scrollView.contentOffset.y + leftOrRightAngle/5 >= CONTENTOFFSET_LIMIT && !self.selectModeIsOn)
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
            if (leftOrRightAngle > LEFT_RIGHT_TILT_ANGLE_LIMIT)
            {
                // Post this notification and immediately remove the observer, as we want this to happen only once
                [[NSNotificationCenter defaultCenter] postNotificationName:RAPSelectRowNotification object:self];
                self.selectModeIsOn = NO;
            }
            else if (leftOrRightAngle < -LEFT_RIGHT_TILT_ANGLE_LIMIT)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:RAPSegueBackNotification object:self];
                self.selectModeIsOn = NO;
            }
            
        }
        //NSLog(@"Contentoffset.y is %f", scrollView.contentOffset.y);
    }
    if ((forwardOrBackwardAngle > FORWARD_BACKWARD_TILT_ANGLE_LIMIT + self.calibratedAngle || forwardOrBackwardAngle < -FORWARD_BACKWARD_TILT_ANGLE_LIMIT + self.calibratedAngle) && (leftOrRightAngle < LEFT_RIGHT_TILT_ANGLE_LIMIT || leftOrRightAngle > -LEFT_RIGHT_TILT_ANGLE_LIMIT))
    {
        // NSLog(@"Tilted %f degrees", forwardOrBackwardAngle);
        if (!self.selectModeHasBeenSwitched) // selectModeHasBeenSwitched is needed to differentiate between neutral state and selecting state. selectModeIsOn is used to toggle between creating the rect selector and removing it.
        {
            BOOL change = !self.selectModeIsOn;
            self.selectModeIsOn = change;
            self.selectModeHasBeenSwitched = YES;
        }
        if (self.selectModeIsOn)
        {
            // For some reason when separating into a dictionary to put in the notification, the following code does not allow the rect selector to start from the bottom: NSDictionary *dictionaryWithBools = @{[NSNumber numberWithBool:[self floatIsPositive:forwardOrBackwardAngle]]:@"atTop",[NSNumber numberWithBool:isInWebView]:@"inWebView"};
            // Post this notification and immediately remove the observer, as we want this to happen only once
            [[NSNotificationCenter defaultCenter] postNotificationName:RAPCreateRectSelectorNotification object:self userInfo:[NSDictionary dictionaryWithObjects:@[[NSNumber numberWithBool:[self angleIsForward:forwardOrBackwardAngle]], [NSNumber numberWithBool:isInWebView], [NSNumber numberWithFloat:forwardOrBackwardAngle]] forKeys:@[@"atTop",@"inWebView",@"angle"]]];
            //NSLog(@"Attop is %d", [self floatIsPositive:forwardOrBackwardAngle]);
            //NSLog(@"Tilted %f degrees forward", forwardOrBackwardAngle);
        }
        if (!self.selectModeIsOn)
        {
            // Post this notification and immediately remove the observer, as we want this to happen only once
            [[NSNotificationCenter defaultCenter] postNotificationName:RAPRemoveRectSelectorNotification object:self];
        }
        
    }
    
    if (forwardOrBackwardAngle < FORWARD_BACKWARD_TILT_ANGLE_LIMIT + self.calibratedAngle && forwardOrBackwardAngle > -FORWARD_BACKWARD_TILT_ANGLE_LIMIT + self.calibratedAngle && leftOrRightAngle < LEFT_RIGHT_TILT_ANGLE_LIMIT && leftOrRightAngle > -LEFT_RIGHT_TILT_ANGLE_LIMIT)
    {
        // Prevent each millisecond of having device tilted turn select mode on/off repeatedly
        self.selectModeHasBeenSwitched = NO;
        self.scrollingSessionHasStarted = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:RAPTableViewShouldAdjustToNearestRowAtIndexPathNotification object:self];
    }
    
}

-(void)turnOffSelectMode
{
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
