//
//  RAPSubredditWebServices.h
//  redditAPI
//
//  Created by Woudini on 2/28/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import <UIImageView+AFNetworking.h>
#import "RAPTableViewCell.h"
typedef void (^DoThingsAfterLoadingSubredditBlock)(id jsonData);
typedef void (^DoThingsAfterLoadingImagesBlock)(UIImage *image);

@interface RAPSubredditWebServices : NSObject
@property (nonatomic, copy) DoThingsAfterLoadingImagesBlock anImageHandlerBlock;

-(id)initWithSubredditString:(NSString *)subredditString withHandlerBlock:(DoThingsAfterLoadingSubredditBlock)aHandlerBlock;
-(void)loadImageIntoCell:(RAPTableViewCell *)cell withURLString:(NSString *)URLString;

@end
