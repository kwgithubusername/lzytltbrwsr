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
    if ([self.items count])
    {
        // Object at index 0 is the thread topic, so count the number of cells and add 1
        return [[self.items objectAtIndex:1][@"data"][@"children"] count] + 1;
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
    
    self.commentCellBlock(commentCell, data);
    
    return commentCell;
}


@end
