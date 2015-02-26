//
//  RAPRectangleSelector.h
//  redditAPI
//
//  Created by Woudini on 2/7/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RAPRectangleSelector : UIView
@property (nonatomic) BOOL userHasStoppedSelection;
@property (nonatomic) CGRect currentLocationRect;
@property (nonatomic) int cellIndex;
@property (nonatomic) int cellMax;
@property (nonatomic) BOOL isStationary;
@property (nonatomic) NSMutableArray *rectsMutableArray;
@property (nonatomic) CGFloat statusBarPlusNavigationBarHeight;

-(id)initWithFramesMutableArray:(NSMutableArray *)mutableArray atTop:(BOOL)atTop withCellMax:(int)cellMax inWebView:(BOOL)isInWebView inInitialFrame:(CGRect)frame withToolbarRect:(CGRect)toolbarRect;
-(void)reset;
@end
