//
//  SWAccessibilityCustomAction.h
//  SWTableViewCell
//
//  Created by Boris Dušek on 4/25/15.
//  Copyright (c) 2015 Chris Wendel. All rights reserved.
//

#import <UIKit/UIKit.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
@interface SWAccessibilityCustomAction : UIAccessibilityCustomAction

@property(nonatomic, assign) BOOL right;
@property(nonatomic, assign) NSInteger index;

@end
#endif
