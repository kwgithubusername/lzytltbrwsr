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

@interface RAPTiltToScrollViewController ()
@property (nonatomic) RAPTiltToScroll *tiltToScroll;
@property (nonatomic) CGRect tableViewCellRect;
@property (nonatomic) BOOL rectSelectorHasBeenMade;
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
        self.tableViewCellRect = CGRectMake(cellRect.origin.x, cellRect.origin.y+self.navigationController.navigationBar.frame.size.height+[self statusBarHeight], cellRect.size.width, cellRect.size.height);
        [self addObserverForRectSelector];
    }
}

#pragma mark Segue

-(void)segueBack
{
    if (self.navigationController.navigationBar.backItem)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:RAPSegueBackNotification object:self.tiltToScroll];
        [self.tiltToScroll segueSuccessful];
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
}

-(void)addObserverForAdjustToNearestRowNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustTableView) name:RAPTableViewShouldAdjustToNearestRowAtIndexPathNotification object:self.tiltToScroll];
}

#pragma mark View methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tiltToScroll.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tiltToScroll startTiltToScrollWithSensitivity:1 forScrollView:self.tableView];
    [self addObserverForRectSelector];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(segueBack) name:RAPSegueBackNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Tilt detection must be separate for each VC due to overreactivity with segues
    
    [self.tiltToScroll stopTiltToScroll];
    
    for (UIView *view in self.view.subviews)
    {
        if (view.tag == 999)
        {
            [view removeFromSuperview];
        }
    }
    [self.rectangleSelector reset];
    self.rectSelectorHasBeenMade = NO;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:RAPSelectRowNotification object:self.tiltToScroll];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RAPTableViewShouldAdjustToNearestRowAtIndexPathNotification object:self.tiltToScroll];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RAPCreateRectSelectorNotification object:self.tiltToScroll];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RAPRemoveRectSelectorNotification object:self.tiltToScroll];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RAPSegueNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RAPSegueBackNotification object:nil];
}


#pragma mark Rectangle Selector methods

-(void)userSelectedRow
{
    NSLog(@"User selected row");
    
    NSLog(@"Superclass: Originselected is %@", NSStringFromCGPoint(self.rectangleSelector.currentLocationRect.origin));
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RAPSelectRowNotification object:self.tiltToScroll];
    [[NSNotificationCenter defaultCenter] postNotificationName:RAPSegueNotification object:nil];
    [self.tiltToScroll stopTiltToScroll];
    [self removeRectSelector];
}

-(float)statusBarHeight
{
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    return MIN(statusBarSize.width, statusBarSize.height);
}

- (void)createRectSelectorAtTop:(BOOL)atTop
{
    if (!self.rectSelectorHasBeenMade)
    {
        NSLog(@"let's make a rect selector");
        self.rectangleSelector = [[RAPRectangleSelector alloc] initWithFrame:self.tableViewCellRect atTop:atTop];
        self.rectangleSelector.cellMax = (int)[[self.tableView visibleCells] count]-1;
        NSLog(@"Cellmax is %d", self.rectangleSelector.cellMax);
        self.rectangleSelector.incrementCGFloat = self.tableViewCellRect.size.height;
        NSLog(@"CGIncrement is %f", self.rectangleSelector.incrementCGFloat);
        self.rectangleSelector.tag = 999;
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
         [self createRectSelectorAtTop:[[note.userInfo objectForKey:@"atTop"] boolValue]];
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
