//
//  SWTableViewCell.m
//  SWTableViewCell
//
//  Created by Chris Wendel on 9/10/13.
//  Copyright (c) 2013 Chris Wendel. All rights reserved.
//

#import "SWTableViewCell.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "SWUtilityButtonView.h"
#import "UITableView+SWCellSelection.h"

static NSString * const kTableViewCellContentView = @"UITableViewCellContentView";

#pragma mark - SWUtilityButtonView

@interface SWTableViewCell () <UIScrollViewDelegate>
{
    SWCellState _cellState; // The state of the cell within the scroll view, can be left, right or middle
    CGFloat additionalRightPadding;
    
    dispatch_once_t onceToken;
}

- (void)toggleCellSelectionStateWithAnimation:(BOOL)animation;

@property (nonatomic, strong) SWUtilityButtonView *scrollViewButtonViewLeft;
@property (nonatomic, strong) SWUtilityButtonView *scrollViewButtonViewRight;
@property (nonatomic, weak) UIView *scrollViewContentView;
@property (nonatomic) CGFloat height;

@property (nonatomic, strong) SWLongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, assign, getter = isShowingSelection) BOOL showingSelection; // YES if we are currently highlighting the cell for selection

@end

@implementation SWTableViewCell

#pragma mark Initializers

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier containingTableView:(UITableView *)containingTableView leftUtilityButtons:(NSArray *)leftUtilityButtons rightUtilityButtons:(NSArray *)rightUtilityButtons
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.height = containingTableView.rowHeight;
        [self initializer];
        self.containingTableView = containingTableView;
        self.rightUtilityButtons = rightUtilityButtons;
        self.leftUtilityButtons = leftUtilityButtons;
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        [self initializer];
    }
    
    return self;
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        [self initializer];
    }
    
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        [self initializer];
    }
    
    return self;
}

- (void)initializer
{
    // Set up scroll view that will host our cell content
    SWCellScrollView *cellScrollView = [[SWCellScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), self.height)];
    cellScrollView.delegate = self;
    cellScrollView.showsHorizontalScrollIndicator = NO;
    cellScrollView.scrollsToTop = NO;
    cellScrollView.scrollEnabled = YES;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(scrollViewTapGestureRecognizerFired:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [cellScrollView addGestureRecognizer:tapGestureRecognizer];
    
    self.tapGestureRecognizer = tapGestureRecognizer;
    
    SWLongPressGestureRecognizer *longPressGestureRecognizer = [[SWLongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                             action:@selector(scrollViewLongPressGestureRecognizerFired:)];
    longPressGestureRecognizer.cancelsTouchesInView = NO;
    longPressGestureRecognizer.minimumPressDuration = 0.1;
    [cellScrollView addGestureRecognizer:longPressGestureRecognizer];
    
    self.longPressGestureRecognizer = longPressGestureRecognizer;
    
    self.cellScrollView = cellScrollView;
    
    // Create the content view that will live in our scroll view
    UIView *scrollViewContentView = [[UIView alloc] initWithFrame:CGRectMake([self leftUtilityButtonsWidth], 0, CGRectGetWidth(self.bounds), self.height)];
    scrollViewContentView.backgroundColor = [UIColor whiteColor];
    [self.cellScrollView addSubview:scrollViewContentView];
    self.scrollViewContentView = scrollViewContentView;
    
    // Add the cell scroll view to the cell
    UIView *contentViewParent = self;
    if (![NSStringFromClass([[self.subviews objectAtIndex:0] class]) isEqualToString:kTableViewCellContentView])
    {
        // iOS 7
        contentViewParent = [self.subviews objectAtIndex:0];
    }
    NSArray *cellSubviews = [contentViewParent subviews];
    [self insertSubview:cellScrollView atIndex:0];
    for (UIView *subview in cellSubviews)
    {
        [self.scrollViewContentView addSubview:subview];
    }
    
    self.showingSelection = NO;
    self.highlighted = NO;
}

- (void)setContainingTableView:(UITableView *)containingTableView
{
    _containingTableView = containingTableView;
    // Check if the UITableView will display Indices on the right. If that's the case, add a padding
    if([_containingTableView.dataSource respondsToSelector:@selector(sectionIndexTitlesForTableView:)])
    {
        NSArray *indices = [_containingTableView.dataSource sectionIndexTitlesForTableView:_containingTableView];
        additionalRightPadding = indices == nil ? 0 : kSectionIndexWidth;
    }
    
    _containingTableView.directionalLockEnabled = YES;
    
    self.height = _containingTableView.rowHeight;
    [self.tapGestureRecognizer requireGestureRecognizerToFail:_containingTableView.panGestureRecognizer];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.cellScrollView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), self.height);
    self.cellScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds) + [self utilityButtonsPadding], self.height);
    self.cellScrollView.contentOffset = CGPointMake([self leftUtilityButtonsWidth], 0);
    self.scrollViewButtonViewLeft.frame = CGRectMake([self leftUtilityButtonsWidth], 0, 0, self.height);
    self.scrollViewButtonViewLeft.layer.masksToBounds = YES;
    self.scrollViewButtonViewRight.frame = CGRectMake(CGRectGetWidth(self.bounds), 0, 0, self.height);
    self.scrollViewButtonViewRight.layer.masksToBounds = YES;
    self.scrollViewContentView.frame = CGRectMake([self leftUtilityButtonsWidth], 0, CGRectGetWidth(self.bounds), self.height);
    self.tapGestureRecognizer.enabled = YES;
    self.showingSelection = NO;
}

