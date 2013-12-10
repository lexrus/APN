//
//  LTSwitchCell.h
//  APN
//
//  Created by Lex on 11/22/13.
//  Copyright (c) 2013 LexTang.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LTSwitchCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UISwitch *switchButton;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
