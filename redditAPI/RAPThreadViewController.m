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

#define RAPSegueNotification @"RAPSegueNotification"
#define RAPGetRectSelectorShapesNotification @"RAPGetRectSelectorShapesNotification"


@interface RAPThreadViewController ()
@property (nonatomic) NSMutableArray *resultsMutableArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) UIActivityIndicatorView *spinner;
@property (nonatomic) RAPThreadDataSource *dataSource;
@property (nonatomic) RAPSubredditWebServices *webServices;
@end

@implementation RAPThreadViewController

#pragma mark Segue Methods

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
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
        //commentTreeViewController.commentDataDictionary = [[NSDictionary alloc] initWithDictionary:[[self.resultsMutableArray objectAtIndex:1][@"data"][@"children"] objectAtIndex:(super.rectangleSelector.cellIndex-1)][@"data"]];
    }
}

-(void)segueWhenSelectedRow
{
    if (super.rectangleSelector.cellIndex == 0)
    {
        [self performSegueWithIdentifier:@"linkSegue" sender:nil];
    }
    else if (super.rectangleSelector.cellIndex == super.rectangleSelector.cellMax)
    {
        [self performSegueWithIdentifier:@"favoritesSegue" sender:nil];
    }
    else if ([[[self.resultsMutableArray objectAtIndex:1][@"data"][@"children"] objectAtIndex:(super.rectangleSelector.cellIndex-1)][@"data"][@"replies"] count] > 0)
    {
        [self performSegueWithIdentifier:@"commentSegue" sender:nil];
    }
}

#pragma mark Table View Methods

- (void)setupDataSource
{
    void (^topicCell)(RAPThreadTopicTableViewCell *, id) = ^(RAPThreadTopicTableViewCell *topicCell, id item) {
        self.navigationItem.title = [[NSString alloc] initWithFormat:@"%@: %@", item[@"subreddit"], item[@"title"]];
        topicCell.topicLabel.text = item[@"title"];
        topicCell.usernameLabel.text = item[@"author"];
    };
    
    void (^commentCell)(RAPThreadCommentTableViewCell *, id) = ^(RAPThreadCommentTableViewCell *commentCell, id item) {
        commentCell.commentLabel.text = item[@"body"];
        commentCell.usernameLabel.text = item[@"author"];
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
    [self.webServices requestCommentDataForID36Article:self.IDURLString];
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
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.tableView.numberOfSections)] withRowAnimation:UITableViewRowAnimationNone];
}

@end
