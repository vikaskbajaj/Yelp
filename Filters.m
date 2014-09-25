//
//  Filters.m
//  YelpAssignment
//
//  Created by Vikas Kumar Bajaj on 9/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "Filters.h"

@implementation Filters

+ (id) singletonObject {
    
    static Filters *filters = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        filters = [[self alloc] init];
    });
    
    return filters;
}

-(id) init {
    self = [super init];
    if (self) {
        
        self.defaultFilters = [[NSMutableDictionary alloc] init];
        
        self.mostPopularFilters = @[@{@"name": @"Offering a Deal",
                                      @"yelpkey" : @"deals_filter",
                                      @"valuetype" : @"boolean",
                                      @"value": @(NO)}];
        
        self.distanceOptions = @[@{@"name": @"Auto",
                                   @"yelpkey" : @"radius_filter",
                                   @"value" : @"10", //need to add logic to handle "auto" string value
                                   @"valuetype": @"string"
                                   },
                                 @{@"name" : @"0.3 miles",
                                   @"yelpkey" : @"radius_filter",
                                   @"value" : @"500",
                                   @"valuetype": @"string"
                                   },
                                 @{@"name" : @"1 mile",
                                   @"yelpkey" : @"radius_filter",
                                   @"value" : @"1600",
                                   @"valuetype": @"string"
                                   },
                                 @{@"name" : @"5 miles",
                                   @"yelpkey" : @"radius_filter",
                                   @"value" : @"8000",
                                   @"valuetype": @"string"
                                   },
                                 @{@"name" : @"20 miles",
                                   @"yelpkey" : @"radius_filter",
                                   @"value" : @"33000",
                                   @"valuetype": @"string"
                                   }
                                 ];

        self.sortOptions = @[@{@"name": @"Best Match",
                                   @"yelpkey" : @"sort",
                                   @"value" : @(0),
                                   @"valuetype": @"number"
                                   },
                                 @{@"name" : @"Distance",
                                   @"yelpkey" : @"sort",
                                   @"value" : @(1),
                                   @"valuetype": @"number"
                                   },
                                 @{@"name" : @"Highest Rated",
                                   @"yelpkey" : @"sort",
                                   @"value" : @(2),
                                   @"valuetype": @"number"
                                   }
                                 ];

        self.filterGroups = @[@{@"title": @"Most Popular",
                           @"data": self.mostPopularFilters,
                           @"options" : @"individual"
                           },
                           @{@"title": @"Distance",
                           @"data": self.distanceOptions,
                           @"options" : @"group"
                           },
                         @{@"title": @"Sort by",
                           @"data": self.sortOptions,
                           @"options" : @"group"
                           }
                        ];
        
        [self.defaultFilters setObject:@(NO) forKey:@"deals_filter"];
        [self.defaultFilters setObject:@"10" forKey:@"radius_filter"];
        [self.defaultFilters setObject:@(1) forKey:@"sort"];

    }
    return self;
}

-(NSDictionary *) getLastSavedFilters {
    NSUserDefaults *userDefaults =  [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"yelpFilters"] != nil) {
        NSDictionary *filtersFromUserDefaults = [userDefaults objectForKey:@"yelpFilters"];
        return [NSDictionary dictionaryWithDictionary:filtersFromUserDefaults];
    } else {
        return self.defaultFilters;
    }
}

@end
