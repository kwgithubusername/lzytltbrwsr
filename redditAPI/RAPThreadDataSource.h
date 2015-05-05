//
//  RAPThreadDataSource.h
//  redditAPI
//
//  Created by Woudini on 2/27/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TableViewCellTopicBlock)(id cell, id item);
typedef void (^TableViewCellCommentBlock)(id cell, id item, id indexPath);

@interface RAPThreadDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

- (id)initWithItems:(NSArray *)anItems
     cellIdentifier:(NSString *)aCellIdentifier
    topicCellBlock:(TableViewCellTopicBlock)aTopicCellBlock
   commentCellBlock:(TableViewCellCommentBlock)aCommentCellBlock;

- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

@end
