//
//  NSObject+PerformSelector.m
//  SWTableViewCell
//
//  Created by Colin Regan on 7/22/14.
//  Copyright (c) 2014 Chris Wendel. All rights reserved.
//

#import "NSObject+PerformSelector.h"

@implementation NSObject (PerformSelector)

- (void)performSelectorOnNextRunLoopCycle:(SEL)aSelector withObjects:(NSArray *)args
{
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:aSelector]];
    [invocation setSelector:aSelector];
    [invocation setTarget:self];
    [args enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [invocation setArgument:&obj atIndex:(idx + 2)];
    }];
    [invocation retainArguments];
    
    [invocation performSelector:@selector(invoke) withObject:nil afterDelay:0];
}

@end
