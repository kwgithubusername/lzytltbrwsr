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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // return 3;
    // Add one for the head comment
    // Add one for the favorites toolbar
    int numberOfRows = 2+[self getNumberOfRepliesFromDictionary:self.itemsDictionary];
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
    else if (indexPath.row == [self tableView:tableView numberOfRowsInSection:0]-1)
    {
        cell.usernameLabel.text = @"";
        cell.commentLabel.text = @"";
    }
    else
    {
        cell.usernameLabel.text = @"";
        cell.commentLabel.text = @"";
//        NSDictionary *dataDictionary = [[NSDictionary alloc] initWithDictionary:[self getCommentsFromDictionary:self.itemsDictionary[@"replies"][@"data"]]];
//        NSLog(@"dataDict body is %@ for indexpath.row %d", dataDictionary[@"body"], indexPath.row);
//        self.commentCellBlock(cell, dataDictionary);
    }
    return cell;
}

-(NSDictionary *)retrieveCommentsFromDictionary:(NSDictionary *)itemsDictionary
{
    __block int index = 0;
    //__block NSMutableArray *commentsMutableArray = [[NSMutableArray alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary * bindings)
    {
        if([evaluatedObject[@"data"][@"replies"] respondsToSelector:@selector(count)])
        {
            index++;
            //recursion needs to occur here
            return YES;
        }
        else
        {
            return NO;
        }
    }];
    
    NSArray *repliesChildrenArray = itemsDictionary[@"children"];
    
    for (int i = 0; i < [repliesChildrenArray count]; i++)
    {
        // FilteredArray will return child comments with replies
        NSArray *filteredArray = [[repliesChildrenArray objectAtIndex:i] filteredArrayUsingPredicate:predicate];
    }
    return nil;
}

/*
[
 {+}
 {-
    data:{
            children:[
                        {   -----BELOW IS WHERE COMMENTDATADICTIONARY STARTS-----
                            data:{
                                    body  <-- THIS BODY IS THE PARENT COMMENT
                                    replies:{   BELOW IS WHERE ITEMSDICTIONARY STARTS
                                                data:{  BELOW IS WHERE REPLIESCHILDRENARRAY STARTS
                                                        children:[
                                                                    { OBJECTATINDEX:i
                                                                        data:{
                                                                                body
                                                                                replies:{
*/

-(NSDictionary *)getCommentsFromDictionary:(NSDictionary *)itemsDictionary
{
    // Count number of replies to parent.
    // increment number of replies as each time "data" is crossed
    // If indexPath.row at any point is > number of replies to that body, i.e., if replies count == 0, go to next child
    
    NSArray *repliesChildrenArray = itemsDictionary[@"children"];
    
    //NSLog(@"replieschildrenarray %@", repliesChildrenArray);
    
    id dictionaryToReturn;
    
    for (int i = 0; i < [repliesChildrenArray count]; i++)
    {
        //NSLog(@"repliesobjectreplies is %@", repliesChildrenReplies);
        
        if ([[repliesChildrenArray objectAtIndex:i][@"data"][@"replies"] respondsToSelector:@selector(count)])
        {
            NSDictionary *tempDictionary = [[NSDictionary alloc] initWithDictionary:[self getCommentsFromDictionary:[repliesChildrenArray objectAtIndex:i][@"data"]]];
                
            dictionaryToReturn = [[NSDictionary alloc] initWithDictionary:[self retrieveDataWithPreviousIndex:tempDictionary fromCurrentIndex:i usingArray:repliesChildrenArray]];
        }
        else
        {
            dictionaryToReturn = [[NSDictionary alloc] initWithDictionary:[self retrieveDataWithPreviousIndex:[repliesChildrenArray objectAtIndex:i][@"data"] fromCurrentIndex:i usingArray:repliesChildrenArray]];
        }
    }
    NSLog(@"datadict is %@", dictionaryToReturn);
    return dictionaryToReturn;
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
