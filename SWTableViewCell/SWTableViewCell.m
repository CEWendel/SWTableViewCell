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

static NSString * const kTableViewCellContentView = @"UITableViewCellContentView";

#pragma mark - SWUtilityButtonView

static BOOL containingScrollViewIsScrolling = false;

@interface SWTableViewCell () <UIScrollViewDelegate> {
    SWCellState _cellState; // The state of the cell within the scroll view, can be left, right or middle
    BOOL _isHidingUtilityButtons;
    CGFloat additionalRightPadding;
}

@property (nonatomic, strong) SWCellScrollView *cellScrollView; // Scroll view to be added to UITableViewCell
@property (nonatomic) CGFloat height; // The cell's height
@property (nonatomic, weak) UIView *scrollViewContentView; // Views that live in the scroll view
@property (nonatomic, strong) SWUtilityButtonView *scrollViewButtonViewLeft;
@property (nonatomic, strong) SWUtilityButtonView *scrollViewButtonViewRight;

// Gesture recognizers
@property (nonatomic, strong) SWLongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

// Used for row height and selection
@property (nonatomic, weak) UITableView *containingTableView;

@end

@implementation SWTableViewCell

#pragma mark Initializers

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier containingTableView:(UITableView *)containingTableView leftUtilityButtons:(NSArray *)leftUtilityButtons rightUtilityButtons:(NSArray *)rightUtilityButtons {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.rightUtilityButtons = rightUtilityButtons;
        self.leftUtilityButtons = leftUtilityButtons;
        self.height = containingTableView.rowHeight;
        self.containingTableView = containingTableView;
        self.highlighted = NO;
        [self initializer];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self initializer];
    }
    
    return self;
}

- (id)init {
    self = [super init];
    
    if (self) {
        [self initializer];
    }
    
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self initializer];
    }
    
    return self;
}

- (void)initializer {
    // Check if the UITableView will display Indices on the right. If that's the case, add a padding
    if([self.containingTableView.dataSource respondsToSelector:@selector(sectionIndexTitlesForTableView:)])
    {
        NSArray *indices = [self.containingTableView.dataSource sectionIndexTitlesForTableView:self.containingTableView];
        additionalRightPadding = indices == nil ? 0 : kSectionIndexWidth;
    }
    
    // Set up scroll view that will host our cell content
    SWCellScrollView *cellScrollView = [[SWCellScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), _height)];
    cellScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds) + [self utilityButtonsPadding], _height);
    cellScrollView.contentOffset = [self scrollViewContentOffset];
    cellScrollView.delegate = self;
    cellScrollView.showsHorizontalScrollIndicator = NO;
    cellScrollView.scrollsToTop = NO;
    cellScrollView.scrollEnabled = YES;
    
    UITapGestureRecognizer *tapGesutreRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewUp:)];
    [cellScrollView addGestureRecognizer:tapGesutreRecognizer];
    
    self.tapGestureRecognizer = tapGesutreRecognizer;
    
    SWLongPressGestureRecognizer *longPressGestureRecognizer = [[SWLongPressGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewPressed:)];
    longPressGestureRecognizer.minimumPressDuration = 0.1;
    [cellScrollView addGestureRecognizer:longPressGestureRecognizer];
    
    self.longPressGestureRecognizer = longPressGestureRecognizer;
    
    self.cellScrollView = cellScrollView;
    
    // Set up the views that will hold the utility buttons
    SWUtilityButtonView *scrollViewButtonViewLeft = [[SWUtilityButtonView alloc] initWithUtilityButtons:_leftUtilityButtons parentCell:self utilityButtonSelector:@selector(leftUtilityButtonHandler:)];
    [scrollViewButtonViewLeft setFrame:CGRectMake([self leftUtilityButtonsWidth], 0, [self leftUtilityButtonsWidth], _height)];
    self.scrollViewButtonViewLeft = scrollViewButtonViewLeft;
    [self.cellScrollView addSubview:scrollViewButtonViewLeft];
    
    SWUtilityButtonView *scrollViewButtonViewRight = [[SWUtilityButtonView alloc] initWithUtilityButtons:_rightUtilityButtons parentCell:self utilityButtonSelector:@selector(rightUtilityButtonHandler:)];
    [scrollViewButtonViewRight setFrame:CGRectMake(CGRectGetWidth(self.bounds), 0, [self rightUtilityButtonsWidth], _height)];
    self.scrollViewButtonViewRight = scrollViewButtonViewRight;
    [self.cellScrollView addSubview:scrollViewButtonViewRight];
    
    // Populate the button views with utility buttons
    [scrollViewButtonViewLeft populateUtilityButtons];
    [scrollViewButtonViewRight populateUtilityButtons];
    
    // Create the content view that will live in our scroll view
    UIView *scrollViewContentView = [[UIView alloc] initWithFrame:CGRectMake([self leftUtilityButtonsWidth], 0, CGRectGetWidth(self.bounds), _height)];
    scrollViewContentView.backgroundColor = [UIColor whiteColor];
    [self.cellScrollView addSubview:scrollViewContentView];
    self.scrollViewContentView = scrollViewContentView;
    
    // Add the cell scroll view to the cell
    UIView *contentViewParent = self;
    if (![NSStringFromClass([[self.subviews objectAtIndex:0] class]) isEqualToString:kTableViewCellContentView]) {
        // iOS 7
        contentViewParent = [self.subviews objectAtIndex:0];
    }
    NSArray *cellSubviews = [contentViewParent subviews];
    [self insertSubview:cellScrollView atIndex:0];
    for (UIView *subview in cellSubviews) {
        [self.scrollViewContentView addSubview:subview];
    }
    
    [self addSubview:self.contentView];
    [self.scrollViewContentView addSubview:self.contentView];
}

