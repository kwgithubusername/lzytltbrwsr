//
//  RAPRectangleSelector.m
//  redditAPI
//
//  Created by Woudini on 2/7/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "RAPRectangleSelector.h"
@interface RAPRectangleSelector ()
@property (nonatomic) UIColor *rectColor;
@property (nonatomic) CGFloat rectRedCGFloat;
@property (nonatomic) CGFloat rectGreenCGFloat;
@property (nonatomic) CGFloat rectBlueCGFloat;
@property (nonatomic) NSTimer *changeColorTimer;
@end
@implementation RAPRectangleSelector

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
    self.rectColor = [UIColor greenColor];
    self.rectRedCGFloat = 0;
    self.rectGreenCGFloat = 1.0;
    self.rectBlueCGFloat = 0;
    //[self setNeedsDisplay];
    [self beginDecrementingAlpha];
}

-(void)beginDecrementingAlpha
{
    self.changeColorTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(changeColor) userInfo:nil repeats:YES];
}

-(void)changeColor
{
    self.rectColor = [UIColor colorWithRed:self.rectRedCGFloat green:self.rectGreenCGFloat blue:self.rectBlueCGFloat alpha:1];
    if (self.rectRedCGFloat < 0.9)
    {
        self.rectRedCGFloat = self.rectRedCGFloat + 0.1;
    }
    else
    {
        self.rectRedCGFloat = 1;
    }
    if (self.rectRedCGFloat == 1)
    {
        self.rectGreenCGFloat = self.rectGreenCGFloat - 0.1;
    }
    [self setNeedsDisplay];
    if (self.rectGreenCGFloat == 0)
    {
        [self.changeColorTimer invalidate];
        self.changeColorTimer = nil;
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    UIBezierPath *borderPath = [[UIBezierPath alloc] init];
    [borderPath moveToPoint:CGPointMake(0,0)];
//    [borderPath moveToPoint:CGPointMake(self.bounds.size.width, 0)];
    [borderPath moveToPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height)];
    [borderPath moveToPoint:CGPointMake(0,self.bounds.size.height)];
    [borderPath closePath];
    
    borderPath.lineWidth = 5.0;
    
    // Start by filling the area with the blue color
    [self.rectColor setFill];
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
