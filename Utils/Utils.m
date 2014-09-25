//
//  Utils.m
//  YelpAssignment
//
//  Created by Vikas Kumar Bajaj on 9/24/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "Utils.h"
#import "Colours.h"

@implementation Utils

+(UIButton *) getStandardUIButtonWithTitle: (NSString *) title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [button setBackgroundColor:[UIColor colorFromHexString:@"#c41200"]];
    [button.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [button.layer setBorderWidth:0.25f];
    [button.layer setCornerRadius:4.0f];
    
    return button;
}
@end
