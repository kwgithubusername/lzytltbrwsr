//
//  RAPSelectorView.m
//  redditAPI
//
//  Created by Woudini on 2/2/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "RAPSelectorView.h"

@implementation RAPSelectorView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];
    }
    return self;
}

-(void)awakeFromNib
{
    [self setup];
}

-(void)setup
{
    [self setNeedsDisplay];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    CGPoint topLeft = CGPointMake(0,0);
    CGPoint topRight = CGPointMake(width,0);
    CGPoint bottomRight = CGPointMake(width,height);
    CGPoint bottomLeft = CGPointMake(0,height);
    
    UIBezierPath *x1 = [[UIBezierPath alloc] init];
    [x1 moveToPoint:topLeft];
    [x1 addLineToPoint:topRight];
    [x1 addLineToPoint:bottomLeft];
    [x1 addLineToPoint:bottomRight];
    
    [[UIColor redColor] setStroke];
    [x1 stroke];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