#pragma mark Selection

- (void)scrollViewPressed:(id)sender {
    SWLongPressGestureRecognizer *longPressGestureRecognizer = (SWLongPressGestureRecognizer *)sender;
    
    if (longPressGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        // Gesture recognizer ended without failing so we select the cell
        [self selectCell];
        
        // Set back to deselected
        [self setSelected:NO];
    } else {
        // Handle the highlighting of the cell
        if (self.isHighlighted) {
            [self setHighlighted:NO];
        } else {
            [self highlightCell];
        }
    }
}

- (void)scrollViewUp:(id)sender {
    [self selectCellWithTimedHighlight];
}

- (void)selectCell {
    if (_cellState == kCellStateCenter) {
        if ([self.containingTableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]){
            NSIndexPath *cellIndexPath = [_containingTableView indexPathForCell:self];
            [self.containingTableView.delegate tableView:_containingTableView didSelectRowAtIndexPath:cellIndexPath];
        }
    }
}

- (void)selectCellWithTimedHighlight {
    if(_cellState == kCellStateCenter) {
        // Selection
        if ([self.containingTableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]){
            NSIndexPath *cellIndexPath = [_containingTableView indexPathForCell:self];
            [self setSelected:YES];
            [self.containingTableView.delegate tableView:_containingTableView didSelectRowAtIndexPath:cellIndexPath];
            // Make the selection visible
            NSTimer *endHighlightTimer = [NSTimer scheduledTimerWithTimeInterval:0.20 target:self selector:@selector(timerEndCellHighlight:) userInfo:nil repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:endHighlightTimer forMode:NSRunLoopCommonModes];
        }
    } else {
        // Scroll back to center
        [self hideUtilityButtonsAnimated:YES];
    }
}

- (void)highlightCell {
    if (_cellState == kCellStateCenter) {
        [self setHighlighted:YES];
    }
}

- (void)timerEndCellHighlight:(id)sender {
    [self setSelected:NO];
}

#pragma mark UITableViewCell overrides

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    self.scrollViewContentView.backgroundColor = backgroundColor;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted animated:NO];
    if (highlighted) {
        self.scrollViewButtonViewLeft.hidden = YES;
        self.scrollViewButtonViewRight.hidden = YES;
    } else {
        self.scrollViewButtonViewLeft.hidden = NO;
        self.scrollViewButtonViewRight.hidden = NO;
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        self.scrollViewButtonViewLeft.hidden = YES;
        self.scrollViewButtonViewRight.hidden = YES;
    } else {
        self.scrollViewButtonViewLeft.hidden = NO;
        self.scrollViewButtonViewRight.hidden = NO;
    }
}

