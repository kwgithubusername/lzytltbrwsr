//
//  RAPCommentTreeViewController.h
//  redditAPI
//
//  Created by Woudini on 2/26/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "RAPTiltToScrollViewController.h"

@interface RAPCommentTreeViewController : RAPTiltToScrollViewController

@property (nonatomic) NSString *threadNameFromNavigationBarString;
@property (nonatomic) NSDictionary *commentDataDictionary;

@end
