//
//  MasterViewController.m
//  inapp
//
//  Created by George Vardikos on 15/02/16.
//  Copyright © 2016 foosol. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "MyIAPGateway.h"
#import <StoreKit/StoreKit.h>
#import <SVProgressHUD.h>
#import <MAConfirmButton.h>




@interface MasterViewController ()

//@property (nonatomic,copy) NSArray *products;
@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Products";
    
    self.navigationItem.rightBarButtonItem = [self restoreButton];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.refreshControl beginRefreshing];
    [self refresh];
}

- (void) refresh {
    [[MyIAPGateway sharedInstance] fetchProductsWithBlock:^(BOOL success, NSArray *products) {
        self.products = products;
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }];
}

- (UIBarButtonItem *)restoreButton {
    return [[UIBarButtonItem alloc] initWithTitle:@"Restore" style:UIBarButtonItemStylePlain target:self action:@selector(restore)];
}

-(void)restore {
    [SVProgressHUD show];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onProductPurchased:) name:IAPGatewayProductPurchased object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.products.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    SKProduct *product = [self.products objectAtIndex:indexPath.row];
    cell.textLabel.text = product.localizedTitle;
    cell.detailTextLabel.text = product.localizedDescription;
    
    if ([[MyIAPGateway sharedInstance] isProductPurchased:product]) {
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = [self confirmButtonForRow:indexPath.row];
    }
    return cell;
}

- (MAConfirmButton *)confirmButtonForRow:(NSInteger)row {
    SKProduct *product = [self.products objectAtIndex:row];
    NSDecimalNumber *price = product.price;
    NSString *priceString = [NSString stringWithFormat:@"%@ $", price];
    MAConfirmButton *button = [MAConfirmButton buttonWithTitle:priceString confirm:@"Confirm?"];
    button.tag = row;
    [button addTarget:self action:@selector(purchaseProduct:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)purchaseProduct:(id)sender {
    MAConfirmButton *button = sender;
    SKProduct *product = [self.products objectAtIndex:button.tag];
    [button disableWithTitle:@"Purchasing..."];
    [SVProgressHUD show];
    [[MyIAPGateway sharedInstance] purchaseProduct:product];
}

-(void)onProductPurchased:(NSNotification *)notification {
    [SVProgressHUD showSuccessWithStatus:@"Thank you"];
    NSString *productIdentifier = notification.object;
    [self.products enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SKProduct *product = obj;
        if ([product.productIdentifier isEqualToString:productIdentifier]){
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            *stop = YES;
        }
    }];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [self.products removeObjectAtIndex:indexPath.row];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
//    }
}

@end
