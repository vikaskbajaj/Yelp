//
//  FiltersViewController.h
//  YelpAssignment
//
//  Created by Vikas Kumar Bajaj on 9/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Filters.h"

@class FiltersViewController;

@protocol FiltersViewControllerDelegate <NSObject>

- (void)didReceiveFilters:(NSDictionary *)searchFilters;

@end

@interface FiltersViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) Filters *filters;
@property (nonatomic, weak) id <FiltersViewControllerDelegate> delegate;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;


@end
