//
//  RAPFavoritesDataSource.h
//  redditAPI
//
//  Created by Woudini on 2/26/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef UITableViewCell* (^CellForRowAtIndexPathBlock)(NSIndexPath *indexPath, UITableView *tableView);
typedef BOOL (^CanEditRowAtIndexPathBlock)();
typedef NSInteger (^RowsInSectionBlock)(UITableView *tableView);
typedef void (^DeleteCellBlock)(NSIndexPath *indexPath, UITableView *tableView);

@interface RAPFavoritesDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

- (id)initWithRowsInSectionBlock:(RowsInSectionBlock)aRowsInSectionBlock
CellForRowAtIndexPathBlock:(CellForRowAtIndexPathBlock)aCellForRowAtIndexPathBlock
CanEditRowAtIndexPathBlock:(CanEditRowAtIndexPathBlock)aCanEditRowAtIndexPathBlock
   deleteCellBlock:(DeleteCellBlock)aDeleteCellBlock;

@end
