//
//  RAPTiltToScrollViewController.m
//  redditAPI
//
//  Created by Woudini on 2/14/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "RAPTiltToScrollViewController.h"

#define RAPSelectRowNotification @"RAPSelectRowNotification"
#define RAPCreateRectSelectorNotification @"RAPCreateRectSelectorNotification"
#define RAPTableViewShouldAdjustToNearestRowAtIndexPathNotification @"RAPTableViewShouldAdjustToNearestRowAtIndexPathNotification"
#define RAPRemoveRectSelectorNotification @"RAPRemoveRectSelectorNotification"
#define RAPSegueNotification @"RAPSegueNotification"
#define RAPSegueBackNotification @"RAPSegueBackNotification"
#define RAPGetRectSelectorShapesNotification @"RAPGetRectSelectorShapesNotification"

@interface RAPTiltToScrollViewController ()
@property (nonatomic) RAPTiltToScroll *tiltToScroll;
@property (nonatomic) CGRect tableViewCellRect;
@property (nonatomic) CGRect defaultCellRect;
@property (nonatomic) UIActivityIndicatorView *spinner;
@property (nonatomic) NSTimer *timerToPreventSegueingBackTooQuickly;
@property (nonatomic) int timeViewHasBeenVisibleInt;
@property (nonatomic) BOOL isInWebView;
@property (nonatomic) UIWebView *webView;
@property (nonatomic) NSMutableArray *cellRectSizeArray;
@property (nonatomic) BOOL spinnerIsStopped;

@end

@implementation RAPTiltToScrollViewController

-(RAPTiltToScroll *)tiltToScroll
{
    if (!_tiltToScroll) _tiltToScroll = [[RAPTiltToScroll alloc] init];
    return _tiltToScroll;
}

-(void)createTableViewCellRectWithCellRect:(CGRect)cellRect
{
    // Need to get the frame we will use for the rect selector
    if (CGRectIsEmpty(self.tableViewCellRect))
    {
        self.defaultCellRect = cellRect;
        self.tableViewCellRect = CGRectMake(cellRect.origin.x, cellRect.origin.y+self.navigationController.navigationBar.frame.size.height+[self statusBarHeight], cellRect.size.width, cellRect.size.height);
        [self addObserverForRectSelector];
    }
}

#pragma mark Segue

-(void)timeViewHasBeenVisible
{
    if (self.timeViewHasBeenVisibleInt < 15)
    {
        self.timeViewHasBeenVisibleInt++;
    }
    else if (self.timeViewHasBeenVisibleInt >= 15)
    {
        [self.timerToPreventSegueingBackTooQuickly invalidate];
    }
    //NSLog(@"Timeviewhasbeenvisible:%d", self.timeViewHasBeenVisibleInt);
}

-(void)segueBack
{
    if (self.navigationController.navigationBar.backItem && self.timeViewHasBeenVisibleInt >= 15)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:RAPSegueBackNotification object:self.tiltToScroll];
        [self.tiltToScroll segueSuccessful];
        self.navigationController.navigationBar.alpha = 1;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark TiltToScroll Delegate Method

-(void)adjustTableView
{
    // This method is needed to scroll the tableview to show entire cells when the user stops scrolling; That way no half, quarter, or other portion of a cell is missing and the rectangle selector will be hovering over only one cell
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RAPTableViewShouldAdjustToNearestRowAtIndexPathNotification object:self.tiltToScroll];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:[[self.tableView visibleCells] firstObject]];
    //NSLog(@"IndexPath is %d", indexPath.row);
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    NSLog(@"startfill");
    [self fillCellRectSizeArrayWithVisibleCells];
}

-(void)addObserverForAdjustToNearestRowNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustTableView) name:RAPTableViewShouldAdjustToNearestRowAtIndexPathNotification object:self.tiltToScroll];
}

#pragma mark View methods

-(UIScrollView *)appropriateScrollView
{
    return self.isInWebView ? self.webView.scrollView : self.tableView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fillCellRectSizeArrayWithVisibleCells) name:RAPGetRectSelectorShapesNotification object:nil];
    self.cellRectSizeArray = [[NSMutableArray alloc] init];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tiltToScroll.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tiltToScroll startTiltToScrollWithSensitivity:1 forScrollView:[self appropriateScrollView] inWebView:self.isInWebView];
    [self addObserverForRectSelector];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(segueBack) name:RAPSegueBackNotification object:nil];
    self.timeViewHasBeenVisibleInt = 0;
    self.timerToPreventSegueingBackTooQuickly = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timeViewHasBeenVisible) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Tilt detection must be separate for each VC due to overreactivity with segues
    
    [super viewWillDisappear:animated];
    
    [self.tiltToScroll stopTiltToScroll];
    
    [self removeRectSelector];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:RAPSelectRowNotification object:self.tiltToScroll];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RAPTableViewShouldAdjustToNearestRowAtIndexPathNotification object:self.tiltToScroll];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RAPCreateRectSelectorNotification object:self.tiltToScroll];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RAPRemoveRectSelectorNotification object:self.tiltToScroll];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RAPSegueNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RAPSegueBackNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RAPGetRectSelectorShapesNotification object:nil];
    
    [self.timerToPreventSegueingBackTooQuickly invalidate];
}


