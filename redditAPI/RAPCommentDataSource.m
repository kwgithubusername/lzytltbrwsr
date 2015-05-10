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

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Add one for the favorites toolbar
    int numberOfRows = (int)(1+[self.itemsArray count]);
    // NSLog(@"number of rows is %d", numberOfRows);
    return numberOfRows;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RAPThreadCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell" forIndexPath:indexPath];
    
    NSLog(@"loading row %lu", (unsigned long)indexPath.row);
    
    if (indexPath.row == 0)
    {
        cell.customIndentationLevel = (int)indexPath.row;
        id item = self.itemsArray[indexPath.row];
        self.commentCellBlock(cell, item);
    }
    else if (indexPath.row == self.itemsArray.count)
    {
        cell.usernameLabel.text = @"";
        cell.commentLabel.text = @"";
    }
    else
    {
        NSDictionary *item = self.itemsArray[indexPath.row];
        
        cell.customIndentationLevel = (int)[item[@"depth"] intValue];

        int indention = cell.customIndentationLevel == 0 ? 4 : cell.customIndentationLevel*10;
            
        cell.layoutMargins = UIEdgeInsetsMake(4, indention, 4, 4);
        cell.contentView.layoutMargins = cell.layoutMargins;
        
        self.commentCellBlock(cell, item);
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
