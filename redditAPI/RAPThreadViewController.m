//
//  RAPThreadViewController.m
//  redditAPI
//
//  Created by Woudini on 2/4/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "RAPThreadViewController.h"
#import "RAPThreadTopicTableViewCell.h"
#import "RAPThreadCommentTableViewCell.h"

@interface RAPThreadViewController ()
@property (nonatomic) NSMutableArray *resultsMutableArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation RAPThreadViewController

- (void)loadRedditJSONWithAppendingString:(NSString *)appendString
{
    NSURL *url = [NSURL URLWithString:[[NSString alloc] initWithFormat:@"http://www.reddit.com/%@", appendString]];
    NSURLSessionConfiguration *sessionconfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionconfig];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          NSMutableArray *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                                          NSLog(@"Results are %@", jsonData);
                                          NSLog(@"JSONdata is %@", [jsonData firstObject][@"data"]);
                                          //NSArray *jsonResults = [[NSArray alloc] initWithArray:[jsonData];
                                          //NSString *string = [[NSString alloc] initWithString:[jsonData firstObject][@"data"][@"selftext"] ];
                                          //NSLog(@"string is %@", string);
                                          dispatch_async(dispatch_get_main_queue(), ^
                                                         {
                                                             [self.resultsMutableArray addObjectsFromArray:jsonResults];
//                                                             [self.tableView reloadData];
                                                         });
                                      }];
    
    [dataTask resume];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"permalinkis = %@", self.permalinkURLString);
    self.resultsMutableArray = [[NSMutableArray alloc] init];
    [self loadRedditJSONWithAppendingString:self.permalinkURLString];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
