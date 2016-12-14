//
//  SWUtilityButtonView.m
//  SWTableViewCell
//
//  Created by Matt Bowman on 11/27/13.
//  Copyright (c) 2013 Chris Wendel. All rights reserved.
//

#import "SWUtilityButtonView.h"
#import "SWUtilityButtonTapGestureRecognizer.h"

static CGFloat const kCBSwipeCellUtilityButtonConstraintPadding = 1.0;

@interface SWUtilityButtonView()

@property (nonatomic, strong) NSLayoutConstraint *widthConstraint;
@property (nonatomic, strong) NSMutableArray *buttonBackgroundColors;

@end

@implementation SWUtilityButtonView

#pragma mark - SWUtilityButonView initializers

- (id)initWithUtilityButtons:(NSArray *)utilityButtons parentCell:(SWTableViewCell *)parentCell utilityButtonSelector:(SEL)utilityButtonSelector
{
    self = [self initWithFrame:CGRectZero utilityButtons:utilityButtons parentCell:parentCell utilityButtonSelector:utilityButtonSelector];
    
    return self;
}

- (id)initWithFrame:(CGRect)frame utilityButtons:(NSArray *)utilityButtons parentCell:(SWTableViewCell *)parentCell utilityButtonSelector:(SEL)utilityButtonSelector
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.widthConstraint = [NSLayoutConstraint constraintWithItem:self
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.0
                                                             constant:0.0]; // constant will be adjusted dynamically in -setUtilityButtons:.
        self.widthConstraint.priority = UILayoutPriorityDefaultHigh;
        [self addConstraint:self.widthConstraint];
        
        _parentCell = parentCell;
        self.utilityButtonSelector = utilityButtonSelector;
        self.utilityButtons = utilityButtons;
    }
    
    return self;
}

#pragma mark Populating utility buttons

- (void)setUtilityButtons:(NSArray *)utilityButtons
{
    // if no width specified, use the default width
    [self setUtilityButtons:utilityButtons WithButtonWidth:kUtilityButtonWidthDefault];
}

- (void)setUtilityButtons:(NSArray *)utilityButtons WithButtonWidth:(CGFloat)width
{
    for (UIButton *button in _utilityButtons)
    {
        [button removeFromSuperview];
    }
    
    _utilityButtons = [utilityButtons copy];
    
    if (utilityButtons.count)
    {
        NSUInteger utilityButtonsCounter = 0;
        UIView *precedingView = nil;
        
        for (UIButton *button in _utilityButtons)
        {
            [self addSubview:button];
            button.translatesAutoresizingMaskIntoConstraints = NO;
            
            if (!precedingView)
            {
                // First button; pin it to the left edge.
                [self addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:kCBSwipeCellUtilityButtonConstraintPadding]];
            }
            else
            {
                // Subsequent button; pin it to the right edge of the preceding one, with equal width.
                [self addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:precedingView
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:1.0
                                                                  constant:0.0]];
                [self addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:precedingView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:kCBSwipeCellUtilityButtonConstraintPadding]];
            }
            //luquan: Changed to place a 1px vertical constraint on the top and bottom of each button
            [self addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1.0
                                                              constant:kCBSwipeCellUtilityButtonConstraintPadding]];

            [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                             attribute:NSLayoutAttributeBottom
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:button
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1.0
                                                              constant:kCBSwipeCellUtilityButtonConstraintPadding + 1]]; // +1 to account for the height of the seperator view
            
            SWUtilityButtonTapGestureRecognizer *utilityButtonTapGestureRecognizer = [[SWUtilityButtonTapGestureRecognizer alloc] initWithTarget:_parentCell action:_utilityButtonSelector];
            utilityButtonTapGestureRecognizer.buttonIndex = utilityButtonsCounter;
            [button addGestureRecognizer:utilityButtonTapGestureRecognizer];
            
            utilityButtonsCounter++;
            precedingView = button;
        }
        
        // Pin the last button to the right edge.
        [self addConstraint:[NSLayoutConstraint constraintWithItem:precedingView
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0
                                                          constant:kCBSwipeCellUtilityButtonConstraintPadding]];
    }
    
    self.widthConstraint.constant = (width * utilityButtons.count);
    
    [self setNeedsLayout];
    
    return;
}

#pragma mark -

- (void)pushBackgroundColors
{
    self.buttonBackgroundColors = [[NSMutableArray alloc] init];
    
    for (UIButton *button in self.utilityButtons)
    {
        [self.buttonBackgroundColors addObject:button.backgroundColor];
    }
}

- (void)popBackgroundColors
{
    NSEnumerator *e = self.utilityButtons.objectEnumerator;
    
    for (UIColor *color in self.buttonBackgroundColors)
    {
        UIButton *button = [e nextObject];
        button.backgroundColor = color;
    }
    
    self.buttonBackgroundColors = nil;
}

@end

