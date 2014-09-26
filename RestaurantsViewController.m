//
//  RestaurantsViewController.m
//  YelpAssignment
//
//  Created by Vikas Kumar Bajaj on 9/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "RestaurantsViewController.h"
#import "YelpClient.h"
#import "RestaurantCell.h"
#import "UIImageView+AFNetworking.h"
#import "FiltersViewController.h"
#import "Filters.h"
#import "Colours.h"
#import "Utils.h"
#import "SVProgressHUD.h"


NSString * const kYelpConsumerKey = @"vxKwwcR_NMQ7WaEiQBK_CA";
NSString * const kYelpConsumerSecret = @"33QCvh5bIF5jIHR5klQr7RtBDhQ";
NSString * const kYelpToken = @"uRcRswHFYa1VkDrGV6LAW2F8clGh5JHV";
NSString * const kYelpTokenSecret = @"mqtKIxMIR4iBtBPZCmCLEb-Dz3Y";

@interface RestaurantsViewController ()

@property(strong, nonatomic) YelpClient *yelpClient;
@property (strong, nonatomic) NSMutableArray *yelpResponse;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) Filters *filters;
@property (strong, nonatomic) NSString *term;

@end

@implementation RestaurantsViewController

- (void) getBusinessesForSearchTerm:(NSString *)searchTerm withFilters:(NSDictionary *)filters {
    [SVProgressHUD showWithStatus:@"Searching" maskType:SVProgressHUDMaskTypeNone];
    if (self.yelpClient == nil) {
        self.yelpClient = [[YelpClient alloc] initWithConsumerKey:kYelpConsumerKey consumerSecret:kYelpConsumerSecret accessToken:kYelpToken accessSecret:kYelpTokenSecret];
    }
    [self.yelpClient search:searchTerm withFilters:filters success:^(AFHTTPRequestOperation *operation, id response) {
        [self.yelpResponse addObjectsFromArray:[(NSDictionary *)response objectForKey:@"businesses"]];
        NSLog(@"Response received for search term %@ having count as %ld", searchTerm, self.yelpResponse.count);
        [SVProgressHUD dismiss];
        [self.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", [error description]);
    }];
}

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.filters = [Filters singletonObject];
        self.term = @"";
        self.yelpResponse = [[NSMutableArray alloc] init];
        [self getBusinessesForSearchTerm:self.term withFilters:[self.filters getLastSavedFilters]];
    }
    return self;
}


-(void) didReceiveFilters:(NSDictionary *)searchFilters {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:searchFilters forKey:@"yelpFilters"];
    [userDefaults synchronize];
    
    [self.yelpResponse removeAllObjects];
    [self getBusinessesForSearchTerm:self.term withFilters:searchFilters];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.yelpResponse.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellID = @"RestaurantCell";
    RestaurantCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[RestaurantCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    NSDictionary *restaurant = self.yelpResponse[indexPath.row];
    
    NSString *restaurantIndex = [NSString stringWithFormat:@"%ld", (indexPath.row + 1)];
    NSString *restaurantName = restaurant[@"name"];
    
    //NSLog(@"Distance value is %f", distanceInMeters);
    
    cell.name.text = [NSString stringWithFormat:@"%@. %@", restaurantIndex, restaurantName];
    cell.address.text = [restaurant valueForKeyPath:@"location.display_address"][0];
    cell.ratingsLabel.text = [NSString stringWithFormat:@"%@ reviews", restaurant[@"review_count"]];
    
    //Yelp colors
    cell.name.textColor = [UIColor colorFromHexString:@"#333"];
    cell.address.textColor = [UIColor colorFromHexString:@"#999999"];
    
    NSString *imageURL = restaurant[@"image_url"];
    NSString *ratingsURL = restaurant[@"rating_img_url"];
    
    [cell.restaurantImage setImageWithURL:[NSURL URLWithString: imageURL]];
    [cell.ratings setImageWithURL:[NSURL URLWithString: ratingsURL]];
    
    return cell;
    
}

-(void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchDisplayController.searchBar resignFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"RestaurantCell" bundle:nil] forCellReuseIdentifier:@"RestaurantCell"];
    
    UISearchBar *searchBar =  [[UISearchBar alloc] init];
    [searchBar setShowsCancelButton:NO];
    searchBar.delegate = self;
    
    UISearchDisplayController *searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    
    searchController.delegate = self;
    searchController.searchResultsDataSource = self;
    searchController.searchResultsDelegate = self;
    
    self.navigationItem.titleView = searchBar;

    //Yelp colors
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor colorFromHexString:@"#c41200"];
    
    // Filter button
    UIButton *filterButton = [Utils getStandardUIButtonWithTitle:@"Filter"];
    filterButton.frame=CGRectMake(0.0, 100.0, 70.0, 30.0);
    [filterButton addTarget:self action:@selector(onFilterButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *filterButtonItem = [[UIBarButtonItem alloc] initWithCustomView:filterButton];
    
    self.navigationItem.leftBarButtonItem = filterButtonItem;
    
    [self.tableView reloadData];
    
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.term = searchBar.text;
    [self.yelpResponse removeAllObjects];
    [self.searchDisplayController.searchBar resignFirstResponder];
    [self getBusinessesForSearchTerm:self.term withFilters:[self.filters getLastSavedFilters]];
}

- (void) onFilterButtonClicked: (id) sender {
    FiltersViewController *filterController = [[FiltersViewController alloc] initWithNibName:@"FiltersViewController" bundle:nil];
    filterController.delegate = self;
    
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:filterController];
    navController.navigationBar.tintColor =[UIColor whiteColor];
    navController.navigationBar.barTintColor = [UIColor colorFromHexString:@"#c41200"];

    [self presentViewController:navController animated:YES completion:nil];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellID = @"RestaurantCell";
    RestaurantCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[RestaurantCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    NSDictionary *restaurant = self.yelpResponse[indexPath.row];
    
    NSString *restaurantIndex = [NSString stringWithFormat:@"%ld", (indexPath.row + 1)];
    NSString *restaurantName = restaurant[@"name"];
    
    cell.name.text = [NSString stringWithFormat:@"%@. %@", restaurantIndex, restaurantName];
    cell.address.text = [restaurant valueForKeyPath:@"location.display_address"][0];
    cell.ratingsLabel.text = [NSString stringWithFormat:@"%@ reviews", restaurant[@"review_count"]];
    
    //Yelp colors
    cell.name.textColor = [UIColor colorFromHexString:@"#333"];
    cell.address.textColor = [UIColor colorFromHexString:@"#999999"];
    
    NSString *imageURL = restaurant[@"image_url"];
    NSString *ratingsURL = restaurant[@"rating_img_url"];
    
    [cell.restaurantImage setImageWithURL:[NSURL URLWithString: imageURL]];
    [cell.ratings setImageWithURL:[NSURL URLWithString: ratingsURL]];
    
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *) cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == ([self.yelpResponse count] - 1))
    {
        [self getBusinessesForSearchTerm:self.term withFilters:[self.filters getLastSavedFilters]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
