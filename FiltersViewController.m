//
//  FiltersViewController.m
//  YelpAssignment
//
//  Created by Vikas Kumar Bajaj on 9/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "FiltersViewController.h"
#import "Filters.h"
#import "FilterCell.h"
#import "FilterSwitch.h"
#import "Utils.h"

@interface FiltersViewController ()

@property (strong, nonatomic) IBOutlet UITableView *filtersTableView;
@property (strong, nonatomic) NSMutableDictionary *isCollapsed;
@property (strong, nonatomic) NSMutableDictionary *selectedFilters;

@end

@implementation FiltersViewController

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    return [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isCollapsed = [[NSMutableDictionary alloc] init];
    self.filters = [Filters singletonObject];
    
    
    self.filtersTableView.delegate = self;
    self.filtersTableView.dataSource = self;
    self.filtersTableView.rowHeight = UITableViewAutomaticDimension;
    
    [self.filtersTableView registerNib:[UINib nibWithNibName:@"FilterCell" bundle:nil] forCellReuseIdentifier:@"FilterCell"];
    
    self.navigationItem.title = @"Filters";
    self.filtersTableView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];


    
    UIButton *cancelButton = [Utils getStandardUIButtonWithTitle:@"Cancel"];
    cancelButton.frame=CGRectMake(0.0, 100.0, 70.0, 30.0);
    [cancelButton addTarget:self action:@selector(onCancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(applyButtonClicked:)];

    NSDictionary *defaultFilters = [NSDictionary dictionaryWithDictionary:[self.filters getLastSavedFilters]];
    self.selectedFilters = [defaultFilters mutableCopy];

    [self collapseAll];
}

-(void) collapseAll {
    for (int i=0; i<self.filters.filterGroups.count; i++) {
       [self.isCollapsed setObject:@(YES) forKey:[NSNumber numberWithInt:i]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.filters.filterGroups.count;
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}


-(CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}


-(UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(8,0, 320, 10)];
    footerView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
    return footerView;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(8,10, 320, 40)];
    headerView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(8,10,320,40)];
    headerLabel.text = self.filters.filterGroups[section][@"title"];
    
    [headerView addSubview:headerLabel];
    
    return headerView;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSDictionary *filterGroup = self.filters.filterGroups[section];
    
    if ([self.isCollapsed[@(section)] boolValue]) {
        return 1;
    } else {
        return ((NSArray *)filterGroup[@"data"]).count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *filterGroup = self.filters.filterGroups[indexPath.section];
    NSString *groupOption = filterGroup[@"options"];
    NSArray *groupData = filterGroup[@"data"];
    NSDictionary *element = groupData[indexPath.row];
    NSDictionary *lastSavedFilters = [self.filters getLastSavedFilters];
    
    NSString *selectedRowKey = element[@"yelpkey"];
    
    FilterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FilterCell" forIndexPath:indexPath];
    cell.labelCell.text = element[@"name"];
    
    BOOL isCollapsed = [self.isCollapsed[@(indexPath.section)] boolValue];

    //Cell for this category needs to have check mark as an accessory
    if ([groupOption isEqualToString:@"group"]) {
        
        if ([element[@"valuetype"] isEqualToString:@"string"]) {
            NSString *selectedFilterValue = self.selectedFilters[selectedRowKey];
            if (isCollapsed) {
                cell.labelCell.text = [self findElementNameIn:groupData havingValue:selectedFilterValue type:@"string"];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                if ([selectedFilterValue isEqualToString:element[@"value"]]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
        } else if ([element[@"valuetype"] isEqualToString:@"number"]) {
            int selectedFilterValue = [self.selectedFilters[selectedRowKey] intValue];
            if (isCollapsed) {
                cell.labelCell.text = [self findElementNameIn:groupData havingValue:[NSNumber numberWithInt:selectedFilterValue] type:@"number"];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                if (selectedFilterValue == [element[@"value"] intValue]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
        }

    } else {
        FilterSwitch *toggle = [[FilterSwitch alloc] initWithFrame:CGRectZero];
        toggle.filterData = element;
        cell.accessoryView = toggle;
        BOOL isSelected = [[lastSavedFilters objectForKey:element[@"yelpkey"]] boolValue];
        [toggle setOn:isSelected animated:NO];
        [toggle addTarget:self
                   action:@selector(onToggleSwitch:)
             forControlEvents:UIControlEventValueChanged];
    }
    [cell.layer setBorderWidth:0.3f];
    return cell;
}

- (id)findElementNameIn:(NSArray *)groupData havingValue:(id)value type: (NSString *)type {
    id result;
    for (NSDictionary *element in groupData) {
        if([type isEqualToString:@"string"]) {
            if ([element[@"value"] isEqualToString:value]) {
                result = element[@"name"];
                break;
            }
        } else if ([type isEqualToString:@"number"]){
            if (element[@"value"] == value) {
                result = element[@"name"];
                break;
            }
        }
    }
    return result;
}

- (void)applyButtonClicked: (id)sender {
    [self.delegate didReceiveFilters:self.selectedFilters];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) onCancelButtonClicked: (id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) onToggleSwitch:(id)sender {
    NSDictionary *senderData = [sender filterData];
    NSString *valueType = senderData[@"valuetype"];
    
    if ([valueType isEqualToString:@"boolean"]) {
        [self.selectedFilters setObject:@([sender isOn]) forKey:senderData[@"yelpkey"]];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *filterGroup = self.filters.filterGroups[indexPath.section];
    NSString *groupOption = filterGroup[@"options"];
    NSDictionary *element = ((NSArray *)filterGroup[@"data"])[indexPath.row];

    if ([groupOption isEqualToString:@"group"]) {
        BOOL isCollapsed = [self.isCollapsed[@(indexPath.section)] boolValue];
        
        //If section is not collapsed, we need to update selection
        if (!isCollapsed) {
            self.selectedFilters[element[@"yelpkey"]] = element[@"value"];
        }
        self.isCollapsed[@(indexPath.section)] = @(!isCollapsed);
    }
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
}

@end
