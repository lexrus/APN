//
//  LTAPNViewController.m
//  APN
//
//  Created by Lex on 11/23/13.
//  Copyright (c) 2013 LexTang.com. All rights reserved.
//

#import "LTAPNViewController.h"
#import "LTAPNField.h"
#import "LTTextCell.h"
#import "LTAPN.h"
#import "LTPrimaryButtonCell.h"

@interface LTAPNViewController ()<UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *fields;
@property (nonatomic, strong) NSMutableArray *cells;
@property (nonatomic, weak) LTAPN *APN;

@end

@implementation LTAPNViewController
{
    __weak UIButton *_installButton;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Save", nil);
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.APNUUID)
    {
        self.title = NSLocalizedString(@"Edit APN configuration", nil);
    }
    else
    {
        self.title = NSLocalizedString(@"Add APN configuration", nil);
        self.saveButton.enabled = NO;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChange:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (LTAPN *) APN
{
    if (_APNUUID)
    {
        for (LTAPN *APN in $.APNs)
        {
            if ([APN.UUID isEqualToString:_APNUUID])
            {
                _APN = APN;
                break;
            }
        }
    }
    return _APN;
}

#pragma mark - Table view data source

- (NSMutableArray *) fields
{
    if (!_fields)
    {
        _fields = [NSMutableArray array];
        [_fields addObject:[LTAPNField fieldWithName:kLTAPNCode title:@"APN Code" value:nil required:YES]];
        [_fields addObject:[LTAPNField fieldWithName:kLTAPNSummary title:@"Description" value:nil required:NO]];
        [_fields addObject:[LTAPNField fieldWithName:kLTAPNUsername title:@"Username" value:nil required:NO]];
        
        LTAPNField *passwordFieldData = [LTAPNField fieldWithName:kLTAPNPassword title:@"Password" value:nil required:NO];
        passwordFieldData.fieldType = LTPasswordFieldType;
        [_fields addObject:passwordFieldData];
        
        [_fields addObject:[LTAPNField fieldWithName:kLTAPNHost title:@"Proxy host" value:nil required:NO]];
        
        LTAPNField *portFieldData = [LTAPNField fieldWithName:kLTAPNPort title:@"Proxy port" value:nil required:NO];
        portFieldData.fieldType = LTPortFieldType;
        [_fields addObject:portFieldData];
    }
    return _fields;
}

- (NSMutableArray *) cells
{
    if (!_cells)
    {
        _cells = [NSMutableArray array];
    }
    return _cells;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_APNUUID)
    {
        return 3;
    }
    return 2;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return self.fields.count;
    }
    return 1;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2)
    {
        static NSString *DeleteCellIdentifier = @"DeleteCell";
        LTPrimaryButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:DeleteCellIdentifier];
        [cell.button setTitle:NSLocalizedString(@"Delete", nil) forState:UIControlStateNormal];
        return cell;
    }
    else if (indexPath.section == 1)
    {
        static NSString *InstallCellIdentifier = @"InstallCell";
        LTPrimaryButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:InstallCellIdentifier];
        cell.button.enabled = self.saveButton.enabled;
        [cell.button setTitle:NSLocalizedString(@"Install APN Profile", nil) forState:UIControlStateNormal];
        _installButton = cell.button;
        return cell;
    }
    
    static NSString *TextCellIdentifier = @"TextCell";
    LTTextCell *cell = [tableView dequeueReusableCellWithIdentifier:TextCellIdentifier];
    LTAPNField *field = self.fields[indexPath.row];
    
    cell.textLabel.text = NSLocalizedString(field.title, nil);
    cell.textField.placeholder = field.placeholder;
    __weak __typeof(& *self) weakSelf = self;
    cell.textField.delegate = weakSelf;
    if (field.fieldType == LTPortFieldType)
    {
        cell.textField.returnKeyType = UIReturnKeyDone;
        cell.textField.keyboardType = UIKeyboardTypeNumberPad;
    }
    else if (field.fieldType == LTPasswordFieldType)
    {
        cell.textField.secureTextEntry = YES;
    }
    else if ([field.fieldName isEqualToString:kLTAPNHost])
    {
        cell.textField.keyboardType = UIKeyboardTypeURL;
    }
    
    if (field.required)
    {
        cell.required = YES;
    }
    
    if (self.cells.count < indexPath.row + 1)
    {
        [self.cells addObject:cell];
    }
    
    if (self.APN)
    {
        if ([field.fieldName isEqualToString:kLTAPNPort] && self.APN.port == 0)
        {
            
        }
        else
        {
            cell.textField.text = self.APN[field.fieldName];
        }
    }
    
    return cell;
}

