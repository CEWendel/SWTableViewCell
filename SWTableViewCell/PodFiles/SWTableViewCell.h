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
    kCellStateLongRightSwipe,
};

/**
 When this is set, this view will show up on top of the buttons. Currently only implemented for swiping from the right.
 */
@protocol SWTableViewCellLongSwipeView <NSObject>

/**
 Show a hint one can keep swiping. For example, one can show the text: "Keep swiping to add...".
 */
- (void)showLongSwipeHint;

/**
 Show the long swipe action to let user's know that releasing right now will cause action to be triggered.
 For example, one can show the text: "Release now to add"
 */
- (void)showLongSwipeAction;

/**
 Show an acknowledgement the action was successful. SWTableViewCell should send kCellStateLongRightSwipe
 For example, one can show the text: "Added!"
 */
- (void)showLongSwipeSuccess;

/**
 Reset the views to the original state - this probably involves setting alpha to 0 or hiding.
 */
- (void)resetView;

/**
 Offset from buttons at which we wish to trigger showLongSwipeHint on the view.
 */
- (CGFloat)hintOffset;

/**
 Offset from buttons at which we wish to trigger showLongSwipe on the view. Should be larger than the hintOffset
 */
- (CGFloat)triggerOffset;

@end

@protocol SWTableViewCellDelegate <NSObject>

@optional
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index;
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index;
- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state;
- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell;
- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state;
- (void)swipeableTableViewCellDidEndScrolling:(SWTableViewCell *)cell;
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didScroll:(UIScrollView *)scrollView;

@end

@interface SWTableViewCell : UITableViewCell

@property (nonatomic, copy) NSArray *leftUtilityButtons;
@property (nonatomic, copy) NSArray *rightUtilityButtons;
@property (nonatomic, strong) UIView<SWTableViewCellLongSwipeView> *longRightSwipeView;

@property (nonatomic, weak) id <SWTableViewCellDelegate> delegate;


- (void)setRightUtilityButtons:(NSArray *)rightUtilityButtons WithButtonWidth:(CGFloat)width;
- (void)setLeftUtilityButtons:(NSArray *)leftUtilityButtons WithButtonWidth:(CGFloat) width;
- (void)hideUtilityButtonsAnimated:(BOOL)animated;
- (void)showLeftUtilityButtonsAnimated:(BOOL)animated;
- (void)showRightUtilityButtonsAnimated:(BOOL)animated;

- (BOOL)isUtilityButtonsHidden;

@end
