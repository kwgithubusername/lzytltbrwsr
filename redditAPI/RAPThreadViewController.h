//
//  RAPThreadViewController.h
//  redditAPI
//
//  Created by Woudini on 2/4/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RAPTiltToScrollViewController.h"
@interface RAPThreadViewController : RAPTiltToScrollViewController

@property (nonatomic) NSString *IDURLString;
@property (nonatomic) NSString *subredditString;

@end
