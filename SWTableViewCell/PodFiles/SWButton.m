//
//  SWButton.m
//  SWTableViewCell
//
//  Created by Matt Nunes on 3/3/14.
//  Copyright (c) 2014 Chris Wendel. All rights reserved.
//

#import "SWButton.h"
#import "SWTableViewCell.h"

@implementation SWButton

- (SWTableViewCell *)parentCell
{
    SWTableViewCell *parentCell = nil;
    UIView *iterationView = self;
    
    do {
        iterationView = [iterationView superview];
        if ([iterationView isKindOfClass:[SWTableViewCell class]]) {
            parentCell = (SWTableViewCell *)iterationView;
        }
    } while (iterationView && !parentCell);
    
    return parentCell;
}

-(void)setBackgroundColor:(UIColor *)backgroundColor {
    SWTableViewCell *parentCell = [self parentCell];
    
    if ([parentCell isHighlighted] || [parentCell isSelected]) {
        // Don't change the background color, since
        // most likely it's being changed to blend in
        // with the highlight/selection state of the cell.
    }
    else {
        [super setBackgroundColor:backgroundColor];
    }
}

@end
