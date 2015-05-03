//
//  RAPFavoritesDataSource.m
//  redditAPI
//
//  Created by Woudini on 2/26/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "RAPFavoritesDataSource.h"

#define RAPFinalRowLoadedNotification @"RAPFinalRowLoadedNotification"

@interface RAPFavoritesDataSource()
@property (nonatomic, copy) RowsInSectionBlock rowsInSectionBlock;
@property (nonatomic, copy) CellForRowAtIndexPathBlock cellForRowAtIndexPathBlock;
@property (nonatomic, copy) CanEditRowAtIndexPathBlock canEditRowAtIndexPathBlock;
@property (nonatomic, copy) DeleteCellBlock deleteCellBlock;
@end

@implementation RAPFavoritesDataSource

- (id)init
{
    return nil;
}

-(id)initWithRowsInSectionBlock:(RowsInSectionBlock)aRowsInSectionBlock
CellForRowAtIndexPathBlock:(CellForRowAtIndexPathBlock)aCellForRowAtIndexPathBlock
CanEditRowAtIndexPathBlock:(CanEditRowAtIndexPathBlock)aCanEditRowAtIndexPathBlock
   deleteCellBlock:(DeleteCellBlock)aDeleteCellBlock
{
    self = [super init];
    if (self) {
        self.deleteCellBlock = [aDeleteCellBlock copy];
        self.rowsInSectionBlock = [aRowsInSectionBlock copy];
        self.cellForRowAtIndexPathBlock = [aCellForRowAtIndexPathBlock copy];
        self.canEditRowAtIndexPathBlock = [aCanEditRowAtIndexPathBlock copy];
        self.deleteCellBlock = [aDeleteCellBlock copy];
    }
    return self;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.rowsInSectionBlock(tableView);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cellForRowAtIndexPathBlock(indexPath, tableView);
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        self.deleteCellBlock(indexPath, tableView);
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If the last row is loaded, notify the tiltToScrollVC to count how many cells are currently visible
    if (indexPath.row == self.rowsInSectionBlock(tableView)-1)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:RAPFinalRowLoadedNotification object:nil];
    }
}

@end
