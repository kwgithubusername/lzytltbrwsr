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
#import "RAPSelectorView.h"
#import "RAPRedditLinks.h"
#import "RAPRectangleSelector.h"
#import "RAPRectangleReferenceForAdjustingScrollView.h"
#import "RAPThreadViewController.h"

#define RAPSelectRowNotification @"RAPSelectRowNotification"
#define RAPCreateRectSelectorNotification @"RAPCreateRectSelectorNotification"
#define RAPTableViewShouldAdjustToNearestRowAtIndexPathNotification @"RAPTableViewShouldAdjustToNearestRowAtIndexPathNotification"
#define RAPRemoveRectSelectorNotification @"RAPRemoveRectSelectorNotification"

@interface RAPViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *resultsMutableArray;
@property (nonatomic) RAPapi *api;
@property (nonatomic) RAPSelectorView *RAPRectangleSelectorView;
@property (nonatomic) RAPTiltToScroll *tiltToScroll;
@property (nonatomic) CGRect tableViewCellRect;
@property (nonatomic) RAPRectangleSelector *rectangleSelector;
@end

@implementation RAPViewController

-(RAPTiltToScroll *)tiltToScroll
{
    if (!_tiltToScroll) _tiltToScroll = [[RAPTiltToScroll alloc] init];
    return _tiltToScroll;
}

-(RAPapi *)api
{
    if (!_api) _api = [[RAPapi alloc] init];
    return _api;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RAPSelectRowNotification object:self.tiltToScroll];
    [self.tiltToScroll stopTiltToScroll];
    [self removeRectSelector];
    
    if ([segue.identifier isEqualToString:@"threadSegue"])
    {
        RAPThreadViewController *threadViewController = segue.destinationViewController;
        NSIndexPath *indexPath;
        
        // If the the rectangle selector is being used, pick the row that the selector is currently over
        
        if (!CGRectIsEmpty(self.rectangleSelector.frame))
        {
            indexPath = [self.tableView indexPathForRowAtPoint:self.rectangleSelector.currentLocationRect.origin];
        }
        else // Otherwise, the user has tapped the row, so use the row that was tapped
        {
            indexPath = [self.tableView indexPathForSelectedRow];
        }
        
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
    
    // Need to get the frame we will use for the rect selector
    
    if (CGRectIsEmpty(self.tableViewCellRect))
    {
        CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
        self.tableViewCellRect = CGRectMake(cellRect.origin.x, cellRect.origin.y+self.navigationController.navigationBar.frame.size.height+[self statusBarHeight], cellRect.size.width, cellRect.size.height);
        NSLog(@"Tableviewcellrect is %@", NSStringFromCGRect(self.tableViewCellRect));
        NSLog(@"Frame is %@", NSStringFromCGRect(self.view.frame));
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createRectSelector) name:RAPCreateRectSelectorNotification object:self.tiltToScroll];
    }

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

-(void)adjustTableView
{
    // This method is needed to scroll the tableview to show entire cells when the user stops scrolling; That way no half, quarter, or other portion of a cell is missing and the rectangle selector will be hovering over only one cell
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RAPTableViewShouldAdjustToNearestRowAtIndexPathNotification object:self.tiltToScroll];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:[[self.tableView visibleCells] firstObject]];
    //NSLog(@"IndexPath is %d", indexPath.row);
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark TiltToScroll Delegate Method

-(void)addObserverForAdjustToNearestRowNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustTableView) name:RAPTableViewShouldAdjustToNearestRowAtIndexPathNotification object:self.tiltToScroll];
}

#pragma mark View methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.resultsMutableArray = [[NSMutableArray alloc] init];
    [self loadReddit];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tiltToScroll.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tiltToScroll startTiltToScrollWithSensitivity:1 forScrollView:self.tableView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createRectSelector) name:RAPCreateRectSelectorNotification object:self.tiltToScroll];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Tilt detection must be separate for each VC due to overreactivity with segues
    
    [self.tiltToScroll stopTiltToScroll];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RAPSelectRowNotification object:self.tiltToScroll];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RAPTableViewShouldAdjustToNearestRowAtIndexPathNotification object:self.tiltToScroll];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RAPCreateRectSelectorNotification object:self.tiltToScroll];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RAPRemoveRectSelectorNotification object:self.tiltToScroll];
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

#pragma mark Rectangle Selector methods

-(void)userSelectedRow
{
    NSLog(@"User selected row");
    [self performSegueWithIdentifier:@"threadSegue" sender:nil];
}

-(float)statusBarHeight
{
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    return MIN(statusBarSize.width, statusBarSize.height);
}

- (void)createRectSelector
{
    NSLog(@"let's make a rect selector");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RAPCreateRectSelectorNotification object:self.tiltToScroll];
    self.rectangleSelector = [[RAPRectangleSelector alloc] initWithFrame:self.tableViewCellRect];
    self.rectangleSelector.incrementCGFloat = self.tableViewCellRect.size.height;
    self.rectangleSelector.tag = 999;
    [self.view addSubview:self.rectangleSelector];
    [self.view bringSubviewToFront:self.rectangleSelector];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userSelectedRow) name:RAPSelectRowNotification object:self.tiltToScroll];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeRectSelector) name:RAPRemoveRectSelectorNotification object:self.tiltToScroll];
}

- (void)removeRectSelector
{
    for (UIView *view in self.view.subviews)
    {
        if (view.tag == 999)
        {
            [view removeFromSuperview];
        }
    }
    [self.rectangleSelector reset];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RAPSelectRowNotification object:self.tiltToScroll];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RAPRemoveRectSelectorNotification object:self.tiltToScroll];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createRectSelector) name:RAPCreateRectSelectorNotification object:self.tiltToScroll];
}

- (void)tapRowAtIndexPathWhenTiltedRight
{
    
}

- (void)cancelRectWhenTiltedleft
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RAPCreateRectSelectorNotification object:self.tiltToScroll];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
