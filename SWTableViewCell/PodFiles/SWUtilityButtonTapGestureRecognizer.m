//
//  SWUtilityButtonTapGestureRecognizer.m
//  SWTableViewCell
//
//  Created by Matt Bowman on 11/27/13.
//  Copyright (c) 2013 Chris Wendel. All rights reserved.
//

#import "SWUtilityButtonTapGestureRecognizer.h"

@implementation SWUtilityButtonTapGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    self.state = UIGestureRecognizerStateBegan;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.state = UIGestureRecognizerStateEnded;
}



@end

