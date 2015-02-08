//
//  RAPRectangleReferenceForAdjustingScrollView.m
//  redditAPI
//
//  Created by Woudini on 2/8/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "RAPRectangleReferenceForAdjustingScrollView.h"

@implementation RAPRectangleReferenceForAdjustingScrollView

-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
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
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    // Start by filling the area with the blue color
    [[UIColor purpleColor] setFill];
    UIRectFill( rect );
    
    // Assume that there's an ivar somewhere called holeRect of type CGRect
    // We could just fill holeRect, but it's more efficient to only fill the
    // area we're being asked to draw.
    CGRect holeRect = CGRectMake(5, 5, self.bounds.size.width-10, self.bounds.size.height-10);
    CGRect holeRectIntersection = CGRectIntersection( holeRect, rect );
    
    [[UIColor clearColor] setFill];
    UIRectFill( holeRectIntersection );
}


@end
