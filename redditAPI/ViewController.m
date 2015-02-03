//
//  ViewController.m
//  redditAPI
//
//  Created by Woudini on 1/13/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "ViewController.h"
#import "RAPTableViewCell.h"
#import "TableViewController.h"
#import "RAPapi.h"
#import "RAPSelectorView.h"
#import <CoreMotion/CoreMotion.h>
@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *resultsMutableArray;
@property (nonatomic) CMMotionManager *motionManager;
@property (nonatomic) RAPapi *api;
@property (nonatomic) RAPSelectorView *RAPRectangleSelectorView;
@property (nonatomic) CGRect cellFrame;
@property (nonatomic) BOOL cellFrameSet;
@property (nonatomic) CGRect referenceCGRectForScrolling;
@property (nonatomic) BOOL IsReferenceCGRectForScrollingSet;
@property (nonatomic) CGFloat lastContentOffset;

@end

@implementation ViewController

-(RAPapi *)api
{
    if (!_api) _api = [[RAPapi alloc] init];
    return _api;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goToDetail"])
    {
        
    }
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.resultsMutableArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *redditEntry = [[NSMutableDictionary alloc] initWithDictionary:self.resultsMutableArray[indexPath.row]];
    RAPTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.label.text = [redditEntry[@"data"] objectForKey:@"title"];
    cell.subLabel.text = [redditEntry[@"data"] objectForKey:@"author"];
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.cellFrameSet)
    {
        self.cellFrame = cell.frame;
        self.cellFrameSet = YES;
    }
    if (indexPath.row == [self.resultsMutableArray count]-2)
    {
        NSMutableDictionary *redditEntry = [[NSMutableDictionary alloc] initWithDictionary:self.resultsMutableArray[indexPath.row+1]];
        NSString *linkIDString = [[NSString alloc] initWithFormat:@"%@", [redditEntry[@"data"] objectForKey:@"id"]];
        [self loadRedditJSONWithAppendingString:[[NSString alloc] initWithFormat:@"?limit=10?&after=t3_%@", linkIDString]];
    }
}

#pragma mark Setup and NSURLSession

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.resultsMutableArray = [[NSMutableArray alloc] init];
    
    [self loadRedditJSONWithAppendingString:@""];
    
    [self setupTiltToScrollTableView];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)loadRedditJSONWithAppendingString:(NSString *)appendString
{
    NSURL *url = [NSURL URLWithString:[[NSString alloc] initWithFormat:@"http://www.reddit.com/.json%@", appendString]];
    NSURLSessionConfiguration *sessionconfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionconfig];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          NSMutableDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                                          NSArray *jsonResults = [[NSArray alloc] initWithArray:[jsonData[@"data"] objectForKey:@"children"]];
                                          //NSLog(@"Results are %@", jsonResults);
                                          
                                          dispatch_async(dispatch_get_main_queue(), ^
                                                         {
                                                             [self.resultsMutableArray addObjectsFromArray:jsonResults];
                                                             [self.tableView reloadData];
                                                         });
                                      }];
    
    [dataTask resume];
}

#pragma mark Scrolling

-(void)scrollTableViewWithIntensityOfAnglesLeftOrRight:(CGFloat)leftOrRightAngle ForwardOrBackward:(CGFloat)forwardOrBackwardAngle
{
    if (leftOrRightAngle > 10)
    {
        //NSLog(@"Tilted %f degrees clockwise", leftOrRightAngle);
        [self scrollTableViewDownWithCGFloatIntensity:leftOrRightAngle];
    }
    else if (leftOrRightAngle < -10)
    {
        //NSLog(@"Tilted %f degrees counterclockwise", leftOrRightAngle);
        [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForRowAtPoint:CGPointMake(0,0)] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    if (forwardOrBackwardAngle > 10)
    {
        //NSLog(@"Tilted %f degrees forward", forwardOrBackwardAngle);
    }
    else if (forwardOrBackwardAngle < -10)
    {
        //NSLog(@"Tilted %f degrees backward", forwardOrBackwardAngle);
    }
}

-(void)scrollTableViewDownWithCGFloatIntensity:(CGFloat)intensity
{
    if (!self.IsReferenceCGRectForScrollingSet)
    {
        self.referenceCGRectForScrolling = CGRectMake(0, self.tableView.bounds.size.height, 1, self.cellFrame.size.height);
        self.IsReferenceCGRectForScrollingSet = YES;
    }
    
    //NSLog(@"ContentInset.height is %@", self.tableView.contentInset);
    //NSLog(@"ContentOffset.height is %@", self.tableView.contentOffset);
    
    [self.tableView flashScrollIndicators];
    
    [self.tableView scrollRectToVisible:self.referenceCGRectForScrolling animated:YES];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.lastContentOffset > scrollView.contentOffset.y)
    {
        [self maintainFixedPositionOfScrollRectInDirectionDown:NO];
    }
    else if (self.lastContentOffset < scrollView.contentOffset.y)
    {
        [self maintainFixedPositionOfScrollRectInDirectionDown:YES];
    }
    self.lastContentOffset = scrollView.contentOffset.y;

}

