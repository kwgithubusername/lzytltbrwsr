//
//  RAPThreadViewController.h
//  redditAPI
//
//  Created by Woudini on 2/4/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RAPTiltToScroll.h"

@interface RAPThreadViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, TiltToScrollDelegate>

@property (nonatomic) NSString *permalinkURLString;

@end
