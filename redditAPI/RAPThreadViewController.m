//
//  RAPThreadViewController.m
//  redditAPI
//
//  Created by Woudini on 2/4/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "RAPThreadViewController.h"
#import "RAPThreadTopicTableViewCell.h"
#import "RAPThreadCommentTableViewCell.h"
#import "RAPRectangleReferenceForAdjustingScrollView.h"
#import "RAPRectangleSelector.h"

@interface RAPThreadViewController ()
@property (nonatomic) NSMutableArray *resultsMutableArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) RAPTiltToScroll *tiltToScroll;
@property (nonatomic) CGRect tableViewCellRect;
@property (nonatomic) RAPRectangleSelector *rectangleSelector;
@property (nonatomic) RAPRectangleReferenceForAdjustingScrollView *rectangleReference;
@end

#define RAPSelectRowNotification @"RAPSelectRowNotification"
#define RAPCreateRectSelectorNotification @"RAPCreateRectSelectorNotification"
#define RAPTableViewShouldAdjustToNearestRowAtIndexPathNotification @"RAPTableViewShouldAdjustToNearestRowAtIndexPathNotification"
#define RAPRemoveRectSelectorNotification @"RAPRemoveRectSelectorNotification"

@implementation RAPThreadViewController

-(RAPTiltToScroll *)tiltToScroll
{
    if (!_tiltToScroll) _tiltToScroll = [[RAPTiltToScroll alloc] init];
    return _tiltToScroll;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.resultsMutableArray count])
    {
        return [[self.resultsMutableArray objectAtIndex:1][@"data"][@"children"] count] + 1;
    }
    else
    {
        return 0;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        if (CGRectIsEmpty(self.tableViewCellRect))
        {
            CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
            self.tableViewCellRect = CGRectMake(cellRect.origin.x, cellRect.origin.y+self.navigationController.navigationBar.frame.size.height+[self statusBarHeight], cellRect.size.width, cellRect.size.height);
            NSLog(@"Tableviewcellrect is %@", NSStringFromCGRect(self.tableViewCellRect));
            NSLog(@"Frame is %@", NSStringFromCGRect(self.view.frame));
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createRectSelector) name:RAPCreateRectSelectorNotification object:self.tiltToScroll];
        }
        
        RAPThreadTopicTableViewCell *topicCell = [self.tableView dequeueReusableCellWithIdentifier:@"threadTopicCell"];
        
        id data = [[self.resultsMutableArray firstObject][@"data"][@"children"] firstObject][@"data"];
        
        topicCell.topicLabel.text = data[@"title"];
        topicCell.usernameLabel.text = data[@"author"];
        return topicCell;
    }
    else
    {
        RAPThreadCommentTableViewCell *commentCell = [self.tableView dequeueReusableCellWithIdentifier:@"threadCommentCell"];
        
        id data = [[self.resultsMutableArray objectAtIndex:1][@"data"][@"children"] objectAtIndex:(indexPath.row-1)][@"data"];
        
        commentCell.commentLabel.text = data[@"body"];
        commentCell.usernameLabel.text = data[@"author"];
                                                      
        return commentCell;
    }
    
}

- (void)loadRedditJSONWithAppendingString:(NSString *)appendString
{
    NSURL *url = [NSURL URLWithString:[[NSString alloc] initWithFormat:@"http://www.reddit.com%@", appendString]];
    //NSLog(@"URL is %@", url);
    NSURLSessionConfiguration *sessionconfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionconfig];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          NSMutableArray *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                                          //NSLog(@"Results are %@", jsonData);
                                          //NSLog(@"JSONdata is %@", [jsonData firstObject][@"data"]);
                                          //NSArray *jsonResults = [[NSArray alloc] initWithArray:[jsonData];
                                          //NSString *string = [[NSString alloc] initWithString:[jsonData firstObject][@"data"][@"selftext"] ];
                                          //NSLog(@"string is %@", string);
                                          dispatch_async(dispatch_get_main_queue(), ^
                                                         {
                                                             [self.resultsMutableArray addObjectsFromArray:jsonData];
                                                             [self.tableView reloadData];
                                                         });
                                      }];
    
    [dataTask resume];
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

#pragma mark View Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    NSLog(@"permalinkis = %@", self.permalinkURLString);
    self.resultsMutableArray = [[NSMutableArray alloc] init];
    [self loadRedditJSONWithAppendingString:self.permalinkURLString];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tiltToScroll.delegate = self;
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Rect Selector Methods

-(float)statusBarHeight
{
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    return MIN(statusBarSize.width, statusBarSize.height);
}

-(void)userSelectedRow
{
    NSLog(@"User selected row");
    //[self performSegueWithIdentifier:@"threadSegue" sender:nil];
}

-(void)createRectSelector
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


@end
