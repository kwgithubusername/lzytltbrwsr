//
//  RAPSubredditWebServices.m
//  redditAPI
//
//  Created by Woudini on 2/28/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "RAPSubredditWebServices.h"
#import <AFNetworking.h>
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
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSLog(@"URL is %@", url);
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        self.aHandlerBlock(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Data"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
    
    [operation start];

}

@end
