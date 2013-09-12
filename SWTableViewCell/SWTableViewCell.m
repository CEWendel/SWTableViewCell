//
//  SWTableViewCell.m
//  SWTableViewCell
//
//  Created by Chris Wendel on 9/10/13.
//  Copyright (c) 2013 Chris Wendel. All rights reserved.
//

#import "SWTableViewCell.h"
#import "SWUtilityButton.h"

#define kUtilityButtonWidth 80

typedef enum {
    kCellStateCenter,
    kCellStateLeft,
    kCellStateRight
} SWCellState;

#pragma mark - SWUtilityButtonView

@interface SWUtilityButtonView : UIView

@property (nonatomic, strong) NSArray *utilityButtons;

- (id)initWithFrame:(CGRect)frame utilityButtons:(NSArray *)utilityButtons;

- (id)initWithUtilityButtons:(NSArray *)utilityButtons;

@end

@implementation SWUtilityButtonView

#pragma mark - SWUtilityButonView initializers

- (id)initWithUtilityButtons:(NSArray *)utilityButtons {
    self = [super init];
    
    if (self) {
        self.utilityButtons = utilityButtons;
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame utilityButtons:(NSArray *)utilityButtons {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.utilityButtons = utilityButtons;
    }
    
    return self;
}

- (CGFloat)utilityButtonsWidth {
    return (_utilityButtons.count * kUtilityButtonWidth);
}

- (void)populateUtilityButtons {
    NSUInteger utilityButtonsCount = _utilityButtons.count;
    NSUInteger utilityButtonsCounter = _utilityButtons.count;
    for (SWUtilityButton *utilityButton in _utilityButtons) {
        CGFloat utilityButtonXCord = 0;
        if (utilityButtonsCounter > 0) utilityButtonXCord = [self utilityButtonsWidth] / utilityButtonsCounter;
        [utilityButton setFrame:CGRectMake(utilityButtonXCord, 0, [self utilityButtonsWidth] / utilityButtonsCount, CGRectGetHeight(self.bounds))];
        [self addSubview:utilityButton];
        utilityButtonsCounter--;
    }
}

@end

@interface SWTableViewCell () <UIScrollViewDelegate> {
    SWCellState _cellState;
}

// Scroll view to be added to UITableViewCell
@property (nonatomic, weak) UIScrollView *cellScrollView;

// Views that live in the scroll view
@property (nonatomic, weak) UIView *scrollViewContentView;
@property (nonatomic, weak) SWUtilityButtonView *scrollViewButtonViewLeft;
@property (nonatomic, weak) SWUtilityButtonView *scrollViewButtonViewRight;

@end

@implementation SWTableViewCell

#pragma mark Initializers

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
    leftUtilityButtons:(NSArray *)leftUtilityButtons
    rightUtilityButtons:(NSArray *)rightUtilityButtons {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.rightUtilityButtons = rightUtilityButtons;
        self.leftUtilityButtons = leftUtilityButtons;
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
    // Set up scroll view that will host our cell content
    UIScrollView *cellScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
    cellScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds) + [self utilityButtonsPadding], CGRectGetHeight(self.bounds));
    cellScrollView.contentOffset = [self scrollViewContentOffset];
    cellScrollView.delegate = self;
    cellScrollView.showsHorizontalScrollIndicator = NO;
    
    self.cellScrollView = cellScrollView;
    
    // Set up the views that will hold the utility buttons
    SWUtilityButtonView *scrollViewButtonViewLeft = [[SWUtilityButtonView alloc] initWithUtilityButtons:_leftUtilityButtons];
    CGFloat leftUtilityButtonsWidth = [scrollViewButtonViewLeft utilityButtonsWidth];
    [scrollViewButtonViewLeft setFrame:CGRectMake(leftUtilityButtonsWidth, 0, leftUtilityButtonsWidth, CGRectGetHeight(self.bounds))];
    self.scrollViewButtonViewLeft = scrollViewButtonViewLeft;
    [self.cellScrollView addSubview:scrollViewButtonViewLeft];
    
    SWUtilityButtonView *scrollViewButtonViewRight = [[SWUtilityButtonView alloc] initWithUtilityButtons:_rightUtilityButtons];
    CGFloat rightUtilityButtonsWidth = [scrollViewButtonViewRight utilityButtonsWidth];
    [scrollViewButtonViewRight setFrame:CGRectMake(CGRectGetWidth(self.bounds), 0, rightUtilityButtonsWidth, CGRectGetHeight(self.bounds))];
    self.scrollViewButtonViewRight = scrollViewButtonViewRight;
    [self.cellScrollView addSubview:scrollViewButtonViewRight];
    
    // Populate the button views with utility buttons
    [scrollViewButtonViewLeft populateUtilityButtons];
    [scrollViewButtonViewRight populateUtilityButtons];
    
    // Create the content view that will live in our scroll view
    UIView *scrollViewContentView = [[UIView alloc] initWithFrame:CGRectMake([scrollViewButtonViewLeft utilityButtonsWidth], 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
    [self.cellScrollView addSubview:scrollViewContentView];
    self.scrollViewContentView = scrollViewContentView;
    
    // Add the cell scroll view to the cell
    NSArray *cellSubviews = self.subviews;
    [self insertSubview:cellScrollView aboveSubview:0];
    for (UIView *subview in cellSubviews) {
        [self.scrollViewContentView addSubview:subview];
    }
}


#pragma mark - Setup helpers

- (CGFloat)utilityButtonsPadding {
    return ([_scrollViewButtonViewLeft utilityButtonsWidth] + [_scrollViewButtonViewRight utilityButtonsWidth]);
}

- (CGPoint)scrollViewContentOffset {
    return CGPointMake([_scrollViewButtonViewLeft utilityButtonsWidth], 0);
}

@end
