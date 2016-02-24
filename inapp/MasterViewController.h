//
//  MasterViewController.h
//  inapp
//
//  Created by George Vardikos on 15/02/16.
//  Copyright © 2016 foosol. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (nonatomic,copy) NSArray *products;


@end

