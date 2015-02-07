//
//  RAPFavoritesViewController.m
//  redditAPI
//
//  Created by Woudini on 2/3/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "RAPFavoritesViewController.h"

@interface RAPFavoritesViewController ()
@property (nonatomic) NSArray *favoritesArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation RAPFavoritesViewController
- (IBAction)addFavoriteButtonTapped:(UIBarButtonItem *)sender
{
    [self addSubreddit];
}

-(void)addSubreddit
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Add subreddit" message:@"reddit.com/r/" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = 100;
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag)
    {
        case 100:
        {
            if (buttonIndex == 1)
            {
                UITextField *subredditToAddTextField = [alertView textFieldAtIndex:0];
                NSString *subredditToAddString = subredditToAddTextField.text;
                if (subredditToAddString.length > 0)
                {
                    [self verifySubredditWithString:subredditToAddString];
                }
                else
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Blank entry" message:@"Please enter a subreddit" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    alertView.tag = 101;
                    [alertView show];
                }
            }
            break;
        }
        case 101:
        {
            [self addSubreddit];
            break;
        }
        case 404:
        {
            [self addSubreddit];
            break;
        }
    }
}

-(void)alertUserThatSubredditCannotBeFound
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid subreddit" message:@"Please enter a valid subreddit" delegate:self cancelButtonTitle:nil otherButtonTitles: @"OK", nil];
    alertView.tag = 404;
    [alertView show];
}

-(void)verifySubredditWithString:(NSString *)appendString
{
    NSURL *url = [NSURL URLWithString:[[NSString alloc] initWithFormat:@"http://www.reddit.com/r/%@/.json", appendString]];
    NSURLSessionConfiguration *sessionconfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionconfig];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          NSMutableDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                                          NSSet *jsonResults = [[NSSet alloc] initWithArray:[jsonData[@"data"] objectForKey:@"children"]];
                                          NSLog(@"Subreddit is %@", jsonData);
                                          
                                          dispatch_async(dispatch_get_main_queue(), ^
                                                         {
                                                             if ([jsonResults count] == 0)
                                                             {
                                                                 NSLog(@"subreddit not found");
                                                                 [self alertUserThatSubredditCannotBeFound];
                                                             }
                                                             
                                                         });
                                      }];
    
    [dataTask resume];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.favoritesArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *favoritesCell = [self.tableView dequeueReusableCellWithIdentifier:@"favoritesCell"];
    favoritesCell.textLabel.text = [self.favoritesArray objectAtIndex:indexPath.row];
    return favoritesCell;
}

-(NSArray *)defaultSubredditFavorites
{
    return @[@"adviceanimals",@"announcements",@"askreddit",@"aww",@"blog",@"funny",@"gaming",@"iama",@"pics",@"politics",@"programming",@"science",@"technology",@"todayilearned",@"worldnews"];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSDictionary *defaultFavorites = [NSDictionary dictionaryWithObject:[self defaultSubredditFavorites] forKey:@"favorites"];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultFavorites];
    
    self.favoritesArray = [[NSArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] valueForKey:@"favorites"]];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
