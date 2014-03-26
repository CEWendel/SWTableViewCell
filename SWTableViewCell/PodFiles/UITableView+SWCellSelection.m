//
//  UITableView+SWCellSelection.m
//  SWTableViewCell
//
//  Created by Matt Nunes on 3/3/14.
//  Copyright (c) 2014 Matt Nunes. All rights reserved.
//

#import "UITableView+SWCellSelection.h"

@implementation UITableView (SWCellSelection)

- (BOOL)sw_deselectRowAtIndexPath:(NSIndexPath *)indexPath withAnimation:(BOOL)animation
{
    NSIndexPath *indexPathToDeselect = indexPath;
    
    // Ask the delegate what index path to actually deselect.
    // It may return selectedIndexPath, another index path, or nil.
    if ([self.delegate respondsToSelector:@selector(tableView:willDeselectRowAtIndexPath:)]) {
        indexPathToDeselect = [self.delegate tableView:self willDeselectRowAtIndexPath:indexPathToDeselect];
    }
    
    // If the indexPath isn't nil, we can deselect that cell in preparation
    // for selecting the current cell.
    if (indexPathToDeselect) {
        [self deselectRowAtIndexPath:indexPathToDeselect animated:animation];
        
        if ([self.delegate respondsToSelector:@selector(tableView:didDeselectRowAtIndexPath:)]) {
            [self.delegate tableView:self didDeselectRowAtIndexPath:indexPathToDeselect];
        }
        
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)sw_selectRowAtIndexPath:(NSIndexPath *)indexPath withAnimation:(BOOL)animation
{
    if (![self allowsMultipleSelection]) {
        // If multiple selection is not allowed, we will need to
        // de-select the previously selected cell.
        NSIndexPath *selectedIndexPath = [self indexPathForSelectedRow];
        if (selectedIndexPath) {
            // BUT, if we cannot deselect the previously selected cell,
            // then we cannot continue on with this selection operation.
            if (![self sw_deselectRowAtIndexPath:selectedIndexPath withAnimation:animation]) {
                return NO; // - - - - - EARLY RETURN - - - - -
            }
        }
    }
    
    NSIndexPath *indexPathToSelect = indexPath;
    if ([self.delegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)]) {
        indexPathToSelect = [self.delegate tableView:self willSelectRowAtIndexPath:indexPathToSelect];
    }
    
    if (indexPathToSelect) {
        [self selectRowAtIndexPath:indexPathToSelect animated:animation scrollPosition:UITableViewScrollPositionNone];
        
        if ([self.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
            [self.delegate tableView:self didSelectRowAtIndexPath:indexPathToSelect];
        }
        
        return YES;
    }
    else {
        return NO;
    }
}

@end
