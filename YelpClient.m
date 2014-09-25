//
//  YelpClient.m
//  YelpAssignment
//
//  Created by Vikas Kumar Bajaj on 9/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "YelpClient.h"

@implementation YelpClient


- (id)initWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret accessToken:(NSString *)accessToken accessSecret:(NSString *)accessSecret {
    NSURL *baseURL = [NSURL URLWithString:@"http://api.yelp.com/v2/"];
    self = [super initWithBaseURL:baseURL consumerKey:consumerKey consumerSecret:consumerSecret];
    if (self) {
        BDBOAuthToken *token = [BDBOAuthToken tokenWithToken:accessToken secret:accessSecret expiration:nil];
        [self.requestSerializer saveAccessToken:token];
    }
    return self;
}

- (AFHTTPRequestOperation *)search:(NSString *)term withFilters:(NSDictionary *)filters success:(void (^)(AFHTTPRequestOperation *operation, id response))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    // For additional parameters, see http://www.yelp.com/developers/documentation/v2/search_api
    NSMutableDictionary *mutualableFiltersDic = [NSMutableDictionary dictionaryWithDictionary:filters];
    [mutualableFiltersDic setObject:term forKey:@"term"];
    [mutualableFiltersDic setObject:@"San Francisco" forKey:@"location"];
    
    
    NSLog(@"### Term %@ with ##################################### parameters are %@", term, filters);
    
    return [self GET:@"search" parameters:[NSDictionary dictionaryWithDictionary:mutualableFiltersDic] success:success failure:failure];
}

@end