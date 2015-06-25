//
//  FiltersViewController.m
//  Yelp
//
//  Created by Tim Lee on 2015/6/25.
//  Copyright (c) 2015年 codepath. All rights reserved.
//

#import "FiltersViewController.h"
#import "SwitchCell.h"

@interface FiltersViewController ()<UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, readonly) NSDictionary *filters;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSArray *sorts;
@property (nonatomic, strong) NSArray *radius;
@property (nonatomic,strong) NSMutableSet *selectedCategories;
@property (nonatomic,strong) NSMutableSet *selectedSorts;
@property (nonatomic,strong) NSMutableSet *selectedRadius;
@property (nonatomic, assign) BOOL deal;
- (void)initCategories;

@end

@implementation FiltersViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self){
        [self initCategories];
        self.selectedCategories = [NSMutableSet set];
        self.selectedSorts = [NSMutableSet set];
        self.selectedRadius = [NSMutableSet set];
        [self.selectedSorts addObject:self.sorts[0]];
        self.deal = FALSE;
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButton)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(onApplyButton)];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SwitchCell" bundle:nil] forCellReuseIdentifier:@"SwitchCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view methods

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rowCount;
    switch (section) {
        case 0:
            rowCount = self.categories.count;
            break;
        case 1:
            rowCount = self.sorts.count;
            break;
        case 2:
            rowCount = self.radius.count;
            break;
        case 3:
            rowCount = 1;
            break;
        default:
            break;
    }
    return rowCount;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
    
    switch (indexPath.section) {
        case 0:
            cell.titleLabel.text = self.categories[indexPath.row][@"name"];
            cell.on = [self.selectedCategories containsObject:self.categories[indexPath.row]];
            break;
        case 1:
            cell.titleLabel.text = self.sorts[indexPath.row][@"name"];
            cell.on = [self.selectedSorts containsObject:self.sorts[indexPath.row]];
            break;
        case 2:
            cell.titleLabel.text = self.radius[indexPath.row][@"name"];
            cell.on = [self.selectedRadius containsObject:self.radius[indexPath.row]];
            break;
        case 3:
            cell.titleLabel.text = @"Offering a deal";
            cell.on = self.deal;
        default:
            break;
    }
    
    cell.delegate = self;
    return cell;
}

#pragma mark - Switch cell delegate methods

- (void)SwitchCell:(SwitchCell *)cell didUpdateValue:(BOOL)value{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    switch (indexPath.section) {
        case 0:
            if (value) {
                [self.selectedCategories addObject:self.categories[indexPath.row]];
            } else {
                [self.selectedCategories removeObject:self.categories[indexPath.row]];
            }
            break;
        case 1:
            self.selectedSorts = [NSMutableSet set];
            if (value) {
                [self.selectedSorts addObject:self.sorts[indexPath.row]];
            }else{
                [self.selectedSorts addObject:self.sorts[0]];
            }
            [self.tableView reloadData];
            break;
        case 2:
            self.selectedRadius = [NSMutableSet set];
            if (value) {
                [self.selectedRadius addObject:self.radius[indexPath.row]];
            }
            [self.tableView reloadData];
            break;
        case 3:
            if (value) {
                self.deal = TRUE;
            } else {
                self.deal = FALSE;
            }
            
        default:
            break;
    }

}

#pragma mark - Private methods

- (NSDictionary *)filters{
    NSMutableDictionary *filters = [NSMutableDictionary dictionary];
    
    if (self.selectedCategories.count >0){
        NSMutableArray *names = [NSMutableArray array];
        for (NSDictionary *category in self.selectedCategories){
            [names addObject:category[@"code"]];
        }
        NSString *categoryFilter = [names componentsJoinedByString:@","];
        [filters setObject:categoryFilter forKey:@"category_filter"];
    }
    
    if (self.selectedSorts.count > 0){
        [filters setObject:[self.selectedSorts valueForKey:@"code"] forKey:@"sort"];
    }
    
    if (self.selectedRadius.count > 0) {
        [filters setObject:[self.selectedRadius valueForKey:@"code"] forKey:@"radius_filter"];
    }
    
    [filters setObject:(self.deal) ? @"true" : @"false" forKey:@"deals_filter"];
    
    return filters;
}

-(void) onCancelButton{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) onApplyButton{
    [self.delegate filtersViewController:self didChangeFilters:self.filters];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initCategories{
    self.categories =@[@{@"name": @"Afghan", @"code": @"afghani"},
                       @{@"name": @"African", @"code": @"african"},
                       @{@"name" : @"American New", @"code": @"newamerican"}
                      ];
    
    self.sorts = @[@{@"name":@"best match",@"code":@"0"},
                   @{@"name":@"distance",@"code":@"1"},
                   @{@"name":@"highest rated",@"code":@"2"}
                   ];
    
    self.radius = @[@{@"name":@"500 meters",@"code":@"500"},
                    @{@"name":@"1000 meters",@"code":@"1000"},
                    @{@"name":@"1500 meters",@"code":@"1500"}
                    ];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title;
    switch (section) {
        case 0:
            title = @"category";
            break;
        case 1:
            title = @"sort";
            break;
        case 2:
            title = @"radius";
            break;
        case 3:
            title = @"deals";
            break;
        default:
            break;
    }
    return title;
}


@end
