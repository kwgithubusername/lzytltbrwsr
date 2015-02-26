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

#define RAPSegueNotification @"RAPSegueNotification"
#define RAPGetRectSelectorShapesNotification @"RAPGetRectSelectorShapesNotification"


@interface RAPThreadViewController ()
@property (nonatomic) NSMutableArray *resultsMutableArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) UIActivityIndicatorView *spinner;
@end

@implementation RAPThreadViewController

#pragma mark Segue Methods

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"linkSegue"])
    {
        RAPLinkViewController *linkViewController = segue.destinationViewController;
        id data = [[self.resultsMutableArray firstObject][@"data"][@"children"] firstObject][@"data"];
        linkViewController.URLstring = data[@"url"];
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
}

#pragma mark Table View Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.resultsMutableArray count])
    {
        // Object at index 0 is the thread topic, so count the number of cells and add 1
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
        RAPThreadTopicTableViewCell *topicCell = [self.tableView dequeueReusableCellWithIdentifier:@"threadTopicCell"];
        
        return [self configureTopicCell:topicCell atIndexPath:indexPath];
    }
    else
    {
        RAPThreadCommentTableViewCell *commentCell = [self.tableView dequeueReusableCellWithIdentifier:@"threadCommentCell"];
        return [self configureCommentCell:commentCell atIndexPath:indexPath];
    }
    
}

-(RAPThreadTopicTableViewCell *)configureTopicCell:(RAPThreadTopicTableViewCell *)topicCell atIndexPath:(NSIndexPath *)indexPath
{
    id data = [[self.resultsMutableArray firstObject][@"data"][@"children"] firstObject][@"data"];
    
    self.navigationItem.title = [[NSString alloc] initWithFormat:@"%@: %@", data[@"subreddit"], data[@"title"]];
    topicCell.topicLabel.text = data[@"title"];
    topicCell.usernameLabel.text = data[@"author"];
    return topicCell;
}

-(RAPThreadCommentTableViewCell *)configureCommentCell:(RAPThreadCommentTableViewCell *)commentCell atIndexPath:(NSIndexPath *)indexPath
{
    id data = [[self.resultsMutableArray objectAtIndex:1][@"data"][@"children"] objectAtIndex:(indexPath.row-1)][@"data"];
    
    commentCell.commentLabel.text = data[@"body"];
    commentCell.usernameLabel.text = data[@"author"];
    
    return commentCell;
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
                                                             [self.spinner stopAnimating];
                                                             [self notifySuperclassToGetRectSelectorShapes];
                                                             self.tableView.rowHeight = UITableViewAutomaticDimension;
                                                             self.tableView.estimatedRowHeight = 44;
                                                         });
                                      }];
    
    [dataTask resume];
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
    NSLog(@"permalinkis = %@", self.permalinkURLString);
    self.resultsMutableArray = [[NSMutableArray alloc] init];
    [self loadRedditJSONWithAppendingString:self.permalinkURLString];
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
