//
//  RAPTiltToScrollViewController.h
//  redditAPI
//
//  Created by Woudini on 2/14/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RAPTiltToScroll.h"
@interface RAPTiltToScrollViewController : UIViewController <UIScrollViewDelegate, TiltToScrollDelegate>
@property (nonatomic) UITableView *tableView;

-(instancetype)initWithTableView:(UITableView *)tableView;

@end
