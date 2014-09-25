//
//  Filters.h
//  YelpAssignment
//
//  Created by Vikas Kumar Bajaj on 9/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Filters : NSObject

@property (nonatomic) NSArray *distanceOptions;
@property (nonatomic) NSArray *mostPopularFilters;
@property (nonatomic) NSArray *sortOptions;

@property (nonatomic) NSMutableDictionary *defaultFilters;

@property (nonatomic) NSArray *filterGroups;


+(id) singletonObject;

-(NSDictionary *) getLastSavedFilters;

@end
