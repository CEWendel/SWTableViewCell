//
//  NSObject+PerformSelector.h
//  SWTableViewCell
//
//  Created by Colin Regan on 7/22/14.
//  Copyright (c) 2014 Chris Wendel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (PerformSelector)

/**
 *  Performs the specified selector on the current thread during the next run loop cycle.
 *
 *  @param aSelector A selector that identifies the method to invoke. The method should not have a significant return value and should take the same number of arguments that are included in the `args` array.
 *  @param args The arguments to pass to the method when it is invoked. Pass nil if the method does not take any arguments.
 *
 *  @discussion This method enqueues the `aSelector` message on the run loop of the current thread. This is useful in cases where it's not desireable to group multiple view drawing operations into the same drawing cycle. Using this method will cause the selector to be invoked as soon as possible, but on the next run loop cycle.
 */
- (void)performSelectorOnNextRunLoopCycle:(SEL)aSelector withObjects:(NSArray *)args;

@end