- (void)setSelected:(BOOL)selected {
    if (selected) {
        [self setHighlighted:YES];
    } else {
        [self setHighlighted:NO];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated  {
    if (selected) {
        [self setHighlighted:YES];
    } else {
        [self setHighlighted:NO];
    }
}

#pragma mark Height methods

- (void)setCellHeight:(CGFloat)height {
    _height = height;
    
    // update the utility button height
    [_scrollViewButtonViewLeft setHeight:height];
    [_scrollViewButtonViewRight setHeight:height];
    
    [self layoutSubviews];
}

#pragma mark - Utility buttons handling

- (void)rightUtilityButtonHandler:(id)sender {
    SWUtilityButtonTapGestureRecognizer *utilityButtonTapGestureRecognizer = (SWUtilityButtonTapGestureRecognizer *)sender;
    NSUInteger utilityButtonIndex = utilityButtonTapGestureRecognizer.buttonIndex;
    if ([_delegate respondsToSelector:@selector(swipeableTableViewCell:didTriggerRightUtilityButtonWithIndex:)]) {
        [_delegate swipeableTableViewCell:self didTriggerRightUtilityButtonWithIndex:utilityButtonIndex];
    }
}

- (void)leftUtilityButtonHandler:(id)sender {
    SWUtilityButtonTapGestureRecognizer *utilityButtonTapGestureRecognizer = (SWUtilityButtonTapGestureRecognizer *)sender;
    NSUInteger utilityButtonIndex = utilityButtonTapGestureRecognizer.buttonIndex;
    if ([_delegate respondsToSelector:@selector(swipeableTableViewCell:didTriggerLeftUtilityButtonWithIndex:)]) {
        [_delegate swipeableTableViewCell:self didTriggerLeftUtilityButtonWithIndex:utilityButtonIndex];
    }
}

- (void)hideUtilityButtonsAnimated:(BOOL)animated {
    // Scroll back to center
    
    // Force the scroll back to run on the main thread because of weird scroll view bugs
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.cellScrollView setContentOffset:CGPointMake([self leftUtilityButtonsWidth], 0) animated:YES];
    });
    _cellState = kCellStateCenter;
    
    if ([_delegate respondsToSelector:@selector(swipeableTableViewCell:scrollingToState:)]) {
        [_delegate swipeableTableViewCell:self scrollingToState:kCellStateCenter];
    }
}


#pragma mark - Overriden methods

- (void)layoutSubviews {
    [super layoutSubviews];

    self.cellScrollView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), _height);
    self.cellScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds) + [self utilityButtonsPadding], _height);
    self.cellScrollView.contentOffset = CGPointMake([self leftUtilityButtonsWidth], 0);
    self.scrollViewButtonViewLeft.frame = CGRectMake([self leftUtilityButtonsWidth], 0, [self leftUtilityButtonsWidth], _height);
    self.scrollViewButtonViewRight.frame = CGRectMake(CGRectGetWidth(self.bounds), 0, [self rightUtilityButtonsWidth], _height);
    self.scrollViewContentView.frame = CGRectMake([self leftUtilityButtonsWidth], 0, CGRectGetWidth(self.bounds), _height);
    self.cellScrollView.scrollEnabled = YES;
    self.containingTableView.scrollEnabled = YES;
    self.tapGestureRecognizer.enabled = YES;
}

#pragma mark - Setup helpers

- (CGFloat)leftUtilityButtonsWidth {
    return [_scrollViewButtonViewLeft utilityButtonsWidth];
}

- (CGFloat)rightUtilityButtonsWidth {
    return [_scrollViewButtonViewRight utilityButtonsWidth] + additionalRightPadding;
}

- (CGFloat)utilityButtonsPadding {
    return [self leftUtilityButtonsWidth] + [self rightUtilityButtonsWidth];
}

- (CGPoint)scrollViewContentOffset {
    return CGPointMake([_scrollViewButtonViewLeft utilityButtonsWidth], 0);
}

