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
#import "RAPRectangleSelector.h"
#import "RAPLinkViewController.h"
#import "RAPThreadDataSource.h"
#import "RAPSubredditWebServices.h"
#import "RAPCommentTreeViewController.h"
#import "FLFDateFormatter.h"
#import "RAPLinkViewController.h"
#import "RAPLinkSelectorViewController.h"

#define RAPSegueNotification @"RAPSegueNotification"
#define RAPGetRectSelectorShapesNotification @"RAPGetRectSelectorShapesNotification"

@interface RAPTiltToScrollViewController()
-(void)turnOffSelectMode;
@end

@interface RAPThreadViewController ()
@property (nonatomic) FLFDateFormatter *dateFormatter;
@property (nonatomic) NSMutableArray *resultsMutableArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) UIActivityIndicatorView *spinner;
@property (nonatomic) RAPThreadDataSource *dataSource;
@property (nonatomic) RAPSubredditWebServices *webServices;
@property (nonatomic) NSMutableArray *URLsMutableArray;
@end

@implementation RAPThreadViewController

-(FLFDateFormatter *)dateFormatter
{
    if (!_dateFormatter) _dateFormatter = [[FLFDateFormatter alloc] init];
    return _dateFormatter;
}

#pragma mark Segue Methods

-(int)getIndexForSelectedRow
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
    
    // This indexPath will be used to fetch the comments; since every comment that will be selected will have an index of 1 or greater, decrement by 1 to appropriately fetch all comments from index 0 to n
    return (int)indexPath.row-1;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"linkSegue"])
    {
        RAPLinkViewController *linkViewController = segue.destinationViewController;
        id data = [[self.resultsMutableArray firstObject][@"data"][@"children"] firstObject][@"data"];
        linkViewController.URLstring = data[@"url"];
    }
    else if ([segue.identifier isEqualToString:@"commentSegue"])
    {
        RAPCommentTreeViewController *commentTreeViewController = segue.destinationViewController;
        commentTreeViewController.navigationController.title = self.navigationController.title;
        
        int appropriateIndex = [self getIndexForSelectedRow];
        commentTreeViewController.commentDataDictionary = [[NSDictionary alloc] initWithDictionary:[[self.resultsMutableArray objectAtIndex:1][@"data"][@"children"] objectAtIndex:(appropriateIndex)][@"data"]];
    }
    else if ([segue.identifier isEqualToString:@"linkCellSegue"])
    {
        RAPLinkViewController *linkViewController = segue.destinationViewController;
        linkViewController.URLstring = [self.URLsMutableArray firstObject];
    }
    else if ([segue.identifier isEqualToString:@"linkSelectorSegue"])
    {
        RAPLinkSelectorViewController *linkSelectorViewController = segue.destinationViewController;
        linkSelectorViewController.URLsArray = [[NSArray alloc] initWithArray:self.URLsMutableArray];
    }
}

-(BOOL)commentAtIndexHasReplies:(int)index
{
    return [[[self.resultsMutableArray objectAtIndex:1][@"data"][@"children"] objectAtIndex:(index)][@"data"][@"replies"] respondsToSelector:@selector(count)] ? YES : NO;
}

-(void)segueWhenSelectedRow
{
    int appropriateIndex = [self getIndexForSelectedRow];
    
    if (super.rectangleSelector.cellIndex == 0 && [self.tableView indexPathForCell:[[self.tableView visibleCells] firstObject]].row == 0)
    {
        RAPThreadTopicTableViewCell *topicCell = [[self.tableView visibleCells] firstObject];
        
        self.URLsMutableArray = [[NSMutableArray alloc] initWithArray:[topicCell.topicLabel getArrayOfURLs]];
        
        id data = [[self.resultsMutableArray firstObject][@"data"][@"children"] firstObject][@"data"];
        NSString *URLstring = data[@"url"];
        [self.URLsMutableArray insertObject:URLstring atIndex:0];
        
        if (self.URLsMutableArray.count == 2)
        {
            [self performSegueWithIdentifier:@"linkCellSegue" sender:nil];
        }
        else if (self.URLsMutableArray.count > 2)
        {
            [self performSegueWithIdentifier:@"linkSelectorSegue" sender:nil];
        }
        else
        {
            [self performSegueWithIdentifier:@"linkSegue" sender:nil];
        }
    }
    else
    {
        RAPThreadCommentTableViewCell *currentCell = (RAPThreadCommentTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self getIndexForSelectedRow]+1 inSection:0]];
        self.URLsMutableArray = [[NSMutableArray alloc] initWithArray:[currentCell.commentLabel getArrayOfURLs]];
        
        if (super.rectangleSelector.cellIndex == super.rectangleSelector.cellMax)
        {
            [self performSegueWithIdentifier:@"favoritesSegue" sender:nil];
        }
        else if ([self commentAtIndexHasReplies:appropriateIndex])
        {
            [self performSegueWithIdentifier:@"commentSegue" sender:nil];
        }
        else if (self.URLsMutableArray.count == 1)
        {
            [self performSegueWithIdentifier:@"linkCellSegue" sender:nil];
        }
        else if (self.URLsMutableArray.count > 1)
        {
            [self performSegueWithIdentifier:@"linkSelectorSegue" sender:nil];
        }
        else
        {
            [self turnOffSelectMode];
        }
    }

}

