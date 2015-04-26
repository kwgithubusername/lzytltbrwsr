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
//        [self.usernameLabel removeConstraint:self.usernameLabel.constraints[0]];
//        [self.commentLabel removeConstraint:self.commentLabel.constraints[0]];
//        
//        NSLog(@"usernamelabel constriants are %@", self.usernameLabel.constraints);
//        NSLog(@"commentlabel constriants are %@", self.commentLabel.constraints);
        
        self.usernameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.commentLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        int indention = self.customIndentationLevel*5;
        
        NSString *indentationStringUsername = [[NSString alloc] initWithFormat:@"H:|-%d-[usernameLabel]", indention];
        NSString *indentationStringComment = [[NSString alloc] initWithFormat:@"H:|-%d-[commentLabel]", indention];
        NSLog(@"indentation is %@", indentationStringComment);
        NSDictionary *viewsDictionary = @{ @"usernameLabel" : self.usernameLabel, @"commentLabel" : self.commentLabel};
        
//        [self.contentView addConstraints:[NSLayoutConstraint
//                                   constraintsWithVisualFormat:@"V:|-4-[usernameLabel]-[commentLabel]-4-|"
//                                   options:0
//                                   metrics:nil
//                                   views:viewsDictionary]];
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
