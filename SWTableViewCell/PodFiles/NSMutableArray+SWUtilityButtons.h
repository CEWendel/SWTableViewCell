//
//  NSMutableArray+SWUtilityButtons.h
//  SWTableViewCell
//
//  Created by Matt Bowman on 11/27/13.
//  Copyright (c) 2013 Chris Wendel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSMutableArray (SWUtilityButtons)

- (UIButton*)sw_addUtilityButtonWithColor:(UIColor *)color title:(NSString *)title;
- (UIButton*)sw_addUtilityButtonWithColor:(UIColor *)color icon:(UIImage *)icon;
- (UIButton*)sw_addUtilityButtonWithColor:(UIColor *)color normalIcon:(UIImage *)normalIcon selectedIcon:(UIImage *)selectedIcon;

@end
