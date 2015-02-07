//
//  RAPFavoritesViewController.m
//  redditAPI
//
//  Created by Woudini on 2/3/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "RAPFavoritesViewController.h"
#import "ViewController.h"
@interface RAPFavoritesViewController ()
@property (nonatomic) NSMutableArray *favoritesMutableArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation RAPFavoritesViewController

#pragma mark Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"subredditSegue"])
    {
        RAPViewController *subredditViewController = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSString *subredditString = self.favoritesMutableArray[indexPath.row];
        subredditViewController.subRedditURLString = subredditString;
    }
}

#pragma mark Adding subreddits

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
                NSString *subredditToAddString = [subredditToAddTextField.text lowercaseString];
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
                                                             else
                                                             {
                                                                 [self.favoritesMutableArray addObject:appendString];
                                                                 [self.favoritesMutableArray sortUsingSelector:@selector(localizedCompare:)];
                                                                 NSIndexPath *indexPathForWord = [NSIndexPath indexPathForRow:[self.favoritesMutableArray indexOfObject:appendString] inSection:self.tableView.numberOfSections-1];
                                                                 [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPathForWord] withRowAnimation:UITableViewRowAnimationFade];
                                                                 [self updateFavorites];
                                                                 [self.tableView reloadData];
                                                             }
                                                             
                                                         });
                                      }];
    
    [dataTask resume];
}

#pragma mark Table View Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.favoritesMutableArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *favoritesCell = [self.tableView dequeueReusableCellWithIdentifier:@"favoritesCell"];
    favoritesCell.textLabel.text = [self.favoritesMutableArray objectAtIndex:indexPath.row];
    return favoritesCell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self.favoritesMutableArray removeObjectAtIndex:indexPath.row];
        [self updateFavorites];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


-(void)updateFavorites
{
    [[NSUserDefaults standardUserDefaults] setValue:self.favoritesMutableArray forKey:@"favorites"];
}

-(NSArray *)defaultSubredditFavorites
{
    return @[@"adviceanimals",@"announcements",@"askreddit",@"aww",@"blog",@"funny",@"gaming",@"iama",@"pics",@"politics",@"programming",@"science",@"technology",@"todayilearned",@"worldnews"];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSDictionary *defaultFavorites = [NSDictionary dictionaryWithObject:[self defaultSubredditFavorites] forKey:@"favorites"];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultFavorites];
    
    self.favoritesMutableArray = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] valueForKey:@"favorites"]];
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