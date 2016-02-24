//
//  DetailViewController.h
//  inapp
//
//  Created by George Vardikos on 15/02/16.
//  Copyright © 2016 foosol. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

