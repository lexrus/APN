//
//  LTAPNViewController.h
//  APN
//
//  Created by Lex on 11/23/13.
//  Copyright (c) 2013 LexTang.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LTAPNViewController : UITableViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (nonatomic, strong) NSString *APNUUID;

- (void) save;
- (IBAction) saveAndBack:(id)sender;
- (IBAction) remove:(id)sender;
- (IBAction) install:(id)sender;

@end
