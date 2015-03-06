//
//  RAPCommentDataSource.h
//  redditAPI
//
//  Created by Woudini on 3/4/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TableViewCellCommentBlock)(id cell, id item);

@interface RAPCommentDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

- (id)initWithItems:(NSDictionary *)anItems
     cellIdentifier:(NSString *)aCellIdentifier
   commentCellBlock:(TableViewCellCommentBlock)aCommentCellBlock;

@end
