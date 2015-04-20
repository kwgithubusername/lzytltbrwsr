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
#import "RAPSubredditDataSource.h"
#import "RAPSubredditWebServices.h"

#define RAPSegueNotification @"RAPSegueNotification"
#define RAPGetRectSelectorShapesNotification @"RAPGetRectSelectorShapesNotification"

@interface RAPSubredditViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *resultsMutableArray;
@property (nonatomic) UIActivityIndicatorView *spinner;
@property (nonatomic) RAPSubredditDataSource *dataSource;
@property (nonatomic) RAPSubredditWebServices *webServices;
@end

@implementation RAPSubredditViewController

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
        NSString *subredditString = [redditEntry[@"data"] objectForKey:@"subreddit"];
        NSString *IDURLString = [redditEntry[@"data"] objectForKey:@"id"];
        threadViewController.subredditString = [[NSString alloc] initWithFormat:@"r/%@/comments/%@", subredditString, IDURLString];
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

-(void)setupDataSource
{
    __weak RAPSubredditViewController *weakSelf = self;
    
    void (^configureCell)(RAPTableViewCell*, id) = ^(RAPTableViewCell *cell, id item) {
        cell.label.text = [item[@"data"] objectForKey:@"title"];
        cell.subLabel.text = [item[@"data"] objectForKey:@"subreddit"];
        [weakSelf.webServices loadImageIntoCell:cell withURLString:[item[@"data"] objectForKey:@"thumbnail"]];
    };
    
    void (^loadCell)(RAPTableViewCell*, id) = ^(RAPTableViewCell *cell, id item) {
        NSString *linkIDString = [[NSString alloc] initWithFormat:@"%@", [item[@"data"] objectForKey:@"id"]];
        [weakSelf loadRedditJSONWithAppendingString:[[NSString alloc] initWithFormat:RAPRedditLimit_10_typePrefix_Link_, linkIDString]];
        NSLog(@"Appending json info %@",[[NSString alloc] initWithFormat:RAPRedditLimit_10_typePrefix_Link_, linkIDString]);
    };
    
    self.dataSource = [[RAPSubredditDataSource alloc] initWithItems:self.resultsMutableArray
                                                    cellIdentifier:@"cell"
                                                 configureCellBlock:configureCell
                                                   loadingCellBlock:loadCell];
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self.dataSource;
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
        [self loadRedditJSONWithAppendingString:@""];
        self.navigationItem.title = @"frontpage";
    }
    else
    {
        [self loadRedditJSONWithAppendingString:[[NSString alloc] initWithFormat:@"/r/%@",self.subRedditURLString]];
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
    
    void (^setupHandlerBlock)(id) = ^(NSDictionary *jsonData)
    {
        NSArray *jsonResults = [[NSArray alloc] initWithArray:[jsonData[@"data"] objectForKey:@"children"]];
        [self.resultsMutableArray addObjectsFromArray:jsonResults];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
