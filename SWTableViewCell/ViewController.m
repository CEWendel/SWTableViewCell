//
//  ViewController.m
//  SWTableViewCell
//
//  Created by Chris Wendel on 9/10/13.
//  Copyright (c) 2013 Chris Wendel. All rights reserved.
//

#import "ViewController.h"
#import "SWTableViewCell.h"

@interface ViewController () {
    NSMutableArray *_testArray;
    NSIndexPath *_selectedIndexPath;
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 90;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0); // Makes the horizontal row seperator stretch the entire length of the table view
    
    _testArray = [[NSMutableArray alloc] init];
    
    // Add test data to our test array
    [_testArray addObject:[NSDate date]];
    [_testArray addObject:[NSDate date]];
    [_testArray addObject:[NSDate date]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) resetSelectedCell
{
    SWTableViewCell *cell = (SWTableViewCell*)[self.tableView cellForRowAtIndexPath:_selectedIndexPath];
    [cell resetCellPosition];
    _selectedIndexPath = nil;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _testArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    SWTableViewCell *cell = (SWTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        NSMutableArray *leftUtilityButtons = [NSMutableArray new];
        NSMutableArray *rightUtilityButtons = [NSMutableArray new];
        
        [leftUtilityButtons addUtilityButtonWithColor:[UIColor colorWithRed:0.07 green:0.75f blue:0.16f alpha:1.0] icon:[UIImage imageNamed:@"check.png"]];
        [leftUtilityButtons addUtilityButtonWithColor:[UIColor colorWithRed:1.0f green:1.0f blue:0.35f alpha:1.0] icon:[UIImage imageNamed:@"clock.png"]];
        [leftUtilityButtons addUtilityButtonWithColor:[UIColor colorWithRed:1.0f green:0.231f blue:0.188f alpha:1.0] icon:[UIImage imageNamed:@"cross.png"]];
        [leftUtilityButtons addUtilityButtonWithColor:[UIColor colorWithRed:0.55f green:0.27f blue:0.07f alpha:1.0] icon:[UIImage imageNamed:@"list.png"]];
        
        [rightUtilityButtons addUtilityButtonWithColor:[UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0] title:@"More"];
        [rightUtilityButtons addUtilityButtonWithColor:[UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f] title:@"Delete"];
        
        cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier height:_tableView.rowHeight leftUtilityButtons:leftUtilityButtons rightUtilityButtons:rightUtilityButtons];
        cell.delegate = self;
    }
    
    NSDate *dateObject = _testArray[indexPath.row];
    cell.textLabel.text = [dateObject description];
    cell.detailTextLabel.text = @"Some detail text";
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Set background color of cell here if you don't want white
}

#pragma mark - ScrollViewDelegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self resetSelectedCell];
}

#pragma mark - SWTableViewDelegate

- (void) swipeTableViewCellDidFinish:(SWTableViewCell *)cell
{
    NSIndexPath *indexPathForCell = [self.tableView indexPathForCell:cell];
    if (_selectedIndexPath.row != indexPathForCell.row)
        [self resetSelectedCell];
    
    _selectedIndexPath = indexPathForCell;
}

- (void)swippableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
            NSLog(@"left button 0 was pressed");
            break;
        case 1:
            NSLog(@"left button 1 was pressed");
            break;
        case 2:
            NSLog(@"left button 2 was pressed");
            break;
        case 3:
            NSLog(@"left btton 3 was pressed");
        default:
            break;
    }
}

- (void)swippableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
            NSLog(@"More button was pressed");
            break;
        case 1:
        {
            // Delete button was pressed
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            
            [_testArray removeObjectAtIndex:cellIndexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
            break;
        }
        default:
            break;
    }
}

- (void) didSelectedCell:(SWTableViewCell *)cell
{
    [self resetSelectedCell];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

@end
