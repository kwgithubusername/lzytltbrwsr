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

#define RAPSegueNotification @"RAPSegueNotification"
#define RAPGetRectSelectorShapesNotification @"RAPGetRectSelectorShapesNotification"

@interface RAPViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *resultsMutableArray;
@property (nonatomic) RAPapi *api;
@property (nonatomic) UIActivityIndicatorView *spinner;
@end

@implementation RAPViewController

-(RAPapi *)api
{
    if (!_api) _api = [[RAPapi alloc] init];
    return _api;
}

#pragma mark Segue methods

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"threadSegue"])
    {
        NSIndexPath *indexPath;
        if (![self.tableView indexPathForSelectedRow])
        {
            indexPath = [self.tableView indexPathForCell:[[self.tableView visibleCells] objectAtIndex:super.rectangleSelector.cellIndex]];
            //NSLog(@"Indexpath.row is %d", indexPath.row);
        }
        else // Otherwise, the user has tapped the row, so use the row that was tapped
        {
            indexPath = [self.tableView indexPathForSelectedRow];
            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
        
        RAPThreadViewController *threadViewController = segue.destinationViewController;
        NSMutableDictionary *redditEntry = [[NSMutableDictionary alloc] initWithDictionary:self.resultsMutableArray[indexPath.row]];
        NSString *linkIDString = [[NSString alloc] initWithFormat:@"%@.json", [redditEntry[@"data"] objectForKey:@"permalink"]];
        threadViewController.permalinkURLString = linkIDString;
    }
}

-(void)segueWhenSelectedRow
{
    if (super.rectangleSelector.cellIndex != super.rectangleSelector.cellMax)
    {
        [self performSegueWithIdentifier:@"threadSegue" sender:nil];
    }
    else if (super.rectangleSelector.cellIndex == super.rectangleSelector.cellMax)
    {
        [self performSegueWithIdentifier:@"favoritesSegue" sender:nil];
    }
    // A selected row from this page will always segue

}

-(void)segueBack
{
    [self.navigationController popViewControllerAnimated:YES];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(segueWhenSelectedRow) name:RAPSegueNotification object:nil];
}

-(void)startSpinner
{
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinner.color = [UIColor grayColor];
    self.spinner.center = self.view.center;
    self.spinner.hidesWhenStopped = YES;
    [self.view addSubview:self.spinner];
    [self.view bringSubviewToFront:self.spinner];
    [self.spinner startAnimating];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Observer for RAPSegueNotification is removed in the superclass
    [super viewWillDisappear:animated];
}

#pragma mark Notify superclass to get rect selector shapes

-(void)notifySuperclassToGetRectSelectorShapes
{
    [[NSNotificationCenter defaultCenter] postNotificationName:RAPGetRectSelectorShapesNotification object:self];
}

#pragma mark Load Reddit and NSURLsession

- (void)loadReddit
{
    if (!self.subRedditURLString)
    {
        [self loadRedditJSONWithAppendingString:@"/.json"];
        self.navigationItem.title = @"frontpage";
    }
    else
    {
        [self loadRedditJSONWithAppendingString:[[NSString alloc] initWithFormat:@"/r/%@/.json",self.subRedditURLString]];
        self.navigationItem.title = [[NSString alloc] initWithFormat:@"%@",self.subRedditURLString];
    }
}

- (void)alertUserThatErrorOccurred
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error retrieving data" message:@"Could not get reddit data" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
}

- (void)loadRedditJSONWithAppendingString:(NSString *)appendString
{
    [self startSpinner];
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
                                                             [self.spinner stopAnimating];
                                                             [self notifySuperclassToGetRectSelectorShapes];
                                                         });
                                      }];
    
    [dataTask resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
