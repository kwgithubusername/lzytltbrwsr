//
//  RAPSubredditWebServices.m
//  redditAPI
//
//  Created by Woudini on 2/28/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "RAPSubredditWebServices.h"

@interface RAPSubredditWebServices ()

@property (nonatomic) NSString *subredditString;
@property (nonatomic, copy) DoThingsAfterLoadingSubredditBlock aHandlerBlock;

@end

@implementation RAPSubredditWebServices

-(id)initWithSubredditString:(NSString *)subredditString withHandlerBlock:(DoThingsAfterLoadingSubredditBlock)aHandlerBlock
{
    if (self = [super init])
    {
        self.subredditString = subredditString;
        self.aHandlerBlock = aHandlerBlock;
        [self loadSubreddit];
    }
    return self;
}

-(void)loadSubreddit
{
    NSURL *url = [NSURL URLWithString:[[NSString alloc] initWithFormat:@"http://www.reddit.com%@", self.subredditString]];
    NSLog(@"URL is %@", url);
    NSURLSessionConfiguration *sessionconfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionconfig];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          id jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                                          
                                          dispatch_async(dispatch_get_main_queue(), ^
                                                         {
                                                             self.aHandlerBlock(jsonData);
                                                         });
                                      }];
    
    [dataTask resume];

}

@end
