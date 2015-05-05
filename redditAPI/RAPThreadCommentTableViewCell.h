//
//  RAPThreadCommentTableViewCell.h
//  redditAPI
//
//  Created by Woudini on 2/5/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RAPThreadCommentTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (nonatomic) int customIndentationLevel;
@property (weak, nonatomic) IBOutlet UIImageView *commentBubbleImageView;
@end
