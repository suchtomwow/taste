//
//  QueueCell.m
//  Taste
//
//  Created by Thomas Carey on 4/30/13.
//  Copyright (c) 2013 Thomas J. Carey. All rights reserved.
//

#import "QueueCell.h"

@implementation QueueCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
