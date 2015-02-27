//
//  RAPTableViewCell.h
//  redditAPI
//
//  Created by Woudini on 1/13/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RAPTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *subLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;

@end
