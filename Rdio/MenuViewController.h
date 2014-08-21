//
//  MenuViewController.h
//  Taste
//
//  Created by Thomas Carey on 4/27/13.
//  Copyright (c) 2013 Thomas J. Carey. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface MenuViewController : UITableViewController <UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *items;

@property (strong, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) UIStoryboard *tasteStoryboard;

@property (strong, nonatomic) ViewController *viewCtl;

@end
