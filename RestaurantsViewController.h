//
//  RestaurantsViewController.h
//  YelpAssignment
//
//  Created by Vikas Kumar Bajaj on 9/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FiltersViewController.h"

@interface RestaurantsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, FiltersViewControllerDelegate>

- (void) getBusinessesForSearchTerm: (NSString *) searchTerm withFilters: (NSDictionary *)filters;

@end
