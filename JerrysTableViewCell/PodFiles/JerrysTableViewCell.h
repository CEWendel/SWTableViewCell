//
//  JerrysTableViewCell.h
//  JerrysTableViewCell
//
//  Created by Chris Wendel on 9/10/13.
//  Copyright (c) 2013 Chris Wendel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "JerrysCellScrollView.h"
#import "JerrysLongPressGestureRecognizer.h"
#import "JerrysUtilityButtonTapGestureRecognizer.h"
#import "NSMutableArray+JerrysUtilityButtons.h"

@class JerrysTableViewCell;

typedef NS_ENUM(NSInteger, JerrysCellState)
{
    kCellStateCenter,
    kCellStateLeft,
    kCellStateRight,
};

@protocol JerrysTableViewCellDelegate <NSObject>

@optional
- (void)swipeableTableViewCell:(JerrysTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index;
- (void)swipeableTableViewCell:(JerrysTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index;
- (void)swipeableTableViewCell:(JerrysTableViewCell *)cell scrollingToState:(JerrysCellState)state;
- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(JerrysTableViewCell *)cell;
- (BOOL)swipeableTableViewCell:(JerrysTableViewCell *)cell canSwipeToState:(JerrysCellState)state;
- (void)swipeableTableViewCellDidEndScrolling:(JerrysTableViewCell *)cell;

@end

@interface JerrysTableViewCell : UITableViewCell

@property (nonatomic, copy) NSArray *leftUtilityButtons;
@property (nonatomic, copy) NSArray *rightUtilityButtons;

@property (nonatomic, weak) id <JerrysTableViewCellDelegate> delegate;

- (void)setRightUtilityButtons:(NSArray *)rightUtilityButtons WithButtonWidth:(CGFloat) width;
- (void)setLeftUtilityButtons:(NSArray *)leftUtilityButtons WithButtonWidth:(CGFloat) width;
- (void)hideUtilityButtonsAnimated:(BOOL)animated;
- (void)showLeftUtilityButtonsAnimated:(BOOL)animated;
- (void)showRightUtilityButtonsAnimated:(BOOL)animated;

- (BOOL)isUtilityButtonsHidden;

@end
