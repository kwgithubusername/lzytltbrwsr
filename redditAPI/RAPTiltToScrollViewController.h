//
//  RAPTiltToScrollViewController.h
//  redditAPI
//
//  Created by Woudini on 2/14/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RAPTiltToScroll.h"
#import "RAPRectangleSelector.h"

@interface RAPTiltToScrollViewController : UIViewController <UIScrollViewDelegate, TiltToScrollDelegate>
@property (weak, nonatomic) UITableView *tableView;
@property (nonatomic) RAPRectangleSelector *rectangleSelector;
@property (nonatomic) BOOL rectSelectorHasBeenMade;
@end
