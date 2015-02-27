//
//  ViewController.h
//  redditAPI
//
//  Created by Woudini on 1/13/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RAPTiltToScroll.h"
#import "RAPTiltToScrollViewController.h"
@interface RAPViewController : RAPTiltToScrollViewController <UITableViewDelegate>
@property (nonatomic) NSString *subRedditURLString;
@end

