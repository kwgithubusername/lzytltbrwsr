//
//  RAPSubredditWebServices.m
//  redditAPI
//
//  Created by Woudini on 2/28/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "RAPSubredditWebServices.h"
#import "UICKeyChainStore.h"

#define CLIENT_ID @"lDpwq6nbxkYXLw"
#define CLIENT_SECRET @""

@interface RAPSubredditWebServices ()

@property (nonatomic) NSString *subredditString;
@property (nonatomic, copy) DoThingsAfterLoadingSubredditBlock aHandlerBlock;
@property (nonatomic) UIImageView *imageView;

@end

@implementation RAPSubredditWebServices

-(id)initWithSubredditString:(NSString *)subredditString withHandlerBlock:(DoThingsAfterLoadingSubredditBlock)aHandlerBlock;
{
    if (self = [super init])
    {
        self.subredditString = subredditString;
        self.aHandlerBlock = aHandlerBlock;
        
        UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:@"com.reddit.auth"];
        NSString *accessTokenString = keychain[@"access_token"];
        NSLog(@"accessTokenString is %@",accessTokenString);
        
        NSDate *dateOfExpiration = [[NSUserDefaults standardUserDefaults] objectForKey:@"expires_in"];
        
        if (!dateOfExpiration || [dateOfExpiration timeIntervalSinceNow] < 0.0)
        {
            [self obtainAccessToken];
        }
    }
    return self;
}

-(void)obtainAccessToken
{
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

    id timeToExpire = requestReplyDictionary[@"expires_in"];
    
    [self setupTimedRetrievalOfNewAccessToken:timeToExpire];
    
    [self storeOauth2Token:requestReplyDictionary];
}

-(void)setupTimedRetrievalOfNewAccessToken:(id)timeToExpire
{
    [self performSelector:@selector(obtainAccessToken) withObject:nil afterDelay:[timeToExpire doubleValue]];
    
    NSInteger timeToExpireInteger = [timeToExpire integerValue];
    
    NSDate *currentDate = [NSDate date];
    NSDate *dateOfExpiration = [currentDate dateByAddingTimeInterval:timeToExpireInteger];
    [[NSUserDefaults standardUserDefaults] setObject:dateOfExpiration forKey:@"expires_in"];
}

-(void)storeOauth2Token:(NSDictionary *)dictionary
{
    NSString *accessTokenString = dictionary[@"access_token"];
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:@"com.reddit.auth"];
    keychain[@"access_token"] = accessTokenString;
}

-(void)requestDataForSubreddit
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSString *URLString = [[NSString alloc] initWithFormat:@"https://oauth.reddit.com/%@", self.subredditString];
    NSLog(@"URLString: %@", URLString);
    [request setURL:[NSURL URLWithString:URLString]];
    [request setHTTPMethod:@"GET"];
    
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:@"com.reddit.auth"];
    
    NSString *bearerTokenString = [[NSString alloc] initWithFormat:@"bearer %@",keychain[@"access_token"]];
    
    [request setValue:bearerTokenString forHTTPHeaderField:@"Authorization"];
    
    NSURLSessionConfiguration *sessionconfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionconfig];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        //NSString *requestReply = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSASCIIStringEncoding];
        //NSLog(@"CommentDataReply: %@", requestReply);
        id jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if (error) {
            NSLog(@"error retrieving data:%@", [error localizedDescription]);
        }
            dispatch_async(dispatch_get_main_queue(), ^
        {
            // NSLog(@"data is %@", jsonData);
            self.aHandlerBlock(jsonData);
        });
    }];
    
    [dataTask resume];
}

-(void)loadSubreddit
{

// NSURLSESSION
    
//  NSURL *url = [NSURL URLWithString:[[NSString alloc] initWithFormat:@"http://www.reddit.com%@", self.subredditString]];
// NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    NSLog(@"URL is %@", url);
//    
//    NSURLSessionConfiguration *sessionconfig = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionconfig];
//    
//    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
//                                      {
//                                          id jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
//                                          
//                                          dispatch_async(dispatch_get_main_queue(), ^
//                                                         {
//                                                             self.aHandlerBlock(jsonData);
//                                                         });
//                                      }];
//    
//    [dataTask resume];
    
    
// AFNETWORKING
    
//    dispatch_queue_t backgroundQueue = dispatch_queue_create("com.name.bgqueue", NULL);
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    operation.responseSerializer = [AFJSONResponseSerializer serializer];
//    operation.completionQueue = backgroundQueue;
//    
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        self.aHandlerBlock(responseObject);
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Data"
//                                                            message:[error localizedDescription]
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"Ok"
//                                                  otherButtonTitles:nil];
//        [alertView show];
//    }];
//    
//    [operation start];

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
