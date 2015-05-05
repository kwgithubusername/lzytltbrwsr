//
//  RAPTiltToScroll.h
//  redditAPI
//
//  Created by Woudini on 2/3/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TiltToScrollDelegate <NSObject>
-(void)addObserverForAdjustToNearestRowNotification;
@end

@interface RAPTiltToScroll : NSObject
@property (nonatomic) id <TiltToScrollDelegate> delegate;
@property (nonatomic) BOOL isCalibrating;
@property (nonatomic) BOOL hasCalibrated;
@property (nonatomic) BOOL hasStarted;
-(instancetype)init;
-(void)turnOffSelectMode;
-(void)startTiltToScrollWithSensitivity:(float)sensitivity forScrollView:(UIScrollView *)scrollView inWebView:(BOOL)isInWebView;
-(void)stopTiltToScroll;
@end
