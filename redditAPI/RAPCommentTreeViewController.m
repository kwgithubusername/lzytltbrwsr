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
    void (^commentCellBlock)(RAPThreadCommentTableViewCell *, id) = ^(RAPThreadCommentTableViewCell *commentCell, id item) {
        commentCell.commentLabel.text = item[@"body"];
        commentCell.usernameLabel.text = item[@"author"];
        commentCell.usernameLabel.text = [[NSString alloc] initWithFormat:@"Depth:%@", item[@"depth"]];
    };
    
    self.dataSource = [[RAPCommentDataSource alloc] initWithItems:self.mutableArrayOfCommentDataDictionaries cellIdentifier:@"commentCell" commentCellBlock:commentCellBlock];
    
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        dispatch_group_t d_group = dispatch_group_create();
        dispatch_group_t e_group = dispatch_group_create();
        
        dispatch_group_enter(d_group);
        [self getCommentsFromDictionary:self.commentDataDictionary[@"replies"][@"data"] withDepthIndex:0];
        dispatch_group_leave(d_group);
        
        dispatch_group_wait(d_group, DISPATCH_TIME_FOREVER);
        
        dispatch_group_enter(e_group);
        [self getProperDepthForComments];
        NSLog(@"done with comments");
        dispatch_group_leave(e_group);
        
        dispatch_group_wait(e_group, DISPATCH_TIME_FOREVER);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setupDataSource];
            [self.tableView reloadData];
            self.tableView.estimatedRowHeight = 44;
            self.tableView.rowHeight = UITableViewAutomaticDimension;
            [self notifySuperclassToGetRectSelectorShapes];
        });
    });
    
//    // Get a background thread to run on, since this is a longer process
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        [self getCommentsFromDictionary:self.commentDataDictionary[@"replies"][@"data"] withDepthIndex:0];
//
//        // update UI on the main thread
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self setupDataSource];
//            [self.tableView reloadData];
//            self.tableView.estimatedRowHeight = 44;
//            self.tableView.rowHeight = UITableViewAutomaticDimension;
//            [self notifySuperclassToGetRectSelectorShapes];
//        });
//        
//    });
}

-(void)getProperDepthForComments
{
    NSMutableArray *mutableArrayOfDepthIndexes = [[NSMutableArray alloc] init];
    
    for (NSMutableDictionary *mutableDictionary in self.mutableArrayOfCommentDataDictionaries)
    {
        NSNumber *depthNumber = [NSNumber numberWithInt:(int)mutableDictionary[@"depth"]];
        [mutableArrayOfDepthIndexes addObject:depthNumber];
    }
    
    // Remove duplicates
    NSMutableSet *mutableSetOfDepthIndexes = [[NSMutableSet alloc] initWithArray:mutableArrayOfDepthIndexes];
    
    // Order from smallest to largest
    NSMutableArray *orderedArrayOfDepthIndexes = [[NSMutableArray alloc] initWithArray:[mutableSetOfDepthIndexes allObjects]];
    [orderedArrayOfDepthIndexes sortUsingSelector:@selector(compare:)];
    NSLog(@"Ordered array is %@", orderedArrayOfDepthIndexes);
    
    int mutableArrayOfCommentDataDictionariesCount = (int)[self.mutableArrayOfCommentDataDictionaries count];
    
    for (int index = 1; index < mutableArrayOfCommentDataDictionariesCount; index++)
    {
        int currentDepth = (int)[self.mutableArrayOfCommentDataDictionaries[index] valueForKey:@"depth"];
        int rankInt = (int)[orderedArrayOfDepthIndexes indexOfObject:[NSNumber numberWithInt:currentDepth]];
        NSLog(@"rankInt is %d", rankInt);
        NSNumber *depthToUse = [NSNumber numberWithInt:rankInt];
        NSLog(@"depthTouse is %@", depthToUse);
        [self.mutableArrayOfCommentDataDictionaries[index] setValue:depthToUse forKey:@"depth"];
    }
}

-(void)getCommentsFromDictionary:(NSDictionary *)itemsDictionary withDepthIndex:(int)depthIndex
{
    // Count number of replies to parent.
    // increment number of replies as each time "data" is crossed
    // If indexPath.row at any point is > number of replies to that body, i.e., if replies count == 0, go to next child
    
    // Each comment has to have a depth.
    
    depthIndex++;
    
    NSArray *repliesChildrenArray = itemsDictionary[@"children"];
    
    int repliesChildrenArrayCount = (int)[repliesChildrenArray count];
    
    for (int index = 0; index < repliesChildrenArrayCount; index++)
    {
        if ([repliesChildrenArray objectAtIndex:index][@"data"][@"body"])
        {
            NSMutableDictionary *commentData = [[NSMutableDictionary alloc] initWithDictionary:[repliesChildrenArray objectAtIndex:index][@"data"]];
            [commentData setValue:[NSNumber numberWithInt:depthIndex] forKey:@"depth"];
            [self.mutableArrayOfCommentDataDictionaries addObject:commentData];
        };
        
        if ([[repliesChildrenArray objectAtIndex:index][@"data"][@"replies"] respondsToSelector:@selector(count)])
        {
            [self getCommentsFromDictionary:[repliesChildrenArray objectAtIndex:index][@"data"][@"replies"][@"data"] withDepthIndex:depthIndex];
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
