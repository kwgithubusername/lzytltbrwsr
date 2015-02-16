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

#define RAPSegueNotification @"RAPSegueNotification"

@interface RAPTiltToScrollViewController()
- (void)createTableViewCellRectWithCellRect:(CGRect)cellRect;
@end

@interface RAPThreadViewController ()
@property (nonatomic) NSMutableArray *resultsMutableArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation RAPThreadViewController

#pragma mark Segue Methods

-(void)segueWhenSelectedRow
{
    //[self performSegueWithIdentifier:@"subredditSegue" sender:nil];
}

#pragma mark Table View Methods

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
        [super createTableViewCellRectWithCellRect:[tableView rectForRowAtIndexPath:indexPath]];
        
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

#pragma mark Load reddit method

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
