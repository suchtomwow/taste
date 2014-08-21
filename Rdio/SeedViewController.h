//
//  SeedViewController.h
//  Taste
//
//  Created by Thomas Carey on 4/20/13.
//  Copyright (c) 2013 Thomas J. Carey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface SeedViewController : UITableViewController <RDAPIRequestDelegate, RdioDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *suggestionsTable;

@property (strong, nonatomic) NSMutableArray *suggestions;

@end