#pragma mark Table View Methods

- (void)setupDataSource
{
    __weak RAPThreadViewController *weakSelf = self;
    
    void (^topicCell)(RAPThreadTopicTableViewCell *, id) = ^(RAPThreadTopicTableViewCell *topicCell, id item) {
        weakSelf.navigationItem.title = [[NSString alloc] initWithFormat:@"%@: %@", item[@"subreddit"], item[@"title"]];
        topicCell.topicLabel.text = [[NSString alloc] initWithFormat:@"%@\n\n %@", item[@"title"], item[@"selftext"]];
        topicCell.usernameLabel.text = item[@"author"];
        // breakpoint tests multiple links in topic
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[item[@"created_utc"] doubleValue]];
        topicCell.timeLabel.text = [weakSelf.dateFormatter formatDate:date];
    };
    
    void (^commentCell)(RAPThreadCommentTableViewCell *, id, NSIndexPath *indexPath) = ^(RAPThreadCommentTableViewCell *commentCell, id item, NSIndexPath *indexPath) {
        
        commentCell.commentLabel.text = item[@"body"];
        commentCell.usernameLabel.text = [[NSString alloc] initWithFormat:@"%@ • %@", item[@"author"], item[@"score"]];
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[item[@"created_utc"] doubleValue]];
        commentCell.timeLabel.text = [weakSelf.dateFormatter formatDate:date];
        

        
        // If the first cell in the tableView is visible and the user wants the first comment, the cellIndex will be 2, so decrement by 1.
        BOOL hasComments = [weakSelf commentAtIndexHasReplies:(int)indexPath.row-1];
        dispatch_async(dispatch_get_main_queue(), ^{
            commentCell.commentBubbleImageView.alpha = hasComments ? 1 : 0;
        });
    };
    
    self.dataSource = [[RAPThreadDataSource alloc] initWithItems:self.resultsMutableArray cellIdentifier:@"" topicCellBlock:topicCell commentCellBlock:commentCell];
    
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self.dataSource;
}


#pragma mark Notify superclass to get rect selector shapes

-(void)notifySuperclassToGetRectSelectorShapes
{
    [[NSNotificationCenter defaultCenter] postNotificationName:RAPGetRectSelectorShapesNotification object:self];
}

#pragma mark Load reddit method

- (void)loadRedditJSONWithAppendingString:(NSString *)appendString
{
    [self startSpinner];
    
    void (^setupHandlerBlock)(id) = ^(NSArray *jsonData)
    {
        [self.resultsMutableArray addObjectsFromArray:jsonData];
        [self setupDataSource];
        [self.tableView reloadData];
        [self.spinner stopAnimating];
        [self notifySuperclassToGetRectSelectorShapes];
        self.tableView.estimatedRowHeight = 44;
        self.tableView.rowHeight = UITableViewAutomaticDimension;

    };
    
    self.webServices = [[RAPSubredditWebServices alloc] initWithSubredditString:appendString withHandlerBlock:setupHandlerBlock];
    [self.webServices requestDataForSubreddit];
}

#pragma mark View Methods

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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    //NSLog(@"permalinkis = %@", self.IDURLString);
    self.resultsMutableArray = [[NSMutableArray alloc] init];
    [self loadRedditJSONWithAppendingString:self.subredditString];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(segueWhenSelectedRow) name:RAPSegueNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Observer for RAPSegueNotification is removed in the superclass
    [super viewWillDisappear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // In certain subreddits e.g. /r/swingdancing, cells are not dynamically resized unless the following code is executed
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

@end
