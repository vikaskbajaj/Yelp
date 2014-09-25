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
@property (weak, nonatomic) Filters *filters;

@end

@implementation RestaurantsViewController

- (void) getBusinessesForSearchTerm:(NSString *)searchTerm withFilters:(NSDictionary *)filters {
    [SVProgressHUD showWithStatus:@"Searching" maskType:SVProgressHUDMaskTypeNone];
    if (self.yelpClient == nil) {
        self.yelpClient = [[YelpClient alloc] initWithConsumerKey:kYelpConsumerKey consumerSecret:kYelpConsumerSecret accessToken:kYelpToken accessSecret:kYelpTokenSecret];
    }
    [self.yelpClient search:searchTerm withFilters:filters success:^(AFHTTPRequestOperation *operation, id response) {
        
        [self.yelpResponse removeAllObjects];
        self.yelpResponse = [[(NSDictionary *)response objectForKey:@"businesses"] mutableCopy];
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
        
        [self getBusinessesForSearchTerm:@"American" withFilters:[self.filters getLastSavedFilters]];
    }
    return self;
}

-(void) didReceiveFilters:(NSDictionary *)searchFilters {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:searchFilters forKey:@"yelpFilters"];
    [userDefaults synchronize];
    
    [self getBusinessesForSearchTerm:@"American" withFilters:searchFilters];
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
    
    cell.name.text = [NSString stringWithFormat:@"%@. %@", restaurantIndex, restaurantName];
    cell.address.text = [restaurant valueForKeyPath:@"location.display_address"][0];
    
    //Yelp colors
    cell.name.textColor = [UIColor colorFromHexString:@"#333"];
    cell.address.textColor = [UIColor colorFromHexString:@"#999999"];
    
    NSString *imageURL = restaurant[@"image_url"];
    NSString *ratingsURL = restaurant[@"rating_img_url_small"];
    
    [cell.restaurantImage setImageWithURL:[NSURL URLWithString: imageURL]];
    [cell.ratings setImageWithURL:[NSURL URLWithString: ratingsURL]];
    
    return cell;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
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
    
    //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(onFilterButtonClicked:)];
    
    // Filter button
    UIButton *filterButton = [Utils getStandardUIButtonWithTitle:@"Filter"];
    filterButton.frame=CGRectMake(0.0, 100.0, 70.0, 30.0);
    [filterButton addTarget:self action:@selector(onFilterButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *filterButtonItem = [[UIBarButtonItem alloc] initWithCustomView:filterButton];
    
    self.navigationItem.leftBarButtonItem = filterButtonItem;

    [self.tableView reloadData];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}
          
-(void) viewDidAppear:(BOOL)animated {
    [self.tableView reloadData];
}


- (void) onFilterButtonClicked: (id) sender {
    FiltersViewController *filterController = [[FiltersViewController alloc] initWithNibName:@"FiltersViewController" bundle:nil];
    filterController.delegate = self;
    
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:filterController];
    navController.navigationBar.tintColor =[UIColor whiteColor];
    navController.navigationBar.barTintColor = [UIColor colorFromHexString:@"#c41200"];

    [self presentViewController:navController animated:YES completion:nil];
    
    //UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:nil action:nil];
    
    //self.navigationItem.backBarButtonItem = cancelButton;
    
    //[self.navigationController pushViewController:filterController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end