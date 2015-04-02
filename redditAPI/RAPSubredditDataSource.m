//
//  RAPSubredditDataSource.m
//  redditAPI
//
//  Created by Woudini on 2/26/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "RAPSubredditDataSource.h"
#import "RAPTableViewCell.h"

#define RAPFinalRowLoadedNotification @"RAPFinalRowLoadedNotification"


@interface RAPSubredditDataSource()

@property (nonatomic) NSArray *items;
@property (nonatomic, copy) NSString *cellIdentifier;
@property (nonatomic, copy) TableViewCellConfigureBlock configureCellBlock;
@property (nonatomic, copy) TableViewCellLoadingBlock loadCellBlock;

@end

@implementation RAPSubredditDataSource

- (id)init
{
    return nil;
}

- (id)initWithItems:(NSArray *)anItems
     cellIdentifier:(NSString *)aCellIdentifier
 configureCellBlock:(TableViewCellConfigureBlock)aConfigureCellBlock
loadingCellBlock:(TableViewCellLoadingBlock)aLoadingCellBlock
{
    self = [super init];
    if (self) {
        self.items = anItems;
        self.cellIdentifier = aCellIdentifier;
        self.configureCellBlock = [aConfigureCellBlock copy];
        self.loadCellBlock = [aLoadingCellBlock copy];
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

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RAPTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier
                                                            forIndexPath:indexPath];
    id item = [self itemAtIndexPath:indexPath];
    self.configureCellBlock(cell, item);
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // App will not register reaching the bottom of the tableview with tilt-to-scroll, so fetch more data when second-to-last row has been reached
    
    if (indexPath.row == [self.items count]-2)
    {
        RAPTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier
                                                                 forIndexPath:indexPath];
        id item = [self itemAtIndexPathPlusOne:indexPath];
        self.loadCellBlock(cell, item);
    }
    
    // If the last row is loaded, notify the tiltToScrollVC to count how many cells are currently visible
    if (indexPath.row == (int)self.items.count-1)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:RAPFinalRowLoadedNotification object:nil];
    }
}

@end
