//
//  RAPLinkSelectorDataSource.h
//  redditAPI
//
//  Created by Woudini on 5/9/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef UITableViewCell* (^CellForRowAtIndexPathBlock)(NSIndexPath *indexPath, UITableView *tableView);
typedef NSInteger (^RowsInSectionBlock)(UITableView *tableView);

@interface RAPLinkSelectorDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

- (id)initWithRowsInSectionBlock:(RowsInSectionBlock)aRowsInSectionBlock
      CellForRowAtIndexPathBlock:(CellForRowAtIndexPathBlock)aCellForRowAtIndexPathBlock;

@end
