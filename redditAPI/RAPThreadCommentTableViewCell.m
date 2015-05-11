//
//  RAPThreadCommentTableViewCell.m
//  redditAPI
//
//  Created by Woudini on 2/5/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "RAPThreadCommentTableViewCell.h"

@implementation RAPThreadCommentTableViewCell



- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.usernameLabel.text = @"";
    self.commentLabel.text = @"";
    self.timeLabel.text = @"";
}

@end
