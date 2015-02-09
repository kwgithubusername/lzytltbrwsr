//
//  RAPTiltToScroll.h
//  redditAPI
//
//  Created by Woudini on 2/3/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TiltToScrollDelegate <NSObject>

-(void)addAdjustToNearestRowNotification;

@end

@interface RAPTiltToScroll : NSObject
@property (nonatomic) id <TiltToScrollDelegate> delegate;
-(void)startTiltToScrollWithSensitivity:(float)sensitivity forScrollView:(UIScrollView *)scrollView;

@end
