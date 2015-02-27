//
//  RAPFavoritesDataSource.h
//  redditAPI
//
//  Created by Woudini on 2/26/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TableViewCellDeleteBlock)(NSIndexPath *indexPath);

@interface RAPFavoritesDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

- (id)initWithItems:(NSArray *)anItems
     cellIdentifier:(NSString *)aCellIdentifier
   deleteCellBlock:(TableViewCellDeleteBlock)aDeleteCellBlock;

- (id)itemAtIndexPath:(NSIndexPath *)indexPath;


@end
