//
//  RAPapi.m
//  redditAPI
//
//  Created by Woudini on 2/2/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "RAPapi.h"

@implementation RAPapi

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

- (void)loadRedditJSONWithAppendingString:(NSString *)appendString
{
    NSURL *url = [NSURL URLWithString:[[NSString alloc] initWithFormat:@"http://www.reddit.com/.json%@", appendString]];
    NSURLSessionConfiguration *sessionconfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionconfig];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          NSMutableDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                                          //NSArray *jsonResults = [[NSArray alloc] initWithArray:[jsonData[@"data"] objectForKey:@"children"]];
                                          //NSLog(@"Results are %@", jsonResults);
                                          
                                          dispatch_async(dispatch_get_main_queue(), ^
                                                         {
//                                                             resultsArray = [[NSArray alloc] initWithArray:jsonResults];
//                                                             [tableView reloadData];
                                                         });
                                      }];
    
    [dataTask resume];
}


@end
