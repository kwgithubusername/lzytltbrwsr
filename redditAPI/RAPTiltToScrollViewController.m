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
#define RAPFinalRowLoadedNotification @"RAPFinalRowLoadedNotification"


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
@property (nonatomic) NSMutableArray *cellRectSizeArrayWithLastRowVisible;
@property (nonatomic) BOOL spinnerIsStopped;

@end

@implementation RAPTiltToScrollViewController

-(RAPTiltToScroll *)tiltToScroll
{
    if (!_tiltToScroll) _tiltToScroll = [[RAPTiltToScroll alloc] init];
    return _tiltToScroll;
}

#pragma mark Calibration

-(void)calibrate
{
    [self calibrateTiltButtonTapped:nil];
}

- (IBAction)calibrateTiltButtonTapped:(UIBarButtonItem *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hold device at a comfortable angle" message:@"Tilt mechanism will auto-calibrate in 3 seconds" delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    [alertView show];
    self.tiltToScroll.isCalibrating = YES;
    [self performSelector:@selector(dismissAlertView:) withObject:alertView afterDelay:3];
}

-(void)dismissAlertView:(UIAlertView *)alertView
{
    self.tiltToScroll.hasCalibrated = YES;
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

#pragma mark Segue

-(void)timeViewHasBeenVisible
{
    if (self.timeViewHasBeenVisibleInt < 25)
    {
        self.timeViewHasBeenVisibleInt++;
    }
    else if (self.timeViewHasBeenVisibleInt >= 25)
    {
        [self.timerToPreventSegueingBackTooQuickly invalidate];
    }
    //NSLog(@"Timeviewhasbeenvisible:%d", self.timeViewHasBeenVisibleInt);
}

-(void)segueBack
{
    if (self.navigationController.navigationBar.backItem && self.timeViewHasBeenVisibleInt >= 25)
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
    NSLog(@"IndexPath is %ld", (long)indexPath.row);
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    NSLog(@"startfill");
    [self fillCellRectSizeArrayWithVisibleCells];
}

-(void)addObserverForAdjustToNearestRowNotification
{
    NSLog(@"observerforadjusttonearestrowadded");
    // delegate method- must be called when scrolling session has started
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustTableView) name:RAPGetRectSelectorShapesNotification object:nil];
    self.cellRectSizeArray = [[NSMutableArray alloc] init];
    self.cellRectSizeArrayWithLastRowVisible = [[NSMutableArray alloc] init];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tiltToScroll.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tiltToScroll startTiltToScrollWithSensitivity:1 forScrollView:[self appropriateScrollView] inWebView:self.isInWebView];
    [self addObserverForRectSelector];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(countFinalRowsThatAreVisible) name:RAPFinalRowLoadedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(segueBack) name:RAPSegueBackNotification object:nil];
    self.timeViewHasBeenVisibleInt = 0;
    self.timerToPreventSegueingBackTooQuickly = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(timeViewHasBeenVisible) userInfo:nil repeats:YES];
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

-(void)countFinalRowsThatAreVisible
{
    [self.cellRectSizeArrayWithLastRowVisible removeAllObjects];
    
    for (UITableViewCell *cell in [self.tableView visibleCells])
    {
        // Need to increment visible cells by 1;
        [self.cellRectSizeArrayWithLastRowVisible addObject:[NSValue valueWithCGRect:[self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.tableView indexPathForCell:cell].row+1 inSection:0]]]];
        NSLog(@"adding cell with indexPath %ld", (long)[self.tableView indexPathForCell:cell].row+1);
    }
    
}

-(void)fillCellRectSizeArrayWithVisibleCells
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RAPGetRectSelectorShapesNotification object:nil];
    
    [self.cellRectSizeArray removeAllObjects];
    
    if ([self.tableView indexPathForCell:[[self.tableView visibleCells] lastObject]].row != [self.tableView numberOfRowsInSection:0]-1)
    {
        for (UITableViewCell *cell in [self.tableView visibleCells])
        {
            [self.cellRectSizeArray addObject:[NSValue valueWithCGRect:[self.tableView rectForRowAtIndexPath:[self.tableView indexPathForCell:cell]]]];
            //NSLog(@"adding cell with indexPath %ld", (long)[self.tableView indexPathForCell:cell].row);
        }
    }
    else
    {
        [self.cellRectSizeArray addObjectsFromArray:self.cellRectSizeArrayWithLastRowVisible];
    }
    
    //NSLog(@"added rects");
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
    if (!self.rectSelectorHasBeenMade && [self.cellRectSizeArray count] > 0 && !isInWebView && self.timeViewHasBeenVisibleInt >= 5)
    {
        NSLog(@"let's make a rect selector");
        //NSLog(@"atTop in createRect method is %d", atTop);
        
        if (!atTop)
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
        
        int cellMax = (int)[[self.tableView visibleCells] count]-1;
        
        self.rectangleSelector = [[RAPRectangleSelector alloc] initWithFramesMutableArray:self.cellRectSizeArray atTop:atTop withCellMax:cellMax inWebView:isInWebView inInitialFrame:self.tableViewCellRect withToolbarRect:toolbarRect];
        
        //NSLog(@"Toolbarframe is %@", NSStringFromCGRect(self.navigationController.toolbar.frame));
        //NSLog(@"bounds of screen is %@", NSStringFromCGRect(self.view.bounds));
        //NSLog(@"Cellmax is %d", self.rectangleSelector.cellMax);
        
        self.rectangleSelector.statusBarPlusNavigationBarHeight = self.navigationController.navigationBar.frame.size.height+[self statusBarHeight];
        self.rectangleSelector.currentContentOffset = self.tableView.contentOffset.y;
        NSLog(@"contentoffset for rect is %f", self.tableView.contentOffset.y);
        self.rectangleSelector.tag = 999;
        
        //Boilerplate
        [self.view addSubview:self.rectangleSelector];
        [self.view bringSubviewToFront:self.rectangleSelector];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userSelectedRow) name:RAPSelectRowNotification object:self.tiltToScroll];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeRectSelector) name:RAPRemoveRectSelectorNotification object:self.tiltToScroll];
        self.rectSelectorHasBeenMade = YES;
    }
    
    else if (isInWebView && self.timeViewHasBeenVisibleInt >= 5)
    {
        NSLog(@"self.tableviewcellrect is %@", NSStringFromCGRect(self.tableViewCellRect));
        self.rectangleSelector = [[RAPRectangleSelector alloc] initWithFramesMutableArray:nil atTop:atTop withCellMax:1 inWebView:isInWebView inInitialFrame:self.navigationController.navigationBar.frame withToolbarRect:CGRectZero];
        self.navigationController.navigationBar.alpha = 0.5;
        self.rectangleSelector.tag = 999;
        
        //Boilerplate
        [self.view addSubview:self.rectangleSelector];
        [self.view bringSubviewToFront:self.rectangleSelector];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userSelectedRow) name:RAPSelectRowNotification object:self.tiltToScroll];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeRectSelector) name:RAPRemoveRectSelectorNotification object:self.tiltToScroll];
        self.rectSelectorHasBeenMade = YES;
    }
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

@end