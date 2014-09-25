//
//  RestaurantCell.h
//  YelpAssignment
//
//  Created by Vikas Kumar Bajaj on 9/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RestaurantCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UILabel *categories;
@property (weak, nonatomic) IBOutlet UILabel *distance;
@property (weak, nonatomic) IBOutlet UIImageView *restaurantImage;
@property (weak, nonatomic) IBOutlet UIImageView *ratings;
@property (weak, nonatomic) IBOutlet UILabel *ratingsLabel;

@end
