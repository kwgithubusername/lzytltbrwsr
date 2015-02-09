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
@interface RAPViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *resultsMutableArray;
@property (nonatomic) RAPapi *api;
@property (nonatomic) RAPSelectorView *RAPRectangleSelectorView;
@property (nonatomic) RAPTiltToScroll *tiltToScroll;
@property (nonatomic) CGRect tableViewCellRect;
@property (nonatomic) RAPRectangleSelector *rectangleSelector;
@property (nonatomic) RAPRectangleReferenceForAdjustingScrollView *rectangleReference;
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
    if ([segue.identifier isEqualToString:@"threadSegue"])
    {
        RAPThreadViewController *threadViewController = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSMutableDictionary *redditEntry = [[NSMutableDictionary alloc] initWithDictionary:self.resultsMutableArray[indexPath.row]];
        //NSString *testString = @"r/SwingDancing/comments/2uc1f2/question_can_you_help_me_locate_this_song/.json";
        NSString *linkIDString = [[NSString alloc] initWithFormat:@"%@.json", [redditEntry[@"data"] objectForKey:@"permalink"]];
        threadViewController.permalinkURLString = linkIDString;
    }
}

#pragma mark TableView Methods

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

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
    
    if (CGRectIsEmpty(self.tableViewCellRect))
    {
        CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
        self.tableViewCellRect = CGRectMake(cellRect.origin.x, cellRect.origin.y+self.navigationController.navigationBar.frame.size.height+[self statusBarHeight], cellRect.size.width, cellRect.size.height);
        NSLog(@"Tableviewcellrect is %@", NSStringFromCGRect(self.tableViewCellRect));
        NSLog(@"Frame is %@", NSStringFromCGRect(self.view.frame));
        // Now that we have a cell, we can get rect selector's shape
        [self notificationSetupForInitializingRectSelector];
        [self createRectReference];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RAPTableViewShouldAdjustToNearestRowAtIndexPathNotification" object:self.tiltToScroll];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:[[self.tableView visibleCells] firstObject]];
    NSLog(@"IndexPath is %d", indexPath.row);
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(void)addAdjustToNearestRowNotification
{
    NSLog(@"Schmee");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustTableView) name:@"RAPTableViewShouldAdjustToNearestRowAtIndexPathNotification" object:self.tiltToScroll];
}

#pragma mark Setup and NSURLSession

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDictionary *d = @{@"poo":@3};
    NSArray *a = @[@"s"];
    
    NSLog(@"Dictionary is %@, Array is %@", d, a);
    self.resultsMutableArray = [[NSMutableArray alloc] init];
    
    [self loadReddit];
    
    self.tiltToScroll.delegate = self;
    [self.tiltToScroll startTiltToScrollWithSensitivity:1 forScrollView:self.tableView];
    // Do any additional setup after loading the view, typically from a nib.
}

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
                                          //NSLog(@"Results are %@", jsonData);
                                          
                                          dispatch_async(dispatch_get_main_queue(), ^
                                                         {
                                                             [self.resultsMutableArray addObjectsFromArray:jsonResults];
                                                             [self.tableView reloadData];
                                                            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustTableView) name:@"RAPTableViewShouldAdjustToNearestRowAtIndexPathNotification" object:self.tiltToScroll];
                                                         });
                                      }];
    
    [dataTask resume];
}

#pragma mark Rectangle Selector methods

-(void)userSelectedRow
{
    NSLog(@"Rect is at %@", NSStringFromCGRect(self.rectangleSelector.frame));
}

-(float)statusBarHeight
{
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    return MIN(statusBarSize.width, statusBarSize.height);
}

- (void)notificationSetupForInitializingRectSelector
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createRectSelector) name:@"RAPCreateRectSelectorNotification" object:self.tiltToScroll];
    
//    [[NSNotificationCenter defaultCenter] addObserverForName:@"RAPRectReferenceShouldMoveByCGFloatIncrement" object:self.tiltToScroll queue:nil usingBlock:^(NSNotification *note)
//    {
//        [self moveRectReferenceByCGFloatAmount:[[note.userInfo objectForKey:@"incrementKey"] floatValue]];
//    }];
}

- (void)createRectSelector
{
    NSLog(@"let's make a rect selector");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RAPCreateRectSelectorNotification" object:self.tiltToScroll];
    self.rectangleSelector = [[RAPRectangleSelector alloc] initWithFrame:self.tableViewCellRect];
    self.rectangleSelector.incrementCGFloat = self.tableViewCellRect.size.height;
    self.rectangleSelector.tag = 999;
    [self.view addSubview:self.rectangleSelector];
    [self.view bringSubviewToFront:self.rectangleSelector];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userSelectedRow) name:@"RAPSelectRowNotification" object:self.tiltToScroll];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeRectSelector) name:@"RAPRemoveRectSelectorNotification" object:self.tiltToScroll];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RAPSelectRowNotification" object:self.tiltToScroll];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RAPRemoveRectSelectorNotification" object:self.tiltToScroll];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createRectSelector) name:@"RAPCreateRectSelectorNotification" object:self.tiltToScroll];
}

-(void)createRectReference
{
    if (!self.rectangleReference)
    {
        self.rectangleReference = [[RAPRectangleReferenceForAdjustingScrollView alloc] initWithFrame:self.tableViewCellRect];
        [self.view addSubview:self.rectangleReference];
        [self.view bringSubviewToFront:self.rectangleReference];
    }
}

-(void)moveRectReferenceByCGFloatAmount:(CGFloat)incrementCGFloat
{
    CGRect newFrame = CGRectMake(self.rectangleReference.frame.origin.x, self.rectangleReference.frame.origin.y + incrementCGFloat, self.rectangleReference.frame.size.width, self.rectangleReference.frame.size.height);
    self.rectangleReference.frame = newFrame;
    NSLog(@"Newframe is %@", NSStringFromCGRect(self.rectangleReference.frame));
}

- (void)tapRowAtIndexPathWhenTiltedRight
{
    
}

- (void)cancelRectWhenTiltedleft
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RAPCreateRectSelectorNotification" object:self.tiltToScroll];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RAPSelectRowNotification" object:self.tiltToScroll];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RAPRectReferenceShouldMoveByCGFloatIncrement" object:self.tiltToScroll];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RAPTableViewShouldAdjustToNearestRowAtIndexPathNotification" object:self.tiltToScroll];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RAPCreateRectSelectorNotification" object:self.tiltToScroll];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RAPRemoveRectSelectorNotification" object:self.tiltToScroll];
}

@end
