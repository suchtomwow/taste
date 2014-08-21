//
//  MenuViewController.h
//  Taste
//
//  Created by Thomas Carey on 4/21/13.
//  Copyright (c) 2013 Thomas J. Carey. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface MenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *items;

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) UIStoryboard *tasteStoryboard;

@property (strong, nonatomic) ViewController *viewCtl;

@end
