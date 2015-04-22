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
    [super layoutSubviews];
    
    if (self.customIndentationLevel != 0)
    {
        int indention = self.customIndentationLevel*5;
        NSString *indentationStringUsername = [[NSString alloc] initWithFormat:@"H:|-%d-[usernameLabel]-|", indention];
        NSString *indentationStringComment = [[NSString alloc] initWithFormat:@"H:|-%d-[commentLabel]-|", indention];
        
        NSDictionary *viewsDictionary = @{ @"usernameLabel" : self.usernameLabel, @"commentLabel" : self.commentLabel};
        
        [self removeConstraints:self.constraints];
        
        [self.contentView addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"V:|-[usernameLabel]-4-[commentLabel]-4-|"
                                   options:0
                                   metrics:nil
                                   views:viewsDictionary]];
        [self.contentView addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:indentationStringComment
                                   options:0
                                   metrics:nil
                                   views:viewsDictionary]];
        [self.contentView addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:indentationStringUsername
                                   options:0
                                   metrics:nil
                                   views:viewsDictionary]];
    }
}

@end