#pragma mark - Properties

- (void)setLeftUtilityButtons:(NSArray *)leftUtilityButtons
{
    _leftUtilityButtons = leftUtilityButtons;
    SWUtilityButtonView *departingLeftButtons = self.scrollViewButtonViewLeft;
    SWUtilityButtonView *scrollViewButtonViewLeft = [[SWUtilityButtonView alloc] initWithUtilityButtons:leftUtilityButtons
                                                                                             parentCell:self
                                                                                  utilityButtonSelector:@selector(leftUtilityButtonHandler:)];
    
    self.scrollViewButtonViewLeft = scrollViewButtonViewLeft;
    [scrollViewButtonViewLeft setFrame:CGRectMake([self leftUtilityButtonsWidth], 0, [self leftUtilityButtonsWidth], self.height)];
    
    [self.cellScrollView insertSubview:scrollViewButtonViewLeft belowSubview:self.scrollViewContentView];

    [departingLeftButtons removeFromSuperview];
    [scrollViewButtonViewLeft populateUtilityButtons];
    
    [self setNeedsLayout];
}

- (void)setRightUtilityButtons:(NSArray *)rightUtilityButtons
{
    _rightUtilityButtons = rightUtilityButtons;
    SWUtilityButtonView *departingLeftButtons = self.scrollViewButtonViewRight;
    SWUtilityButtonView *scrollViewButtonViewRight = [[SWUtilityButtonView alloc] initWithUtilityButtons:rightUtilityButtons
                                                                                              parentCell:self
                                                                                   utilityButtonSelector:@selector(rightUtilityButtonHandler:)];

    self.scrollViewButtonViewRight = scrollViewButtonViewRight;
    [scrollViewButtonViewRight setFrame:CGRectMake(CGRectGetWidth(self.bounds), 0, [self rightUtilityButtonsWidth], self.height)];
    
    [self.cellScrollView insertSubview:scrollViewButtonViewRight belowSubview:self.scrollViewContentView];
    
    [departingLeftButtons removeFromSuperview];
    [scrollViewButtonViewRight populateUtilityButtons];
    
    [self setNeedsLayout];
}


#pragma mark Selection

- (void)scrollViewLongPressGestureRecognizerFired:(id)sender
{
    SWLongPressGestureRecognizer *longPressGestureRecognizer = (SWLongPressGestureRecognizer *)sender;
    
    if (longPressGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        if (![self isHighlighted]) {
            [self setHighlighted:YES animated:!([self isSelected])];
        }
    }
    else if (longPressGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        [self toggleCellSelectionStateWithAnimation:NO];

        if ([self isHighlighted]) {
            [self setHighlighted:NO animated:!([self isSelected])];
        }
    }
    else if (longPressGestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        if ([self isHighlighted])  {
            [self setHighlighted:NO animated:YES];
        }
    }
}

