//
//  TastesViewController.h
//  Taste
//
//  Created by Thomas Carey on 4/26/13.
//  Copyright (c) 2013 Thomas J. Carey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TastesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *table;

@end
