//
//  RAPFavoritesViewController.m
//  redditAPI
//
//  Created by Woudini on 2/3/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "RAPFavoritesViewController.h"
#import "ViewController.h"
#import "RAPRectangleReferenceForAdjustingScrollView.h"
#import "RAPRectangleSelector.h"

#define RAPSelectRowNotification @"RAPSelectRowNotification"
#define RAPCreateRectSelectorNotification @"RAPCreateRectSelectorNotification"
#define RAPTableViewShouldAdjustToNearestRowAtIndexPathNotification @"RAPTableViewShouldAdjustToNearestRowAtIndexPathNotification"
#define RAPRemoveRectSelectorNotification @"RAPRemoveRectSelectorNotification"

@interface RAPFavoritesViewController ()
@property (nonatomic) NSMutableArray *favoritesMutableArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) RAPTiltToScroll *tiltToScroll;
@property (nonatomic) CGRect tableViewCellRect;
@property (nonatomic) RAPRectangleSelector *rectangleSelector;
@property (nonatomic) RAPRectangleReferenceForAdjustingScrollView *rectangleReference;

@end

@implementation RAPFavoritesViewController

-(RAPTiltToScroll *)tiltToScroll
{
    if (!_tiltToScroll) _tiltToScroll = [[RAPTiltToScroll alloc] init];
    return _tiltToScroll;
}

#pragma mark Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"subredditSegue"])
    {
        RAPViewController *subredditViewController = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSString *subredditString = self.favoritesMutableArray[indexPath.row];
        subredditViewController.subRedditURLString = subredditString;
    }
}

#pragma mark Adding subreddits

- (IBAction)addFavoriteButtonTapped:(UIBarButtonItem *)sender
{
    [self addSubreddit];
}

-(void)addSubreddit
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Add subreddit" message:@"reddit.com/r/" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = 100;
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag)
    {
        case 100:
        {
            if (buttonIndex == 1)
            {
                UITextField *subredditToAddTextField = [alertView textFieldAtIndex:0];
                NSString *subredditToAddString = [subredditToAddTextField.text lowercaseString];
                if (subredditToAddString.length > 0)
                {
                    [self verifySubredditWithString:subredditToAddString];
                }
                else
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Blank entry" message:@"Please enter a subreddit" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    alertView.tag = 101;
                    [alertView show];
                }
            }
            break;
        }
        case 101:
        {
            [self addSubreddit];
            break;
        }
        case 404:
        {
            [self addSubreddit];
            break;
        }
    }
}

-(void)alertUserThatSubredditCannotBeFound
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid subreddit" message:@"Please enter a valid subreddit" delegate:self cancelButtonTitle:nil otherButtonTitles: @"OK", nil];
    alertView.tag = 404;
    [alertView show];
}

-(void)verifySubredditWithString:(NSString *)appendString
{
    NSURL *url = [NSURL URLWithString:[[NSString alloc] initWithFormat:@"http://www.reddit.com/r/%@/.json", appendString]];
    NSURLSessionConfiguration *sessionconfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionconfig];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          NSMutableDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                                          NSSet *jsonResults = [[NSSet alloc] initWithArray:[jsonData[@"data"] objectForKey:@"children"]];
                                          NSLog(@"Subreddit is %@", jsonData);
                                          
                                          dispatch_async(dispatch_get_main_queue(), ^
                                                         {
                                                             if ([jsonResults count] == 0)
                                                             {
                                                                 NSLog(@"subreddit not found");
                                                                 [self alertUserThatSubredditCannotBeFound];
                                                             }
                                                             else
                                                             {
                                                                 [self.favoritesMutableArray addObject:appendString];
                                                                 [self.favoritesMutableArray sortUsingSelector:@selector(localizedCompare:)];
                                                                 NSIndexPath *indexPathForWord = [NSIndexPath indexPathForRow:[self.favoritesMutableArray indexOfObject:appendString] inSection:self.tableView.numberOfSections-1];
                                                                 [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPathForWord] withRowAnimation:UITableViewRowAnimationFade];
                                                                 [self updateFavorites];
                                                                 [self.tableView reloadData];
                                                             }
                                                             
                                                         });
                                      }];
    
    [dataTask resume];
}

#pragma mark TiltToScroll Delegate Method

-(void)addObserverForAdjustToNearestRowNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustTableView) name:RAPTableViewShouldAdjustToNearestRowAtIndexPathNotification object:self.tiltToScroll];
}