/*
 #pragma mark - Navigation
 
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 
 */

#pragma mark - NavigationBar actions

- (IBAction) remove:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete this APN?", nil)
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Delete", nil)
                                              otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil];
    
    
    [alertView show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex)
    {
        if (_APNUUID)
        {
            uint i = 0;
            for (LTAPN *oldAPN in $.APNs)
            {
                if ([oldAPN.UUID isEqualToString:_APNUUID])
                {
                    [$.APNs removeObjectAtIndex:i];
                    [$ synchronize];
                    break;
                }
                i++;
            }
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void) save
{
    if (_APNUUID)
    {
        uint i = 0;
        for (LTAPN *oldAPN in $.APNs)
        {
            if ([oldAPN.UUID isEqualToString:_APNUUID])
            {
                [$.APNs replaceObjectAtIndex:i withObject:[self APNFromForm]];
                break;
            }
            i++;
        }
    }
    else
    {
        [$.APNs addObject:[self APNFromForm]];
    }
    
    [$ synchronize];
}

- (IBAction) saveAndBack:(id)sender
{
    [self save];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) install:(id)sender
{
    [self save];
    
    [$ startServer];
    
    NSString *APNURLString = [NSString stringWithFormat:@"http://127.0.0.1:1983/configs/%@.mobileconfig", self.APN.UUID];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APNURLString]];
}

- (LTAPN *) APNFromForm
{
    LTAPN *APN = [[LTAPN alloc] init];
    
    if (_APNUUID)
    {
        APN.UUID = _APNUUID;
    }
    uint i = 0;
    for (LTAPNField *field in self.fields)
    {
        APN[field.fieldName] = [(LTTextCell *) self.cells[i] textField].text;
        i++;
    }
    return APN;
}

#pragma mark - TextField delegates

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    UIView *view = textField;
    
    while (view)
    {
        view = view.superview;
        if ([view isKindOfClass:[LTTextCell class]])
        {
            break;
        }
    }
    LTTextCell *currentCell = (LTTextCell *) view;
    
    if (!currentCell)
    {
        return NO;
    }
    
    BOOL found = NO;
    for (uint i = 0; i < self.cells.count; i++)
    {
        LTTextCell *cell = self.cells[i];
        if (cell == currentCell)
        {
            uint nextIndex = i + 1;
            if (nextIndex < self.cells.count)
            {
                LTTextCell *nextCell = self.cells[nextIndex];
                [nextCell.textField becomeFirstResponder];
                found = YES;
                break;
            }
        }
    }
    
    if (!found)
    {
        [textField resignFirstResponder];
    }
    
    return NO;
}

- (void) textFieldDidChange:(NSNotification *)notification
{
    UITextField *textField = (UITextField *) notification.object;
    
    UIView *view = textField;
    
    while (view)
    {
        view = view.superview;
        if ([view isKindOfClass:[LTTextCell class]])
        {
            break;
        }
    }
    LTTextCell *currentCell = (LTTextCell *) view;
    
    if (currentCell.isRequired)
    {
        BOOL allFilled = YES;
        for (LTTextCell *cell in self.cells)
        {
            if (cell.isRequired && cell.textField.text.length == 0)
            {
                allFilled = NO;
            }
        }
        self.saveButton.enabled = allFilled;
        [_installButton setEnabled:self.saveButton.enabled];
    }
}

@end
