//
//  SWTableViewCell.h
//  SWTableViewCell
//
//  Created by Chris Wendel on 9/10/13.
//  Copyright (c) 2013 Chris Wendel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "SWCellScrollView.h"
#import "SWLongPressGestureRecognizer.h"
#import "SWUtilityButtonTapGestureRecognizer.h"
#import "NSMutableArray+SWUtilityButtons.h"

@class SWTableViewCell;

typedef NS_ENUM(NSInteger, SWCellState)
{
    kCellStateCenter,
    kCellStateLeft,
    kCellStateRight,
};

@protocol SWTableViewCellDelegate <NSObject>

@optional
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index;
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index;
- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state;
- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell;
- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state;

@end

@interface SWTableViewCell : UITableViewCell

@property (nonatomic, copy) NSArray *leftUtilityButtons;
@property (nonatomic, copy) NSArray *rightUtilityButtons;
@property (nonatomic, weak) id <SWTableViewCellDelegate> delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier containingTableView:(UITableView *)containingTableView leftUtilityButtons:(NSArray *)leftUtilityButtons rightUtilityButtons:(NSArray *)rightUtilityButtons;

- (void)hideUtilityButtonsAnimated:(BOOL)animated;

@end
