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
        
        self.layoutMargins = UIEdgeInsetsMake(4, indention, 4, 4);
        self.contentView.layoutMargins = self.layoutMargins;
    }
}

@end
