//
//  SWCellScrollView.m
//  SWTableViewCell
//
//  Created by Matt Bowman on 11/27/13.
//  Copyright (c) 2013 Chris Wendel. All rights reserved.
//

#import "SWCellScrollView.h"
#import "SWTableViewCell.h"

@implementation SWCellScrollView

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.panGestureRecognizer) {
        CGPoint translation = [(UIPanGestureRecognizer*)gestureRecognizer translationInView:gestureRecognizer.view];
		if(fabs(translation.y) <= fabs(translation.x))
		{
			if ([self.cell.delegate respondsToSelector:@selector(swipeableTableViewCell:canSwipeToState:)])
				return [self.cell.delegate swipeableTableViewCell:(SWTableViewCell *)self.superview canSwipeToState:(translation.x > 0 ? kCellStateLeft : kCellStateRight)];
			else
				return YES;
		}
		else
			return NO;
    } else {
        return YES;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // Find out if the user is actively scrolling the tableView of which this is a member.
    // If they are, return NO, and don't let the gesture recognizers work simultaneously.
    //
    // This works very well in maintaining user expectations while still allowing for the user to
    // scroll the cell sideways when that is their true intent.
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        
        // Find the current scrolling velocity in that view, in the Y direction.
        CGFloat yVelocity = [(UIPanGestureRecognizer*)gestureRecognizer velocityInView:gestureRecognizer.view].y;
        
        // Return YES iff the user is not actively scrolling up.
        return fabs(yVelocity) <= 0.25;
        
    }
    return YES;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
	return YES;
}

@end

