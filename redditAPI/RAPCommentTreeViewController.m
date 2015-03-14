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

@end

@implementation RAPCommentTreeViewController

-(void)setupDataSource
{
    void (^commentCell)(RAPThreadCommentTableViewCell *, id) = ^(RAPThreadCommentTableViewCell *commentCell, id item) {
        commentCell.commentLabel.text = item[@"body"];
        commentCell.usernameLabel.text = item[@"author"];
    };
    
    self.dataSource = [[RAPCommentDataSource alloc] initWithItems:self.commentDataDictionary cellIdentifier:@"commentCell" commentCellBlock:commentCell];
    
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self.dataSource;
}

-(void)notifySuperclassToGetRectSelectorShapes
{
    [[NSNotificationCenter defaultCenter] postNotificationName:RAPGetRectSelectorShapesNotification object:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    //[self startOAuth2Request];
    //[self setupDataSource];
    [self.tableView reloadData];
    self.tableView.estimatedRowHeight = 44;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    // Do any additional setup after loading the view.
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
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.tableView.numberOfSections)] withRowAnimation:UITableViewRowAnimationNone];
    [self notifySuperclassToGetRectSelectorShapes];
}

@end
