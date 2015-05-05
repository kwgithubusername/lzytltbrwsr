//
//  RAPThreadDataSource.m
//  redditAPI
//
//  Created by Woudini on 2/27/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "RAPThreadDataSource.h"
#import "RAPThreadTopicTableViewCell.h"
#import "RAPThreadCommentTableViewCell.h"

#define RAPFinalRowLoadedNotification @"RAPFinalRowLoadedNotification"

@interface RAPThreadDataSource()
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, copy) NSString *cellIdentifier;
@property (nonatomic, copy) TableViewCellTopicBlock topicCellBlock;
@property (nonatomic, copy) TableViewCellCommentBlock commentCellBlock;

@end

@implementation RAPThreadDataSource

- (id)initWithItems:(NSArray *)anItems
     cellIdentifier:(NSString *)aCellIdentifier
     topicCellBlock:(TableViewCellTopicBlock)aTopicCellBlock
   commentCellBlock:(TableViewCellCommentBlock)aCommentCellBlock
{
    self = [super init];
    if (self) {
        self.items = [[NSMutableArray alloc] initWithArray:anItems];
        self.cellIdentifier = aCellIdentifier;
        self.topicCellBlock = [aTopicCellBlock copy];
        self.commentCellBlock = [aCommentCellBlock copy];
    }
    return self;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.items[(NSUInteger) indexPath.row];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // index 1 beyond bounds for empty array
    if ([[self.items objectAtIndex:1][@"data"][@"children"] count])
    {
        //NSLog(@"self.items count is %lu, add 1 to get the indexpathrow for the blank cell", (unsigned long)[self.items count]);
        // Object at index 0 is the thread topic, so count the number of cells and add 1
        // The last row needs to be blank as it is counted as selecting the favorites toolbar, so add another cell
        return [[self.items objectAtIndex:1][@"data"][@"children"] count] + 2;
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
        RAPThreadTopicTableViewCell *topicCell = [tableView dequeueReusableCellWithIdentifier:@"threadTopicCell"];
        
        return [self configureTopicCell:topicCell atIndexPath:indexPath];
    }
    else if (indexPath.row == [[self.items objectAtIndex:1][@"data"][@"children"] count]+1)
    {
        RAPThreadCommentTableViewCell *blankCell = [tableView dequeueReusableCellWithIdentifier:@"threadCommentCell"];
        blankCell.usernameLabel.text = @"";
        blankCell.commentLabel.text = @"";
        return blankCell;
    }
    else
    {
        RAPThreadCommentTableViewCell *commentCell = [tableView dequeueReusableCellWithIdentifier:@"threadCommentCell"];
        return [self configureCommentCell:commentCell atIndexPath:indexPath];
    }
    
}

-(RAPThreadTopicTableViewCell *)configureTopicCell:(RAPThreadTopicTableViewCell *)topicCell atIndexPath:(NSIndexPath *)indexPath
{
    id data = [[self.items firstObject][@"data"][@"children"] firstObject][@"data"];
    
    self.topicCellBlock(topicCell, data);
    
    return topicCell;
}

-(RAPThreadCommentTableViewCell *)configureCommentCell:(RAPThreadCommentTableViewCell *)commentCell atIndexPath:(NSIndexPath *)indexPath
{
    id data = [[self.items objectAtIndex:1][@"data"][@"children"] objectAtIndex:(indexPath.row-1)][@"data"];
    
    self.commentCellBlock(commentCell, data, indexPath);
    
    return commentCell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // If the last row is loaded, notify the tiltToScrollVC to count how many cells are currently visible
    if (indexPath.row == (int)[[self.items objectAtIndex:1][@"data"][@"children"] count] + 1)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:RAPFinalRowLoadedNotification object:nil];
    }
}


@end
