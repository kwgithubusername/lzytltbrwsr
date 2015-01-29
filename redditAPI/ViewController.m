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
#import <CoreMotion/CoreMotion.h>
@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSArray *results;
@property (nonatomic) CMMotionManager *motionManager;

@end

@implementation ViewController

-(CMMotionManager *)motionManager
{
    if (!_motionManager)
    {
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.deviceMotionUpdateInterval = 5.0 / 60.0;
    }
    return _motionManager;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goToDetail"])
    {
        
    }
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.results count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *redditEntry = [[NSMutableDictionary alloc] initWithDictionary:self.results[indexPath.row]];
    RAPTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.label.text = [redditEntry[@"data"] objectForKey:@"title"];
    cell.subLabel.text = [redditEntry[@"data"] objectForKey:@"author"];
    return cell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *url = [NSURL URLWithString:@"http://www.reddit.com/.json"];
    NSURLSessionConfiguration *sessionconfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionconfig];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        NSMutableDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        NSArray *jsonResults = [[NSArray alloc] initWithArray:[jsonData[@"data"] objectForKey:@"children"]];
        NSLog(@"Results are %@", jsonResults);
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            self.results = [[NSArray alloc] initWithArray:jsonResults];
            [self.tableView reloadData];
        });
    }];
    
    [dataTask resume];
    
    [self setupTiltToScrollTableView];
    // Do any additional setup after loading the view, typically from a nib.
}


-(void)setupTiltToScrollTableView
{

    [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical toQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *motion, NSError *error)
    {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                CGFloat tiltAngle = [self angleInDegreesUsingX:motion.gravity.x AndY:motion.gravity.y];
                CGFloat z = motion.gravity.z;
            if (tiltAngle > 45)
            {
                NSLog(@"Tilted 45 degrees clockwise");
            }
            else if (tiltAngle < -45)
            {
                NSLog(@"Tilted 45 degrees counterclockwise");
            }
    }];

    }];
}

-(CGFloat)angleInDegreesUsingX:(CGFloat)xPosition AndY:(CGFloat)yPosition
{
    CGFloat angle = atan2(yPosition, xPosition) + M_PI_2;
    return angle * 180.0f / M_PI;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
