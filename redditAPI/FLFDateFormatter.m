//
//  FLFDateFormatter.m
//  FNLApp
//
//  Created by Woudini on 4/21/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "FLFDateFormatter.h"

@implementation FLFDateFormatter

- (NSString *)formatDate:(NSDate *)date
{
    NSTimeInterval timeSinceDate = [[NSDate date] timeIntervalSinceDate:date];
    
    // print up to 24 hours as a relative offset
    if(timeSinceDate < 24.0 * 60.0 * 60.0)
    {
        NSUInteger hoursSinceDate = (NSUInteger)(timeSinceDate / (60.0 * 60.0));
        NSUInteger minutesSinceDate = (NSUInteger)(timeSinceDate / 60);
        switch(hoursSinceDate)
        {
            default:
                return [NSString stringWithFormat:@"%luh", (unsigned long)hoursSinceDate];
            case 0:
                // x minutes ago
                return minutesSinceDate == 0 ?
                [[NSString alloc] initWithFormat:@"%lus",(unsigned long)(timeSinceDate)] :
                [[NSString alloc] initWithFormat:@"%lum",(unsigned long)(minutesSinceDate)];
                break;
        }
    }
    else
    {
        // x days ago
        NSUInteger daysSinceDate = (NSUInteger)(timeSinceDate/60/60/24);
        
        if (daysSinceDate >= 14)
        {
            // x weeks ago
            NSUInteger weeksSinceDate = (NSUInteger)(timeSinceDate/60/60/24/7);
            
            if (weeksSinceDate >= 52)
            {
                NSUInteger yearsSinceDate = (NSUInteger)(timeSinceDate/60/60/24/7/52);
                return [[NSString alloc] initWithFormat:@"%luy", (unsigned long)yearsSinceDate];
            }
            else
            {
                return [[NSString alloc] initWithFormat:@"%luw", (unsigned long)weeksSinceDate];
            }
        }
        else
        {
            return [[NSString alloc] initWithFormat:@"%lud", (unsigned long)daysSinceDate];
        }
    }
}

@end
