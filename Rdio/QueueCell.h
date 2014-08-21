//
//  QueueCell.h
//  Taste
//
//  Created by Thomas Carey on 4/30/13.
//  Copyright (c) 2013 Thomas J. Carey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QueueCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *textLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailTextLabel;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end
