//
//  RAPLinkSelectorViewController.m
//  redditAPI
//
//  Created by Woudini on 5/9/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "RAPLinkSelectorViewController.h"
#import "RAPLinkSelectorDataSource.h"
#import "RAPLinkViewController.h"

@interface RAPTiltToScrollViewController()
-(void)adjustTableView;
-(void)turnOffSelectMode;
@end

#define RAPSegueNotification @"RAPSegueNotification"

@interface RAPLinkSelectorViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) RAPLinkSelectorDataSource *dataSource;
@end

@implementation RAPLinkSelectorViewController

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"selectorToLinkSegue"])
    {
        NSIndexPath *indexPath;
        if (![self.tableView indexPathForSelectedRow])
        {
            indexPath = [self.tableView indexPathForCell:[[self.tableView visibleCells] objectAtIndex:super.rectangleSelector.cellIndex]];
            //NSLog(@"Indexpath.row i%ld%d"(long), indexPath.row);
        }
        else // Otherwise, the user has tapped the row, so use the row that was tapped
        {
            indexPath = [self.tableView indexPathForSelectedRow];
            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
        
        RAPLinkViewController *linkViewController = segue.destinationViewController;
        linkViewController.URLstring = [self.URLsArray objectAtIndex:indexPath.row];
    }
}

-(void)segueWhenSelectedRow
{
    if (super.rectangleSelector.cellIndex != super.rectangleSelector.cellMax && [self.tableView indexPathForSelectedRow].row != super.rectangleSelector.cellMax)
    {
        [self performSegueWithIdentifier:@"selectorToLinkSegue" sender:nil];
    }
    else if (super.rectangleSelector.cellIndex == super.rectangleSelector.cellMax)
    {
        [self performSegueWithIdentifier:@"favoritesSegue" sender:nil];
    }
}

-(void)setupDataSource
{
    __weak RAPLinkSelectorViewController *weakSelf = self;
    
    UITableViewCell *(^cellForRowAtIndexPathBlock)(NSIndexPath *indexPath, UITableView *tableView) = ^UITableViewCell *(NSIndexPath *indexPath, UITableView *tableView)
    {
        static NSString *MyIdentifier = @"linkCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:MyIdentifier];
        }
        
        if (indexPath.row == weakSelf.URLsArray.count)
        {
            cell.textLabel.text = @"";
        }
        else
        {
            cell.textLabel.text = [weakSelf.URLsArray objectAtIndex:indexPath.row];
        }
        
        return cell;
    };
    
    NSInteger(^numberOfRowsInSectionBlock)() = ^NSInteger(){
        return weakSelf.URLsArray.count+1;
    };
    
    self.dataSource = [[RAPLinkSelectorDataSource alloc] initWithRowsInSectionBlock:numberOfRowsInSectionBlock CellForRowAtIndexPathBlock:cellForRowAtIndexPathBlock];
    self.tableView.delegate = self.dataSource;
    self.tableView.dataSource = self.dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDataSource];
    [self adjustTableView];
    self.tableView.estimatedRowHeight = 44;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(segueWhenSelectedRow) name:RAPSegueNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Observer for RAPSegueNotification is removed in the superclass
    [super viewWillDisappear:animated];
    [self turnOffSelectMode];
}

@end
