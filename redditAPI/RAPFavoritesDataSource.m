//
//  RAPFavoritesDataSource.m
//  redditAPI
//
//  Created by Woudini on 2/26/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "RAPFavoritesDataSource.h"

@interface RAPFavoritesDataSource()
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, copy) NSString *cellIdentifier;
@property (nonatomic, copy) TableViewCellDeleteBlock deleteCellBlock;

@end

@implementation RAPFavoritesDataSource

- (id)init
{
    return nil;
}

- (id)initWithItems:(NSArray *)anItems
     cellIdentifier:(NSString *)aCellIdentifier
   deleteCellBlock:(TableViewCellDeleteBlock)aDeleteCellBlock
{
    self = [super init];
    if (self) {
        self.items = [[NSMutableArray alloc] initWithArray:anItems];
        self.cellIdentifier = aCellIdentifier;
        self.deleteCellBlock = [aDeleteCellBlock copy];
    }
    return self;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.items[(NSUInteger) indexPath.row];
}

- (id)itemAtIndexPathPlusOne:(NSIndexPath *)indexPath
{
    return self.items[(NSUInteger) indexPath.row+1];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.items count]+1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *favoritesCell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    if (indexPath.row == [self.items count])
    {
        favoritesCell.textLabel.text = @"";
    }
    else
    {
        favoritesCell.textLabel.text = [self.items objectAtIndex:indexPath.row];
    }
        
    return favoritesCell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self.items removeObjectAtIndex:indexPath.row];
        self.deleteCellBlock(indexPath);
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
