//
//  RAPSubredditWebServices.h
//  redditAPI
//
//  Created by Woudini on 2/28/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DoThingsAfterLoadingSubredditBlock)(id jsonData);

@interface RAPSubredditWebServices : NSObject

-(id)initWithSubredditString:(NSString *)subredditString withHandlerBlock:(DoThingsAfterLoadingSubredditBlock)aHandlerBlock;

@end
