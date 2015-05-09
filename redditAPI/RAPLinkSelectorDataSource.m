//
//  RAPLinkSelectorDataSource.m
//  redditAPI
//
//  Created by Woudini on 5/9/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "RAPLinkSelectorDataSource.h"

#define RAPFinalRowLoadedNotification @"RAPFinalRowLoadedNotification"

@interface RAPLinkSelectorDataSource ()
@property (nonatomic, copy) RowsInSectionBlock rowsInSectionBlock;
@property (nonatomic, copy) CellForRowAtIndexPathBlock cellForRowAtIndexPathBlock;

@end

@implementation RAPLinkSelectorDataSource

-(id)init
{
    return nil;
}

-(id)initWithRowsInSectionBlock:(RowsInSectionBlock)aRowsInSectionBlock CellForRowAtIndexPathBlock:(CellForRowAtIndexPathBlock)aCellForRowAtIndexPathBlock 
{
    self = [super init];
    if (self) {
        self.rowsInSectionBlock = [aRowsInSectionBlock copy];
        self.cellForRowAtIndexPathBlock = [aCellForRowAtIndexPathBlock copy];
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
    return NO;
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
