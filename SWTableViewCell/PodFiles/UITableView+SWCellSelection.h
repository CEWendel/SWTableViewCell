//
//  UITableView+SWCellSelection.h
//  SWTableViewCell
//
//  Created by Matt Nunes on 3/3/14.
//  Copyright (c) 2014 Matt Nunes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (SWCellSelection)

/**
 * Attempts to deselect the row at the given @p indexPath
 * with animation.
 * @discussion This method calls the @p UITableViewDelegate
 * method @p tableView:willDeselectRowAtIndexPath: if
 * the table view's delegate implements it, and then 
 * attempts to deselect the returned indexPath. If that method
 * returns @p nil, then no deselection will occur and the method
 * will return @p NO. Otherwise, deselection will occur
 * and the method will exit returning YES.
 * @param indexPath The index path to attempt to deselect.
 * @param Whether or not to animate the deselection.
 * @returns Whether or not deselection was successful.
 */
- (BOOL)sw_deselectRowAtIndexPath:(NSIndexPath *)indexPath withAnimation:(BOOL)animation;

/**
 * Attempts to select the row at the given @p indexPath
 * with animation and @p UITableViewScrollPositionNone.
 * @discussion 
 * If the table view does not allow multiple selection,
 * then this method first attemps to deselect the currently
 * selected cell using @p deselectRowAtIndexPath:. If that
 * method is unsuccessful and returns @p NO, then this method
 * will also return @p NO immediately.
 *
 * Assuming that that method succeeds, then this method calls
 * the @p UITableViewDelegate method 
 * @p tableView:willSelectRowAtIndexPath: if
 * the table view's delegate implements it, and then
 * attempts to select the returned indexPath. If that method
 * returns @p nil, then no selection will occur and the method
 * will return @p NO. Otherwise, selection will occur
 * and the method will exit returning YES.
 * @param indexPath The index path to attempt to select.
 * @param Whether or not to animate the selection.
 * @returns Whether or not selection was successful.
 */
- (BOOL)sw_selectRowAtIndexPath:(NSIndexPath *)indexPath withAnimation:(BOOL)animation;

@end