#pragma mark Table View Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.favoritesMutableArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (CGRectIsEmpty(self.tableViewCellRect))
    {
        CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
        self.tableViewCellRect = CGRectMake(cellRect.origin.x, cellRect.origin.y+self.navigationController.navigationBar.frame.size.height+[self statusBarHeight], cellRect.size.width, cellRect.size.height);
        NSLog(@"Tableviewcellrect is %@", NSStringFromCGRect(self.tableViewCellRect));
        NSLog(@"Frame is %@", NSStringFromCGRect(self.view.frame));
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createRectSelector) name:RAPCreateRectSelectorNotification object:self.tiltToScroll];
    }
    
    UITableViewCell *favoritesCell = [self.tableView dequeueReusableCellWithIdentifier:@"favoritesCell"];
    favoritesCell.textLabel.text = [self.favoritesMutableArray objectAtIndex:indexPath.row];
    return favoritesCell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self.favoritesMutableArray removeObjectAtIndex:indexPath.row];
        [self updateFavorites];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(void)adjustTableView
{
    // This method is needed to scroll the tableview to show entire cells when the user stops scrolling; That way no half, quarter, or other portion of a cell is missing and the rectangle selector will be hovering over only one cell
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RAPTableViewShouldAdjustToNearestRowAtIndexPathNotification object:self.tiltToScroll];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:[[self.tableView visibleCells] firstObject]];
    //NSLog(@"IndexPath is %d", indexPath.row);
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark Favorites methods

-(void)updateFavorites
{
    [[NSUserDefaults standardUserDefaults] setValue:self.favoritesMutableArray forKey:@"favorites"];
}

-(NSArray *)defaultSubredditFavorites
{
    return @[@"adviceanimals",@"announcements",@"askreddit",@"aww",@"blog",@"funny",@"gaming",@"iama",@"pics",@"politics",@"programming",@"science",@"technology",@"todayilearned",@"worldnews"];
}

#pragma mark View methods

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    NSDictionary *defaultFavorites = [NSDictionary dictionaryWithObject:[self defaultSubredditFavorites] forKey:@"favorites"];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultFavorites];
    
    self.favoritesMutableArray = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] valueForKey:@"favorites"]];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tiltToScroll.delegate = self;
    [self.tiltToScroll startTiltToScrollWithSensitivity:1 forScrollView:self.tableView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createRectSelector) name:RAPCreateRectSelectorNotification object:self.tiltToScroll];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Tilt detection must be separate for each VC due to overreactivity with segues
    
    [self.tiltToScroll stopTiltToScroll];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RAPSelectRowNotification object:self.tiltToScroll];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RAPTableViewShouldAdjustToNearestRowAtIndexPathNotification object:self.tiltToScroll];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RAPCreateRectSelectorNotification object:self.tiltToScroll];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RAPRemoveRectSelectorNotification object:self.tiltToScroll];
}

#pragma mark Rect Selector Methods

-(float)statusBarHeight
{
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    return MIN(statusBarSize.width, statusBarSize.height);
}

-(void)userSelectedRow
{
    NSLog(@"User selected row");
    [self performSegueWithIdentifier:@"subredditSegue" sender:nil];
}

-(void)createRectSelector
{
    NSLog(@"let's make a rect selector");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RAPCreateRectSelectorNotification object:self.tiltToScroll];
    self.rectangleSelector = [[RAPRectangleSelector alloc] initWithFrame:self.tableViewCellRect];
    self.rectangleSelector.incrementCGFloat = self.tableViewCellRect.size.height;
    self.rectangleSelector.tag = 999;
    [self.view addSubview:self.rectangleSelector];
    [self.view bringSubviewToFront:self.rectangleSelector];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userSelectedRow) name:RAPSelectRowNotification object:self.tiltToScroll];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeRectSelector) name:RAPRemoveRectSelectorNotification object:self.tiltToScroll];
}

- (void)removeRectSelector
{
    for (UIView *view in self.view.subviews)
    {
        if (view.tag == 999)
        {
            [view removeFromSuperview];
        }
    }
    [self.rectangleSelector reset];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RAPSelectRowNotification object:self.tiltToScroll];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RAPRemoveRectSelectorNotification object:self.tiltToScroll];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createRectSelector) name:RAPCreateRectSelectorNotification object:self.tiltToScroll];
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
