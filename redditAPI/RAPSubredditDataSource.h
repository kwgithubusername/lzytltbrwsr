//
//  RAPSubredditDataSource.h
//  redditAPI
//
//  Created by Woudini on 2/26/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TableViewCellConfigureBlock)(id cell, id item);
typedef void (^TableViewCellLoadingBlock)(id cell, id item);

@interface RAPSubredditDataSource : NSObject <UITableViewDataSource>

- (id)initWithItems:(NSArray *)anItems
     cellIdentifier:(NSString *)aCellIdentifier
 configureCellBlock:(TableViewCellConfigureBlock)aConfigureCellBlock
   loadingCellBlock:(TableViewCellLoadingBlock)aLoadingCellBlock;

- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

@end
