//
//  RAPRectangleSelector.h
//  redditAPI
//
//  Created by Woudini on 2/7/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RAPRectangleSelector : UIView
@property (nonatomic) CGFloat incrementCGFloat;
@property (nonatomic) BOOL userHasStoppedSelection;
@property (nonatomic) CGRect currentLocationRect;

-(id)initWithFrame:(CGRect)frame atTop:(BOOL)atTop;
-(void)reset;
@end
