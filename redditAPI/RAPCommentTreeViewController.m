//
//  RAPCommentTreeViewController.m
//  redditAPI
//
//  Created by Woudini on 2/26/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "RAPCommentTreeViewController.h"
#import "RAPCommentDataSource.h"
#import "RAPThreadCommentTableViewCell.h"

#define RAPGetRectSelectorShapesNotification @"RAPGetRectSelectorShapesNotification"

@interface RAPCommentTreeViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) RAPCommentDataSource *dataSource;
@property (nonatomic) NSMutableArray *mutableArrayOfCommentDataDictionaries;

@end

@implementation RAPCommentTreeViewController

-(void)setupDataSource
{
    void (^commentCell)(RAPThreadCommentTableViewCell *, id) = ^(RAPThreadCommentTableViewCell *commentCell, id item) {
        commentCell.commentLabel.text = item[@"body"];
        commentCell.usernameLabel.text = item[@"author"];
    };
    
    self.dataSource = [[RAPCommentDataSource alloc] initWithItems:self.mutableArrayOfCommentDataDictionaries cellIdentifier:@"commentCell" commentCellBlock:commentCell];
    
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self.dataSource;
}

-(void)notifySuperclassToGetRectSelectorShapes
{
    [[NSNotificationCenter defaultCenter] postNotificationName:RAPGetRectSelectorShapesNotification object:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mutableArrayOfCommentDataDictionaries = [[NSMutableArray alloc] init];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.mutableArrayOfCommentDataDictionaries addObject:self.commentDataDictionary];
    [self getComments];
    // Do any additional setup after loading the view.
}

-(void)getComments
{
    // Get a background thread to run on
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self getCommentsFromDictionary:self.commentDataDictionary[@"replies"][@"data"]];

        // update UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setupDataSource];
            [self.tableView reloadData];
            self.tableView.estimatedRowHeight = 44;
            self.tableView.rowHeight = UITableViewAutomaticDimension;
            [self notifySuperclassToGetRectSelectorShapes];
        });
        
    });
}

-(void)getCommentsFromDictionary:(NSDictionary *)itemsDictionary
{
    // Count number of replies to parent.
    // increment number of replies as each time "data" is crossed
    // If indexPath.row at any point is > number of replies to that body, i.e., if replies count == 0, go to next child
    
    NSArray *repliesChildrenArray = itemsDictionary[@"children"];
    
    for (int i = 0; i < [repliesChildrenArray count]; i++)
    {
        if ([repliesChildrenArray objectAtIndex:i][@"data"][@"body"])
        {
            [self.mutableArrayOfCommentDataDictionaries addObject:[repliesChildrenArray objectAtIndex:i][@"data"]];
        };
        
        if ([[repliesChildrenArray objectAtIndex:i][@"data"][@"replies"] respondsToSelector:@selector(count)])
        {
            [self getCommentsFromDictionary:[repliesChildrenArray objectAtIndex:i][@"data"][@"replies"][@"data"]];
        }
    }
    NSLog(@"commentdata count is %lu", (unsigned long)[self.mutableArrayOfCommentDataDictionaries count]);
}

- (void)requestData
{
    [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

@end
