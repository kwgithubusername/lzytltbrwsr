//
//  RAPTableViewCell.m
//  redditAPI
//
//  Created by Woudini on 1/13/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "RAPTableViewCell.h"

@implementation RAPTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self.thumbnailImageView addObserver:self
                           forKeyPath:@"image"
                              options:NSKeyValueObservingOptionOld
                              context:NULL];
    }
    
    return self;
}

// The reason we’re observing changes is that if you create a table view cell, return it to the
// table view, and then later add an image (perhaps after doing some background processing), you
// need to call -setNeedsLayout on the cell for it to add the image view to its view hierarchy. We
// asked the change dictionary to contain the old value because this only needs to happen if the
// image was previously nil.
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == self.thumbnailImageView &&
        [keyPath isEqualToString:@"image"] &&
        ([change objectForKey:NSKeyValueChangeOldKey] == nil ||
         [change objectForKey:NSKeyValueChangeOldKey] == [NSNull null])) {
            NSLog(@"Setneedslayout called");
            [self setNeedsLayout];
        }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