- (void)scrollViewTapGestureRecognizerFired:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        if (_cellState == kCellStateCenter) {
            [self toggleCellSelectionStateWithAnimation:YES];
        }
        else {
            [self hideUtilityButtonsAnimated:YES];
        }
        
    }
}

- (void)toggleCellSelectionStateWithAnimation:(BOOL)animation;
{
    NSIndexPath *indexPathToSelect = [self.containingTableView indexPathForCell:self];
    
    if ([self isSelected]) {
        [self.containingTableView sw_deselectRowAtIndexPath:indexPathToSelect withAnimation:animation];
    }
    else {
        [self.containingTableView sw_selectRowAtIndexPath:indexPathToSelect withAnimation:animation];
    }
}

#pragma mark UITableViewCell overrides

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    _scrollViewContentView.backgroundColor = backgroundColor;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (![self.containingTableView allowsSelectionDuringEditing]) {
        BOOL canScroll = !([self isHighlighted] || [self isSelected]);
        [self.cellScrollView setScrollEnabled:canScroll];
    }
    else {
        [self.cellScrollView setScrollEnabled:YES];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (![self.containingTableView allowsSelectionDuringEditing]) {
        BOOL canScroll = !([self isHighlighted] || [self isSelected]);
        [self.cellScrollView setScrollEnabled:canScroll];
    }
    else {
        [self.cellScrollView setScrollEnabled:YES];
    }
}

#pragma mark -  Height methods

- (void)setCellHeight:(CGFloat)height
{
    _height = height;
    
    // update the utility button height
    [self.scrollViewButtonViewLeft setHeight:height];
    [self.scrollViewButtonViewRight setHeight:height];
    
    [self layoutSubviews];
}

#pragma mark - Utility buttons handling

- (void)rightUtilityButtonHandler:(id)sender
{
    SWUtilityButtonTapGestureRecognizer *utilityButtonTapGestureRecognizer = (SWUtilityButtonTapGestureRecognizer *)sender;
    NSUInteger utilityButtonIndex = utilityButtonTapGestureRecognizer.buttonIndex;
    if ([self.delegate respondsToSelector:@selector(swipeableTableViewCell:didTriggerRightUtilityButtonWithIndex:)])
    {
        [self.delegate swipeableTableViewCell:self didTriggerRightUtilityButtonWithIndex:utilityButtonIndex];
    }
}

- (void)leftUtilityButtonHandler:(id)sender
{
    SWUtilityButtonTapGestureRecognizer *utilityButtonTapGestureRecognizer = (SWUtilityButtonTapGestureRecognizer *)sender;
    NSUInteger utilityButtonIndex = utilityButtonTapGestureRecognizer.buttonIndex;
    if ([self.delegate respondsToSelector:@selector(swipeableTableViewCell:didTriggerLeftUtilityButtonWithIndex:)])
    {
        [self.delegate swipeableTableViewCell:self didTriggerLeftUtilityButtonWithIndex:utilityButtonIndex];
    }
}

- (void)hideUtilityButtonsAnimated:(BOOL)animated
{
    if (_cellState == kCellStateCenter)
        return;
    // Scroll back to center
    
    // Force the scroll back to run on the main thread because of weird scroll view bugs
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.cellScrollView setContentOffset:CGPointMake([self leftUtilityButtonsWidth], 0) animated:YES];
    });
    _cellState = kCellStateCenter;
    
    if ([self.delegate respondsToSelector:@selector(swipeableTableViewCell:scrollingToState:)])
    {
        [self.delegate swipeableTableViewCell:self scrollingToState:kCellStateCenter];
    }
}


#pragma mark - Setup helpers

- (CGFloat)leftUtilityButtonsWidth
{
    return [self.scrollViewButtonViewLeft utilityButtonsWidth];
}

- (CGFloat)rightUtilityButtonsWidth
{
    return [self.scrollViewButtonViewRight utilityButtonsWidth] + additionalRightPadding;
}