- (void)maintainFixedPositionOfScrollRectInDirectionDown:(BOOL)isDown
{
    CGRect fixedFrame = self.referenceCGRectForScrolling;
    int i = -1;
    if (isDown)
    {
        i = 1;
    }
    fixedFrame.origin.y = fixedFrame.origin.y + i;
    self.referenceCGRectForScrolling = fixedFrame;
    NSLog(@"FixedFrame.y is %f", self.referenceCGRectForScrolling.origin.y);
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];
    
    if(translation.y > 0)
    {

        // react to dragging right
    } else
        
    {
        // react to dragging left
    }
}

#pragma mark Motion Manager

-(CMMotionManager *)motionManager
{
    if (!_motionManager)
    {
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.deviceMotionUpdateInterval = 5.0 / 60.0;
    }
    return _motionManager;
}

-(BOOL)deviceIsInLandscape
{
    return self.view.frame.size.width == ([[UIScreen mainScreen] bounds].size.width*([[UIScreen mainScreen] bounds].size.width<[[UIScreen mainScreen] bounds].size.height))+([[UIScreen mainScreen] bounds].size.height*([[UIScreen mainScreen] bounds].size.width>[[UIScreen mainScreen] bounds].size.height)) ? NO : YES;
}

-(void)setupTiltToScrollTableView
{

    [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical toQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *motion, NSError *error)
    {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                CGFloat tiltAngleLeftOrRight = [self LeftOrRightAngleInDegreesUsingXGravity:motion.gravity.x YGravity:motion.gravity.y andZGravity:motion.gravity.z];
                CGFloat tiltAngleForwardorBackward = [self ForwardOrBackwardAngleInDegreesUsingXGravity:motion.gravity.x YGravity:motion.gravity.y andZGravity:motion.gravity.z];

                [self scrollTableViewWithIntensityOfAnglesLeftOrRight:tiltAngleLeftOrRight ForwardOrBackward:tiltAngleForwardorBackward];
    }];

    }];
}

-(CGFloat)LeftOrRightAngleInDegreesUsingXGravity:(CGFloat)xGravity YGravity:(CGFloat)yGravity andZGravity:(CGFloat)zGravity
{
    CGFloat angle = 0;

    switch ([[UIDevice currentDevice] orientation])
    {
        case UIDeviceOrientationLandscapeLeft:
        {
            angle = atan2(xGravity, -yGravity);
            break;
        }
        case UIDeviceOrientationLandscapeRight:
        {
            angle = atan2(-xGravity, yGravity);
            break;
        }
        case UIDeviceOrientationPortrait:
        {
            angle = atan2(yGravity, xGravity);
            break;
        }
        case UIDeviceOrientationPortraitUpsideDown:
        {
            angle = atan2(-yGravity, -xGravity);
            break;
        }
        case UIDeviceOrientationFaceUp:
        {
            break;
        }
        case UIDeviceOrientationFaceDown:
        {
            break;
        }
        case UIDeviceOrientationUnknown:
        {
            break;
        }
    }
    CGFloat angleToReturn = (angle + M_PI_2) * 180.0f / M_PI;
    return angleToReturn;
}

-(CGFloat)ForwardOrBackwardAngleInDegreesUsingXGravity:(CGFloat)xGravity YGravity:(CGFloat)yGravity andZGravity:(CGFloat)zGravity
{
    CGFloat angle = 0;
    switch ([[UIDevice currentDevice] orientation])
    {
        case UIDeviceOrientationLandscapeLeft:
        {
            angle = atan2(xGravity, zGravity);
            break;
        }
        case UIDeviceOrientationLandscapeRight:
        {
            angle = atan2(-xGravity, zGravity);
            break;
        }
        case UIDeviceOrientationPortrait:
        {
            angle = atan2(yGravity, zGravity);
            break;
        }
        case UIDeviceOrientationPortraitUpsideDown:
        {
            angle = atan2(-yGravity, zGravity);
        }
        case UIDeviceOrientationFaceUp:
        {
            break;
        }
        case UIDeviceOrientationFaceDown:
        {
            break;
        }
        case UIDeviceOrientationUnknown:
        {
            break;
        }
    }
    CGFloat angleToReturn = (angle + M_PI_2) * 180.0f / M_PI;
    return angleToReturn;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
