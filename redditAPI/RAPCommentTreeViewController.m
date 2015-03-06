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
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupDataSource];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
