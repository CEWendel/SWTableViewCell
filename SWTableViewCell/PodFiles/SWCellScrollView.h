//
//  SWCellScrollView.h
//  SWTableViewCell
//
//  Created by Matt Bowman on 11/27/13.
//  Copyright (c) 2013 Chris Wendel. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SWTableViewCell;

@interface SWCellScrollView : UIScrollView <UIGestureRecognizerDelegate>

@property (nonatomic, weak) SWTableViewCell *cell;
@end
