//
//  UITableViewCell+FixUITableViewCellAutolayoutIHope.m
//  CTClient
//
//  Created by Philip Jacobsen on 5/21/14.
//  Copyright (c) 2014 CrowdTunes LLC. All rights reserved.
//

#import <objc/runtime.h>
#import <objc/message.h>
#import "UITableViewCell+FixUITableViewCellAutolayout.h"

// See http://stackoverflow.com/questions/12610783/auto-layout-still-required-after-executing-layoutsubviews-with-uitableviewcel

@implementation UITableViewCell (FixUITableViewCellAutolayout)

+ (void)load
{
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        Method existing = class_getInstanceMethod(self, @selector(layoutSubviews));
        Method new = class_getInstanceMethod(self, @selector(_autolayout_replacementLayoutSubviews));
        
        method_exchangeImplementations(existing, new);
    }
}

- (void)_autolayout_replacementLayoutSubviews
{
    [super layoutSubviews];
    [self _autolayout_replacementLayoutSubviews]; // not recursive due to method swizzling
    [super layoutSubviews];
}

@end
