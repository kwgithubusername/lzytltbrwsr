//
//  ViewController.m
//  redditAPI
//
//  Created by Woudini on 1/13/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "ViewController.h"
#import "RAPTableViewCell.h"
#import "RAPapi.h"
#import "RAPRedditLinks.h"
#import "RAPThreadViewController.h"
@interface RAPTiltToScrollViewController()
-(CGPoint)getRectSelectorOrigin;
- (void)createTableViewCellRectWithCellRect:(CGRect)cellRect;
@end

@interface RAPViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *resultsMutableArray;
@property (nonatomic) RAPapi *api;
@end

@implementation RAPViewController

-(RAPapi *)api
{
    if (!_api) _api = [[RAPapi alloc] init];
    return _api;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"threadSegue"])
    {
        NSIndexPath *indexPath;
        if (!CGRectIsEmpty(super.rectangleSelector.frame))
        {
//            CGRect currentLocationRect = super.rectangleSelector.currentLocationRect;
//            CGPoint pointToTarget = CGPointMake(0, currentLocationRect.origin.y - currentLocationRect.size.height/2 - 64 + self.tableView.contentOffset.y);
            indexPath = [self.tableView indexPathForCell:[[self.tableView visibleCells] objectAtIndex:super.rectangleSelector.cellIndex]];
            //NSLog(@"Subclass: Originselected is %@", NSStringFromCGPoint(super.rectangleSelector.currentLocationRect.origin));
            NSLog(@"Indexpath.row is %d", indexPath.row);
        }
        else // Otherwise, the user has tapped the row, so use the row that was tapped
        {
            indexPath = [self.tableView indexPathForSelectedRow];
        }
        
        RAPThreadViewController *threadViewController = segue.destinationViewController;
        NSMutableDictionary *redditEntry = [[NSMutableDictionary alloc] initWithDictionary:self.resultsMutableArray[indexPath.row]];
        NSString *linkIDString = [[NSString alloc] initWithFormat:@"%@.json", [redditEntry[@"data"] objectForKey:@"permalink"]];
        threadViewController.permalinkURLString = linkIDString;
    }
}

#pragma mark TableView Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.resultsMutableArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *redditEntry = [[NSDictionary alloc] initWithDictionary:self.resultsMutableArray[indexPath.row]];
    RAPTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.label.text = [redditEntry[@"data"] objectForKey:@"title"];
    cell.subLabel.text = [redditEntry[@"data"] objectForKey:@"subreddit"];
    
    [super createTableViewCellRectWithCellRect:[tableView rectForRowAtIndexPath:indexPath]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // App will not register reaching the bottom of the tableview with tilt-to-scroll, so fetch more data when second-to-last row has been reached
    
    if (indexPath.row == [self.resultsMutableArray count]-2)
    {
        NSDictionary *redditEntry = [[NSDictionary alloc] initWithDictionary:self.resultsMutableArray[indexPath.row+1]];
        NSString *linkIDString = [[NSString alloc] initWithFormat:@"%@", [redditEntry[@"data"] objectForKey:@"id"]];
        [self loadRedditJSONWithAppendingString:[[NSString alloc] initWithFormat:RAPRedditLimit_10_typePrefix_Link_, linkIDString]];
        NSLog(@"Appending json info %@",[[NSString alloc] initWithFormat:RAPRedditLimit_10_typePrefix_Link_, linkIDString]);
    }
}

#pragma mark View methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.resultsMutableArray = [[NSMutableArray alloc] init];
    [self loadReddit];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark Load Reddit and NSURLsession

- (void)loadReddit
{
    if (!self.subRedditURLString)
    {
        [self loadRedditJSONWithAppendingString:@"/.json"];
    }
    else
    {
        [self loadRedditJSONWithAppendingString:[[NSString alloc] initWithFormat:@"/r/%@/.json",self.subRedditURLString]];
    }
}

- (void)alertUserThatErrorOccurred
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error retrieving data" message:@"Could not get reddit data" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
}

- (void)loadRedditJSONWithAppendingString:(NSString *)appendString
{
    NSURL *url = [NSURL URLWithString:[[NSString alloc] initWithFormat:@"http://www.reddit.com%@", appendString]];
    NSLog(@"URL is %@", url);
    NSURLSessionConfiguration *sessionconfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionconfig];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          NSMutableDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                                          NSArray *jsonResults = [[NSArray alloc] initWithArray:[jsonData[@"data"] objectForKey:@"children"]];
                                          
                                          dispatch_async(dispatch_get_main_queue(), ^
                                                         {
                                                             if (![jsonResults count])
                                                             {
                                                                 [self alertUserThatErrorOccurred];
                                                             }
                                                             [self.resultsMutableArray addObjectsFromArray:jsonResults];
                                                             [self.tableView reloadData];
                                                         });
                                      }];
    
    [dataTask resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
