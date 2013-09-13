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

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _testArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    SWTableViewCell *cell = (SWTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        NSLog(@"cell initialized");
        NSMutableArray *leftUtilityButtons = [NSMutableArray new];
        NSMutableArray *rightUtilityButtons = [NSMutableArray new];
        
        //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        
        UIButton *moreButtonRight = [UIButton buttonWithType:UIButtonTypeCustom];
        moreButtonRight.backgroundColor = [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0f];
        [moreButtonRight setTitle:@"More" forState:UIControlStateNormal];
        [moreButtonRight setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [rightUtilityButtons addObject:moreButtonRight];
        
        UIButton *moreButtonLeft = [UIButton buttonWithType:UIButtonTypeCustom];
        moreButtonLeft.backgroundColor = [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0f];
        [moreButtonLeft setTitle:@"More" forState:UIControlStateNormal];
        [moreButtonLeft setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [leftUtilityButtons addObject:moreButtonLeft];
        
        UIButton *deleteButtonRight = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteButtonRight.backgroundColor = [UIColor colorWithRed:1.0f green:0.231f blue:0.188f alpha:1.0f];
        [deleteButtonRight setTitle:@"Delete" forState:UIControlStateNormal];
        [deleteButtonRight setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [rightUtilityButtons addObject:deleteButtonRight];

        UIButton *deleteButtonLeft = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteButtonLeft.backgroundColor = [UIColor colorWithRed:1.0f green:0.231f blue:0.188f alpha:1.0f];
        [deleteButtonLeft setTitle:@"Delete" forState:UIControlStateNormal];
        [deleteButtonLeft setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [leftUtilityButtons addObject:deleteButtonLeft];
        
        cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier height:_tableView.rowHeight leftUtilityButtons:leftUtilityButtons rightUtilityButtons:rightUtilityButtons];
    }
    
    NSDate *dateObject = _testArray[indexPath.row];
    cell.textLabel.text = [dateObject description];
    cell.detailTextLabel.text = @"Some detail text";
    
    NSLog(@"row height is %f", _tableView.rowHeight);
    NSLog(@"cell height is %f", cell.frame.size.height);
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

@end