#pragma mark Rectangle Selector methods

-(void)fillCellRectSizeArrayWithVisibleCells
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RAPGetRectSelectorShapesNotification object:nil];
    
    [self.cellRectSizeArray removeAllObjects];
    
    for (UITableViewCell *cell in [self.tableView visibleCells])
    {
        [self.cellRectSizeArray addObject:[NSValue valueWithCGRect:[self.tableView rectForRowAtIndexPath:[self.tableView indexPathForCell:cell]]]];
    }
    NSLog(@"added rects");
}

-(void)userSelectedRow
{
    NSLog(@"User selected row");
    NSLog(@"Superclass: Originselected is %@", NSStringFromCGPoint(self.rectangleSelector.currentLocationRect.origin));
    if (!self.spinner.isAnimating && self.timeViewHasBeenVisibleInt >= 15 && self.rectSelectorHasBeenMade)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:RAPSelectRowNotification object:self.tiltToScroll];
        [[NSNotificationCenter defaultCenter] postNotificationName:RAPSegueNotification object:nil];
    }
}

-(void)stopTiltToScrollAndRemoveRectSelector
{
    [self.tiltToScroll stopTiltToScroll];
    [self removeRectSelector];
}

-(float)statusBarHeight
{
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    return MIN(statusBarSize.width, statusBarSize.height);
}

- (void)createRectSelectorAtTop:(BOOL)atTop inWebView:(BOOL)isInWebView
{
    if (!self.rectSelectorHasBeenMade && [self.cellRectSizeArray count] > 0)
    {
        NSLog(@"let's make a rect selector");
        //NSLog(@"atTop in createRect method is %d", atTop);
        
        if (!atTop && !isInWebView)
        {
            // Bottom of screen
            CGRect tempRect = [[self.cellRectSizeArray lastObject] CGRectValue];
            self.tableViewCellRect = CGRectMake(0, self.view.frame.size.height-tempRect.size.height, tempRect.size.width, tempRect.size.height);
        }
        else if (atTop)
        {
            // Top of screen
            CGRect tempRect = [[self.cellRectSizeArray objectAtIndex:0] CGRectValue];
            self.tableViewCellRect = CGRectMake(0, self.navigationController.navigationBar.frame.size.height+[self statusBarHeight], tempRect.size.width, tempRect.size.height);
            NSLog(@"self.tableviewcellrect is %@", NSStringFromCGRect(self.tableViewCellRect));
        }
        
        CGRect toolbarRect = CGRectMake(self.navigationController.toolbar.frame.origin.x, self.navigationController.toolbar.frame.origin.y-self.navigationController.toolbar.frame.size.height, self.navigationController.toolbar.frame.size.width, self.navigationController.toolbar.frame.size.height);
        
        self.rectangleSelector = [[RAPRectangleSelector alloc] initWithFramesMutableArray:self.cellRectSizeArray atTop:atTop withCellMax:[[self.tableView visibleCells] count]-1 inWebView:isInWebView inInitialFrame:self.tableViewCellRect withToolbarRect:toolbarRect];
        
        //NSLog(@"Toolbarframe is %@", NSStringFromCGRect(self.navigationController.toolbar.frame));
        //NSLog(@"bounds of screen is %@", NSStringFromCGRect(self.view.bounds));
        //NSLog(@"Cellmax is %d", self.rectangleSelector.cellMax);
        
        self.rectangleSelector.statusBarPlusNavigationBarHeight = self.navigationController.navigationBar.frame.size.height+[self statusBarHeight];
    }
    
    if (isInWebView)
    {
        self.rectangleSelector = [[RAPRectangleSelector alloc] initWithFramesMutableArray:nil atTop:atTop withCellMax:1 inWebView:isInWebView inInitialFrame:self.navigationController.navigationBar.frame withToolbarRect:CGRectZero];
        self.navigationController.navigationBar.alpha = 0.5;
    }
        self.rectangleSelector.tag = 999;
        [self.view addSubview:self.rectangleSelector];
        [self.view bringSubviewToFront:self.rectangleSelector];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userSelectedRow) name:RAPSelectRowNotification object:self.tiltToScroll];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeRectSelector) name:RAPRemoveRectSelectorNotification object:self.tiltToScroll];
        self.rectSelectorHasBeenMade = YES;
    
    
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
    [self.rectangleSelector.rectsMutableArray removeAllObjects];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RAPSelectRowNotification object:self.tiltToScroll];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RAPRemoveRectSelectorNotification object:self.tiltToScroll];
    [self addObserverForRectSelector];
    self.rectSelectorHasBeenMade = NO;
}

-(void)addObserverForRectSelector
{
    [[NSNotificationCenter defaultCenter] addObserverForName:RAPCreateRectSelectorNotification object:self.tiltToScroll queue:nil usingBlock:^(NSNotification *note)
     {
         [[NSNotificationCenter defaultCenter] removeObserver:self name:RAPCreateRectSelectorNotification object:self.tiltToScroll];
         [self createRectSelectorAtTop:[[note.userInfo objectForKey:@"atTop"] boolValue] inWebView:[[note.userInfo objectForKey:@"inWebView"] boolValue]];
         //NSLog(@"atTop notification is %d", [[note.userInfo objectForKey:@"atTop"] boolValue]);
     }];
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
