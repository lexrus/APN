//
//  LTTextCell.h
//  APN
//
//  Created by Lex on 11/23/13.
//  Copyright (c) 2013 LexTang.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LTTextCell : UITableViewCell
@property (nonatomic, assign, getter = isRequired) BOOL required;
@property (nonatomic, weak) IBOutlet UITextField *textField;

@end
