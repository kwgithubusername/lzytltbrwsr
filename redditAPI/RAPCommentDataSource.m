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

@property (nonatomic) NSDictionary *itemsDictionary;
@property (nonatomic, copy) TableViewCellCommentBlock commentCellBlock;
@property (nonatomic) NSDictionary *dataDictionary;

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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int numberOfRows = 1+[self getNumberOfRepliesFromDictionary:self.itemsDictionary];
    NSLog(@"number of rows is %d", numberOfRows);
    return numberOfRows;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RAPThreadCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell" forIndexPath:indexPath];
    
    if (indexPath.row == 0)
    {
        id item = self.itemsDictionary;
        self.commentCellBlock(cell, item);
    }
    else
    {
        NSDictionary *dataDictionary = [[NSDictionary alloc] initWithDictionary:[self getCommentsFromDictionary:self.itemsDictionary[@"replies"][@"data"]]];
        NSLog(@"dataDict body is %@ for indexpath.row %d", dataDictionary[@"body"], indexPath.row);
    }

    return cell;
}

-(NSDictionary *)getCommentsFromDictionary:(NSDictionary *)itemsDictionary
{
    int index = 0;
    // Count number of replies to parent.
    // increment number of replies as each time "data" is crossed
    // If indexPath.row at any point is > number of replies to that body, i.e., if replies count == 0, go to next child
    
    NSArray *repliesChildrenArray = itemsDictionary[@"children"];
    
    //NSLog(@"replieschildrenarray %@", repliesChildrenArray);
    
    for (int i = 0; i < [repliesChildrenArray count]; i++)
    {
        id repliesChildrenReplies = [repliesChildrenArray objectAtIndex:i][@"data"][@"replies"];
//        
//        // If we got the wrong "data", back up one index
//        if ([[repliesChildrenArray objectAtIndex:i][@"data"] objectForKey:@"count"] && ![[repliesChildrenArray objectAtIndex:i][@"data"] objectForKey:@"body"])
//        {
//            repliesChildrenReplies = [repliesChildrenReplies objectAtIndex:i-1][@"data"][@"replies"];
//        }
//        index++;
//        
//        //NSLog(@"repliesobjectreplies is %@", repliesChildrenReplies);
//        
//        if ([repliesChildrenReplies respondsToSelector:@selector(count)])
//        {
//            if ([repliesChildrenReplies count] > 0)
//            {
//                NSLog(@"responded to count");
//                index += [self getNumberOfRepliesFromDictionary:[repliesChildrenArray objectAtIndex:i][@"data"]];
//                self.dataDictionary = [[NSDictionary alloc] initWithDictionary:[self getCommentsFromDictionary:[repliesChildrenArray objectAtIndex:i][@"data"]]];
//                
//                // If we got the wrong "data", back up one index
//                if ([self.dataDictionary objectForKey:@"count"] && ![self.dataDictionary objectForKey:@"body"])
//                {
//                    self.dataDictionary = [[NSDictionary alloc] initWithDictionary:[self getCommentsFromDictionary:[repliesChildrenArray objectAtIndex:i-1][@"data"]]];
//                }
//            }
//        }
//        else if ([repliesChildrenReplies respondsToSelector:@selector(length)])
//        {
//            if ([repliesChildrenReplies length] > 0)
//            {
//                NSLog(@"responded to length");
//                index += [self getNumberOfRepliesFromDictionary:[repliesChildrenArray objectAtIndex:i][@"data"]];
//                self.dataDictionary = [[NSDictionary alloc] initWithDictionary:[self getCommentsFromDictionary:[repliesChildrenArray objectAtIndex:i][@"data"]]];
//                
//                // If we got the wrong "data", back up one index
//                if ([self.dataDictionary objectForKey:@"count"] && ![self.dataDictionary objectForKey:@"body"])
//                {
//                    self.dataDictionary = [[NSDictionary alloc] initWithDictionary:[self getCommentsFromDictionary:[repliesChildrenArray objectAtIndex:i-1][@"data"]]];
//                }
//            }
//        }
//        else
//        {
            self.dataDictionary = [[NSDictionary alloc] initWithDictionary:[self retrieveDataWithPreviousIndex:[repliesChildrenArray objectAtIndex:i][@"data"] fromCurrentIndex:i usingArray:repliesChildrenArray]];
//        }

    }
    NSLog(@"datadict is %@", self.dataDictionary);
    return self.dataDictionary;
}

-(NSDictionary *)retrieveDataWithPreviousIndex:(NSDictionary *)data fromCurrentIndex:(int)index usingArray:(NSArray *)array
{
    if ([data objectForKey:@"count"] && ![data objectForKey:@"body"])
    {
        return [array objectAtIndex:index-1][@"data"];
    }
    else
    {
        return data;
    }
}

-(NSInteger)getNumberOfRepliesFromDictionary:(NSDictionary *)itemsDictionary
{
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

@end
