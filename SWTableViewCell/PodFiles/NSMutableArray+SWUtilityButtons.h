//
//  NSMutableArray+SWUtilityButtons.h
//  SWTableViewCell
//
//  Created by Matt Bowman on 11/27/13.
//  Copyright (c) 2013 Chris Wendel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (SWUtilityButtons)

- (void)sw_addUtilityButtonWithColor:(UIColor *)color title:(NSString *)title;
- (void)sw_addUtilityButtonWithColor:(UIColor *)color icon:(UIImage *)icon;

@end
