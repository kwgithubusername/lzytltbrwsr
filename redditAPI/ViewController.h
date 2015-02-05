//
//  ViewController.h
//  redditAPI
//
//  Created by Woudini on 1/13/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RAPViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) NSString *subRedditURLString;
@end

