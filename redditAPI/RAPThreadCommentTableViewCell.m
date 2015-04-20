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

- (void)layoutSubviews
{
    // Call super
    [super layoutSubviews];
    
    // Update the separator
    self.separatorInset = UIEdgeInsetsMake(0, (self.indentationLevel * self.indentationWidth) + 15, 0, 0);
    
    // Update the frame of the text label
    self.usernameLabel.frame = CGRectMake(self.imageView.frame.origin.x + 40, self.textLabel.frame.origin.y, self.frame.size.width - (self.imageView.frame.origin.x + 60), self.textLabel.frame.size.height);
    
    // Update the frame of the subtitle label
    self.commentLabel.frame = CGRectMake(self.imageView.frame.origin.x + 40, self.detailTextLabel.frame.origin.y, self.frame.size.width - (self.imageView.frame.origin.x + 60), self.detailTextLabel.frame.size.height);
}

@end
