//
//  iPhoneMenuViewController.h
//  Taste
//
//  Created by Thomas Carey on 4/29/13.
//  Copyright (c) 2013 Thomas J. Carey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface iPhoneMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *items;
@property (strong, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) UIStoryboard *tasteStoryboard;
@property (strong, nonatomic) ViewController *viewCtl;

@end