- (CGFloat)utilityButtonsPadding
{
    return [self leftUtilityButtonsWidth] + [self rightUtilityButtonsWidth];
}

- (CGPoint)scrollViewContentOffset
{
    return CGPointMake([self.scrollViewButtonViewLeft utilityButtonsWidth], 0);
}

- (void)setAppearanceWithBlock:(void (^)())appearanceBlock force:(BOOL)force
{
    if (force)
    {
        appearanceBlock();
    }
    else
    {
        dispatch_once(&onceToken, ^{
            appearanceBlock();
        });
    }
}

#pragma mark UIScrollView helpers

- (void)scrollToRight:(inout CGPoint *)targetContentOffset
{
    targetContentOffset->x = [self utilityButtonsPadding];
    _cellState = kCellStateRight;
    
    self.longPressGestureRecognizer.enabled = NO;
    self.tapGestureRecognizer.enabled = NO;
    
    if ([self.delegate respondsToSelector:@selector(swipeableTableViewCell:scrollingToState:)])
    {
        [self.delegate swipeableTableViewCell:self scrollingToState:kCellStateRight];
    }

    if ([self.delegate respondsToSelector:@selector(swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:)])
    {
        for (SWTableViewCell *cell in [self.containingTableView visibleCells]) {
            if (cell != self && [cell isKindOfClass:[SWTableViewCell class]] && [self.delegate swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:cell]) {
                [cell hideUtilityButtonsAnimated:YES];
            }
        }
    }
}

- (void)scrollToCenter:(inout CGPoint *)targetContentOffset
{
    targetContentOffset->x = [self leftUtilityButtonsWidth];
    _cellState = kCellStateCenter;
    
    self.longPressGestureRecognizer.enabled = YES;
    self.tapGestureRecognizer.enabled = NO;

    if ([self.delegate respondsToSelector:@selector(swipeableTableViewCell:scrollingToState:)])
    {
        [self.delegate swipeableTableViewCell:self scrollingToState:kCellStateCenter];
    }
}

- (void)scrollToLeft:(inout CGPoint *)targetContentOffset
{
    targetContentOffset->x = 0;
    _cellState = kCellStateLeft;
    
    self.longPressGestureRecognizer.enabled = NO;
    self.tapGestureRecognizer.enabled = NO;
    
    if ([self.delegate respondsToSelector:@selector(swipeableTableViewCell:scrollingToState:)])
    {
        [self.delegate swipeableTableViewCell:self scrollingToState:kCellStateLeft];
    }
    
    if ([self.delegate respondsToSelector:@selector(swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:)])
    {
        for (SWTableViewCell *cell in [self.containingTableView visibleCells]) {
            if (cell != self && [cell isKindOfClass:[SWTableViewCell class]] && [self.delegate swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:cell]) {
                [cell hideUtilityButtonsAnimated:YES];
            }
        }
    }
}

#pragma mark UIScrollViewDelegate



- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    switch (_cellState)
    {
        case kCellStateCenter:
            if (velocity.x >= 0.5f)
            {
                [self scrollToRight:targetContentOffset];
            }
            else if (velocity.x <= -0.5f)
            {
                [self scrollToLeft:targetContentOffset];
            }
            else
            {
                CGFloat rightThreshold = [self utilityButtonsPadding] - ([self rightUtilityButtonsWidth] / 2);
                CGFloat leftThreshold = [self leftUtilityButtonsWidth] / 2;
                if (targetContentOffset->x > rightThreshold)
                    [self scrollToRight:targetContentOffset];
                else if (targetContentOffset->x < leftThreshold)
                    [self scrollToLeft:targetContentOffset];
                else
                    [self scrollToCenter:targetContentOffset];
            }
            break;
        case kCellStateLeft:
            if (velocity.x >= 0.5f)
            {
                [self scrollToCenter:targetContentOffset];
            }
            else if (velocity.x <= -0.5f)
            {
                // No-op
            }
            else
            {
                if (targetContentOffset->x >= ([self utilityButtonsPadding] - [self rightUtilityButtonsWidth] / 2))
                    [self scrollToRight:targetContentOffset];
                else if (targetContentOffset->x > [self leftUtilityButtonsWidth] / 2)
                    [self scrollToCenter:targetContentOffset];
                else
                    [self scrollToLeft:targetContentOffset];
            }
            break;
        case kCellStateRight:
            if (velocity.x >= 0.5f)
            {
                // No-op
            }
            else if (velocity.x <= -0.5f)
            {
                [self scrollToCenter:targetContentOffset];
            }
            else
            {
                if (targetContentOffset->x <= [self leftUtilityButtonsWidth] / 2)
                    [self scrollToLeft:targetContentOffset];
                else if (targetContentOffset->x < ([self utilityButtonsPadding] - [self rightUtilityButtonsWidth] / 2))
                    [self scrollToCenter:targetContentOffset];
                else
                    [self scrollToRight:targetContentOffset];
            }
            break;
        default:
            break;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.tapGestureRecognizer.enabled = NO;
    if (scrollView.contentOffset.x > [self leftUtilityButtonsWidth])
    {
        if ([self rightUtilityButtonsWidth] > 0)
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(swipeableTableViewCell:canSwipeToState:)])
            {
                BOOL shouldScroll = [self.delegate swipeableTableViewCell:self canSwipeToState:kCellStateRight];
                if (!shouldScroll)
                {
                    scrollView.contentOffset = CGPointMake([self leftUtilityButtonsWidth], 0);
                    return;
                }
            }
            CGFloat scrollViewWidth = MIN(scrollView.contentOffset.x - [self leftUtilityButtonsWidth], [self rightUtilityButtonsWidth]);
            
            // Expose the right button view
            self.scrollViewButtonViewRight.frame = CGRectMake(scrollView.contentOffset.x + (CGRectGetWidth(self.bounds) - scrollViewWidth), 0.0f, scrollViewWidth,self.height);
            
            CGRect scrollViewBounds = self.scrollViewButtonViewRight.bounds;
            scrollViewBounds.origin.x = MAX([self rightUtilityButtonsWidth] - scrollViewWidth, [self rightUtilityButtonsWidth] - scrollView.contentOffset.x);
            self.scrollViewButtonViewRight.bounds = scrollViewBounds;
        }
        else
        {
            [scrollView setContentOffset:CGPointMake([self leftUtilityButtonsWidth], 0)];
            self.tapGestureRecognizer.enabled = YES;
        }
    }
    else
    {
        // Expose the left button view
        if ([self leftUtilityButtonsWidth] > 0)
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(swipeableTableViewCell:canSwipeToState:)])
            {
                BOOL shouldScroll = [self.delegate swipeableTableViewCell:self canSwipeToState:kCellStateLeft];
                if (!shouldScroll)
                {
                    scrollView.contentOffset = CGPointMake([self leftUtilityButtonsWidth], 0);
                    return;
                }
            }
            CGFloat scrollViewWidth = MIN(scrollView.contentOffset.x - [self leftUtilityButtonsWidth], [self leftUtilityButtonsWidth]);
            
            self.scrollViewButtonViewLeft.frame = CGRectMake([self leftUtilityButtonsWidth], 0.0f, scrollViewWidth, self.height);
        }
        else
        {
            [scrollView setContentOffset:CGPointMake(0, 0)];
            self.tapGestureRecognizer.enabled = YES;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self setCellState];
    
    self.tapGestureRecognizer.enabled = YES;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self setCellState];
    
    // Called when setContentOffset in hideUtilityButtonsAnimated: is done
    self.tapGestureRecognizer.enabled = YES;
    if (_cellState == kCellStateCenter)
    {
        self.longPressGestureRecognizer.enabled = YES;
    }
}

- (void)setCellState
{
    if ([self.cellScrollView contentOffset].x == [self leftUtilityButtonsWidth])
        _cellState = kCellStateCenter;
    else if ([self.cellScrollView contentOffset].x == 0)
        _cellState = kCellStateLeft;
    else if ([self.cellScrollView contentOffset].x == [self utilityButtonsPadding])
        _cellState = kCellStateRight;
}

@end