#pragma mark UIScrollView helpers

- (void)scrollToRight:(inout CGPoint *)targetContentOffset{
    targetContentOffset->x = [self utilityButtonsPadding];
    _cellState = kCellStateRight;
    
    self.longPressGestureRecognizer.enabled = NO;
    self.tapGestureRecognizer.enabled = NO;
    
    if ([_delegate respondsToSelector:@selector(swipeableTableViewCell:scrollingToState:)]) {
        [_delegate swipeableTableViewCell:self scrollingToState:kCellStateRight];
    }
}

- (void)scrollToCenter:(inout CGPoint *)targetContentOffset {
    targetContentOffset->x = [self leftUtilityButtonsWidth];
    _cellState = kCellStateCenter;
    
    self.longPressGestureRecognizer.enabled = YES;
    self.tapGestureRecognizer.enabled = NO;

    if ([_delegate respondsToSelector:@selector(swipeableTableViewCell:scrollingToState:)]) {
        [_delegate swipeableTableViewCell:self scrollingToState:kCellStateCenter];
    }
}

- (void)scrollToLeft:(inout CGPoint *)targetContentOffset{
    targetContentOffset->x = 0;
    _cellState = kCellStateLeft;
    
    self.longPressGestureRecognizer.enabled = NO;
    self.tapGestureRecognizer.enabled = NO;
    
    if ([_delegate respondsToSelector:@selector(swipeableTableViewCell:scrollingToState:)]) {
        [_delegate swipeableTableViewCell:self scrollingToState:kCellStateLeft];
    }
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    switch (_cellState) {
        case kCellStateCenter:
            if (velocity.x >= 0.5f) {
                [self scrollToRight:targetContentOffset];
            } else if (velocity.x <= -0.5f) {
                [self scrollToLeft:targetContentOffset];
            } else {
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
            if (velocity.x >= 0.5f) {
                [self scrollToCenter:targetContentOffset];
            } else if (velocity.x <= -0.5f) {
                // No-op
            } else {
                if (targetContentOffset->x >= ([self utilityButtonsPadding] - [self rightUtilityButtonsWidth] / 2))
                    [self scrollToRight:targetContentOffset];
                else if (targetContentOffset->x > [self leftUtilityButtonsWidth] / 2)
                    [self scrollToCenter:targetContentOffset];
                else
                    [self scrollToLeft:targetContentOffset];
            }
            break;
        case kCellStateRight:
            if (velocity.x >= 0.5f) {
                // No-op
            } else if (velocity.x <= -0.5f) {
                [self scrollToCenter:targetContentOffset];
            } else {
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!containingScrollViewIsScrolling) {
        self.containingTableView.scrollEnabled = NO;
        self.tapGestureRecognizer.enabled = NO;
        if (scrollView.contentOffset.x > [self leftUtilityButtonsWidth]) {
            // Expose the right button view
            self.scrollViewButtonViewRight.frame = CGRectMake(scrollView.contentOffset.x + (CGRectGetWidth(self.bounds) - [self rightUtilityButtonsWidth]), 0.0f, [self    rightUtilityButtonsWidth], _height);
        } else {
            // Expose the left button view
            self.scrollViewButtonViewLeft.frame = CGRectMake(scrollView.contentOffset.x, 0.0f, [self leftUtilityButtonsWidth], _height);
        }
    } else {
        self.containingTableView.scrollEnabled = YES;
        [scrollView setContentOffset:CGPointMake([self leftUtilityButtonsWidth], 0) animated:NO];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.tapGestureRecognizer.enabled = YES;
    self.containingTableView.scrollEnabled = YES;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    // Called when setContentOffset in hideUtilityButtonsAnimated: is done
    self.tapGestureRecognizer.enabled = YES;
    if (_cellState == kCellStateCenter) {
        self.containingTableView.scrollEnabled = YES;
        self.longPressGestureRecognizer.enabled = YES;
    }
}

#pragma mark - Class Methods

+ (void)setContainingTableViewIsScrolling:(BOOL)isScrolling {
    containingScrollViewIsScrolling = isScrolling;
}

@end
