//
//  RAPCommentDataSource.m
//  redditAPI
//
//  Created by Woudini on 3/4/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "RAPCommentDataSource.h"
#import "RAPThreadCommentTableViewCell.h"
@interface RAPCommentDataSource ()

@property (nonatomic, strong) NSDictionary *itemsDictionary;
@property (nonatomic, copy) TableViewCellCommentBlock commentCellBlock;

@end

@implementation RAPCommentDataSource

- (id)initWithItems:(NSDictionary *)anItems
     cellIdentifier:(NSString *)aCellIdentifier
   commentCellBlock:(TableViewCellCommentBlock)aCommentCellBlock
{
    self = [super init];
    if (self) {
        self.itemsDictionary = [[NSDictionary alloc] initWithDictionary:anItems];
        self.commentCellBlock = [aCommentCellBlock copy];
    }
    return self;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RAPThreadCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell" forIndexPath:indexPath];
    
    if (indexPath.row == 0)
    {
        id item = [self itemAtIndexPath:indexPath];
        self.commentCellBlock(cell, item);
    }
    else
    {
        
    }

    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int numberOfRows = 1+[self getNumberOfRepliesFromDictionary:self.itemsDictionary];
    NSLog(@"number of rows is %d", numberOfRows);
    return numberOfRows;
}

-(NSInteger)getNumberOfRepliesFromDictionary:(NSDictionary *)itemsDictionary
{
//    while replies count is greater than zero,
//        for each child
//            commentNumber++;
//            set replies to child's replies
    //NSLog(@"repliesobject is %@", NSStringFromClass([repliesObject class]));

    int index = 0;
    
    NSArray *repliesChildrenArray = itemsDictionary[@"replies"][@"data"][@"children"];

    for (int i = 0; i < [repliesChildrenArray count]; i++)
    {
        id repliesChildrenReplies = [repliesChildrenArray objectAtIndex:i][@"data"][@"replies"];
        index++;
        
        NSLog(@"repliesobject is %@", NSStringFromClass([repliesChildrenReplies class]));

        if ([repliesChildrenReplies respondsToSelector:@selector(count)])
        {
            if ([repliesChildrenReplies count] > 0)
            {
                NSLog(@"responded to count");
                index += [self getNumberOfRepliesFromDictionary:[repliesChildrenArray objectAtIndex:i][@"data"]];
            }
        }
        else if ([repliesChildrenReplies respondsToSelector:@selector(length)])
        {
            if ([repliesChildrenReplies length] > 0)
            {
                NSLog(@"responded to length");
                index += [self getNumberOfRepliesFromDictionary:[repliesChildrenArray objectAtIndex:i][@"data"]];
            }
        }

    }
    return index;
}

//-(NSInteger)getNumberOfRepliesFromDictionary:(NSDictionary *)itemsDictionary withStartingRowIndex:(int)index;
//{
//    id repliesChildren = itemsDictionary[@"replies"][@"data"][@"children"];
//    
//    for (int i = 0; i < [repliesChildren count]; i++)
//    {
//        if ([[repliesChildren objectAtIndex:i][@"data"][@"replies"] count] > 0)
//        {
//            for (int j = 0; j < [[repliesChildren objectAtIndex:i][@"data"][@"replies"][@"data"][@"children"] count]; j++)
//            {
//                if ([[[repliesChildren objectAtIndex:i][@"data"][@"replies"][@"data"][@"children"] objectAtIndex:j][@"data"][@"replies"] count] > 0)
//                {
//                    until "replies" = 0
//                }
//            }
//        }
//    }
//    NSLog(@"numberofrows:%d", index);
//    return index;
//}

//-(int)recursiveFunctionForReplies:(NSDictionary *)repliesDictionary
//{
//    if ([repliesDictionary count] == 0)
//    {
//        return 0;
//    }
//    else
//    {
//        return [self recursiveFunctionForReplies:repliesDictionary];
//    }
//}
//
//-(int)recursiveFunctionforChildren:(NSArray *)childrenArray
//{
//    for (int i = 0; i < [childrenArray count]; i++)
//    {
//        childrenArray[i][@"data"][@"replies"]
//    }
//}

@end
