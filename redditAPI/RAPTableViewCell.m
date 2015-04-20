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

    }
    
    return self;
}



//- (NSArray *)getRangesForURLs:(NSAttributedString *)text
//{
//    NSMutableArray *rangesForURLs = [[NSMutableArray alloc] init];;
//    
//    // Use a data detector to find urls in the text
//    NSError *error = nil;
//    NSDataDetector *detector = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:&error];
//    
//    NSString *plainText = text.string;
//    
//    NSArray *matches = [detector matchesInString:plainText
//                                         options:0
//                                           range:NSMakeRange(0, text.length)];
//    
//    // Add a range entry for every url we found
//    for (NSTextCheckingResult *match in matches)
//    {
//        NSRange matchRange = [match range];
//        
//        // If there's a link embedded in the attributes, use that instead of the raw text
//        NSString *realURLString = [text attribute:NSLinkAttributeName atIndex:matchRange.location effectiveRange:nil];
//        if (realURLString == nil)
//            realURLString = [plainText substringWithRange:matchRange];
//        
//        if (![self ignoreMatch:realURLString])
//        {
//            if ([match resultType] == NSTextCheckingTypeLink)
//            {
//                [rangesForURLs addObject:@{KILabelLinkTypeKey : @(KILinkTypeURL),
//                                           KILabelRangeKey : [NSValue valueWithRange:matchRange],
//                                           KILabelLinkKey : realURL,
//                                           }];
//            }
//        }
//    }
//    
//    return rangesForURLs;
//}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
