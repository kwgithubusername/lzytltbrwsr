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

@property (nonatomic) NSArray *itemsArray;
@property (nonatomic, copy) TableViewCellCommentBlock commentCellBlock;
@property (nonatomic) NSDictionary *dataDictionary;
@end

@implementation RAPCommentDataSource

- (id)initWithItems:(NSArray *)anItems
     cellIdentifier:(NSString *)aCellIdentifier
   commentCellBlock:(TableViewCellCommentBlock)aCommentCellBlock
{
    self = [super init];
    if (self) {
        self.itemsArray = [[NSArray alloc] initWithArray:anItems];
        self.commentCellBlock = [aCommentCellBlock copy];
    }
    return self;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Add one for the favorites toolbar
    int numberOfRows = (int)(1+[self.itemsArray count]);
    NSLog(@"number of rows is %d", numberOfRows);
    return numberOfRows;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RAPThreadCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell" forIndexPath:indexPath];
    
    if (indexPath.row == 0)
    {
        id item = self.itemsArray[0];
        self.commentCellBlock(cell, item);
    }
    else if (indexPath.row == [self tableView:tableView numberOfRowsInSection:0]-1)
    {
        cell.usernameLabel.text = @"";
        cell.commentLabel.text = @"";
    }
    else
    {
//        cell.usernameLabel.text = @"";
//        cell.commentLabel.text = @"";
        self.commentCellBlock(cell, self.itemsArray[indexPath.row]);
    }
    return cell;
}

-(NSInteger)getNumberOfRepliesFromDictionary:(NSDictionary *)itemsDictionary
{
    int index = 0;
    
    NSArray *repliesChildrenArray = itemsDictionary[@"replies"][@"data"][@"children"];
    
    for (int i = 0; i < [repliesChildrenArray count]; i++)
    {
        id repliesChildrenReplies = [repliesChildrenArray objectAtIndex:i][@"data"][@"replies"];
        
        if ([repliesChildrenArray objectAtIndex:i][@"data"][@"body"])
        {
            index++;
        }
        //NSLog(@"repliesobject is %@", NSStringFromClass([repliesChildrenReplies class]));
        
        if ([repliesChildrenReplies respondsToSelector:@selector(count)])
        {
                index += [self getNumberOfRepliesFromDictionary:[repliesChildrenArray objectAtIndex:i][@"data"]];
        }
        
    }
    return index;
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


@end
