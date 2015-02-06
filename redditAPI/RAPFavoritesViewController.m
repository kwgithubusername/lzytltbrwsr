//
//  RAPFavoritesViewController.m
//  redditAPI
//
//  Created by Woudini on 2/3/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "RAPFavoritesViewController.h"

@interface RAPFavoritesViewController ()
@property (nonatomic) NSArray *favoritesArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation RAPFavoritesViewController

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.favoritesArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *favoritesCell = [self.tableView dequeueReusableCellWithIdentifier:@"favoritesCell"];
    favoritesCell.textLabel.text = [self.favoritesArray objectAtIndex:indexPath.row];
    return favoritesCell;
}

- (IBAction)cancelButtonTapped:(UIBarButtonItem *)sender
{
    //[self dismissViewControllerAnimated:YES completion:nil];
}

-(NSArray *)defaultSubredditFavorites
{
    return @[@"adviceanimals",@"announcements",@"askreddit",@"aww",@"blog",@"funny",@"gaming",@"iama",@"pics",@"politics",@"programming",@"science",@"technology",@"todayilearned",@"worldnews"];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSDictionary *defaultFavorites = [NSDictionary dictionaryWithObject:[self defaultSubredditFavorites] forKey:@"favorites"];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultFavorites];
    
    self.favoritesArray = [[NSArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] valueForKey:@"favorites"]];
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
