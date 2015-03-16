//
//  RAPSubredditWebServices.m
//  redditAPI
//
//  Created by Woudini on 2/28/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "RAPSubredditWebServices.h"

#define CLIENT_ID @"lDpwq6nbxkYXLw"
#define CLIENT_SECRET @""

@interface RAPSubredditWebServices ()

@property (nonatomic) NSString *subredditString;
@property (nonatomic, copy) DoThingsAfterLoadingSubredditBlock aHandlerBlock;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) NSTimer *accessTokenTimer;

@end

@implementation RAPSubredditWebServices

-(id)initWithSubredditString:(NSString *)subredditString withHandlerBlock:(DoThingsAfterLoadingSubredditBlock)aHandlerBlock;
{
    if (self = [super init])
    {
        self.subredditString = subredditString;
        self.aHandlerBlock = aHandlerBlock;
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"] length] < 1)
        {
            [self obtainAccessToken];
        }
    }
    return self;
}

-(void)obtainAccessToken
{
    [self.accessTokenTimer invalidate];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"https://ssl.reddit.com/api/v1/access_token"]];
    [request setHTTPMethod:@"POST"];
    
    NSString* uuid = [[NSUUID UUID] UUIDString];
    
    NSString* postString = [[NSString alloc] initWithFormat:@"grant_type=https://oauth.reddit.com/grants/installed_client&device_id=%@",uuid];
    NSLog(@"grant_type:%@", postString);
    
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *plainString = [[NSString alloc] initWithFormat:@"%@:%@", CLIENT_ID, CLIENT_SECRET];
    
    NSData *plainData = [plainString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
    
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    NSURLResponse *requestResponse;
    NSData *requestHandler = [NSURLConnection sendSynchronousRequest:request returningResponse:&requestResponse error:nil];
    
    NSDictionary *requestReplyDictionary = [NSJSONSerialization JSONObjectWithData:requestHandler options:NSJSONReadingAllowFragments error:nil];
    //NSString *requestReply = [[NSString alloc] initWithBytes:[requestHandler bytes] length:[requestHandler length] encoding:NSASCIIStringEncoding];
    NSLog(@"requestReply: %@", requestReplyDictionary);

    //NSLog(@"expiresinclass is %@", [requestReplyDictionary[@"expires_in"] class]);
    self.accessTokenTimer = [NSTimer scheduledTimerWithTimeInterval:[requestReplyDictionary[@"expires_in"] doubleValue] target:self selector:@selector(obtainAccessToken) userInfo:nil repeats:YES];
    
    [self storeOauth2Token:requestReplyDictionary];
}

-(void)storeOauth2Token:(NSDictionary *)dictionary
{
    NSString *accessTokenString = dictionary[@"access_token"];
    [[NSUserDefaults standardUserDefaults] setObject:accessTokenString forKey:@"accessToken"];
}

-(void)requestDataForSubreddit
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSString *URLString = [[NSString alloc] initWithFormat:@"https://oauth.reddit.com/%@", self.subredditString];
    NSLog(@"URLString: %@", URLString);
    [request setURL:[NSURL URLWithString:URLString]];
    [request setHTTPMethod:@"GET"];
    
    NSString *bearerTokenString = [[NSString alloc] initWithFormat:@"bearer %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"]];
    
    [request setValue:bearerTokenString forHTTPHeaderField:@"Authorization"];
    
    NSURLResponse *requestResponse;
    NSData *requestHandler = [NSURLConnection sendSynchronousRequest:request returningResponse:&requestResponse error:nil];
    
    NSDictionary *requestReplyDictionary = [NSJSONSerialization JSONObjectWithData:requestHandler options:NSJSONReadingAllowFragments error:nil];
    //NSString *requestReply = [[NSString alloc] initWithBytes:[requestHandler bytes] length:[requestHandler length] encoding:NSASCIIStringEncoding];
    NSLog(@"CommentDataReply: %@", requestReplyDictionary);
    self.aHandlerBlock(requestReplyDictionary);
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

-(void)loadImageIntoCell:(RAPTableViewCell *)cell withURLString:(NSString *)URLString
{
    //NSLog(@"thumbnail url is %@", URLString);
    NSURL *url = [NSURL URLWithString:URLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    UIImage *placeholderImage = [[UIImage alloc] init];
    
    [cell.thumbnailImageView setImageWithURLRequest:request
                          placeholderImage:placeholderImage
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       
                                       //NSLog(@"setImageWithURLRequest executed");
                                       cell.thumbnailImageView.image = image;
                                       //cell.imageView.image = image;
                                       
                                   }
                              failure:nil];
    //return self.imageView.image;
}

@end
