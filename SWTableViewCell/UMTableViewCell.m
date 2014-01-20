//
//  UMTableViewCell.m
//  SWTableViewCell
//
//  Created by Matt Bowman on 12/2/13.
//  Copyright (c) 2013 Chris Wendel. All rights reserved.
//

#import "UMTableViewCell.h"

@implementation UMTableViewCell

-(IBAction)buttonClick:(id)sender
{
    NSLog(@"buttonClick");
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:@"button clicked" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

@end
