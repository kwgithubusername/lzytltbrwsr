//
//  RAPLinkViewController.h
//  redditAPI
//
//  Created by Woudini on 2/18/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "RAPTiltToScrollViewController.h"
@interface RAPLinkViewController : RAPTiltToScrollViewController <NSURLSessionDownloadDelegate, UIWebViewDelegate>
@property (nonatomic) NSString *URLstring;
@end
