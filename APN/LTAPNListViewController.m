//
//  LTAPNListViewController.m
//  APN
//
//  Created by Lex on 11/20/13.
//  Copyright (c) 2013 LexTang.com. All rights reserved.
//

#import "LTAPNListViewController.h"
#import "LTAPNViewController.h"
#import "LTAPNCell.h"
#import "LTAPNField.h"
#import "LTSwitchCell.h"
#import "LTAPN.h"
#import "LTWebViewController.h"

static uint kAPNItemsSection = 1;

@interface LTAPNListViewController ()
<UITableViewDelegate, UITableViewDataSource,
UIActionSheetDelegate, LTAPNManagerDelegate>
{
    NSString *_APNUUID;
}
@property (nonatomic, weak) UISwitch *switchButton;
@property (nonatomic, weak) UIActivityIndicatorView *activityIndicator;

@end

@implementation LTAPNListViewController

- (id) initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    //    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"About", nil);
    self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Help", nil);
    [self.tableView reloadData];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == kAPNItemsSection)
    {
        return $.APNs.count + 1;
    }
    else if ($.isServerOn)
    {
        return 2;
    }
    return 1;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ButtonCellIdentifier = @"ButtonCell";
    static NSString *SwitchCellIdentifier = @"SwitchCell";
    static NSString *ItemCellIdentifier = @"ItemCell";
    
    UITableViewCell *cell = nil;
    
    if (indexPath.section != kAPNItemsSection)
    {
        if (indexPath.row == 0)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:SwitchCellIdentifier];
            cell.textLabel.text = NSLocalizedString(@"Configuration profiles server", nil);
            _switchButton = [(LTSwitchCell *) cell switchButton];
            _activityIndicator = [(LTSwitchCell *) cell activityIndicator];
            if (![_switchButton actionsForTarget:self forControlEvent:UIControlEventValueChanged])
            {
                [_switchButton addTarget:self action:@selector(toggleServer:) forControlEvents:UIControlEventValueChanged];
            }
            [_switchButton setOn:$.isServerOn];
        }
        else
        {
            cell = [tableView dequeueReusableCellWithIdentifier:ButtonCellIdentifier];
            cell.textLabel.text = $.address;
        }
    }
    else if (indexPath.row != $.APNs.count)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:ItemCellIdentifier];
        LTAPN *APN = $.APNs[indexPath.row];
        cell.textLabel.text = APN.code;
        if (APN.summary && APN.summary.length > 0)
        {
            cell.detailTextLabel.text = APN.summary;
        }
        else if (APN.host && APN.host.length > 0 && APN.port > 0)
        {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@:%i", APN.host, APN.port];
        }
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:ButtonCellIdentifier];
        cell.textLabel.text = [NSString stringWithFormat:@"%@...", NSLocalizedString(@"Add APN configuration", nil)];
    }
    
    return cell;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == kAPNItemsSection && $.APNs.count > 0)
    {
        return NSLocalizedString(@"Choose a configuration...", nil);
    }
    return nil;
}

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

// - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
// {
//    if (indexPath.section == kAPNItemsSection && indexPath.row < $.APNs.count)
//    {
//        return YES;
//    }
//    return NO;
// }

#pragma mark - Table view delegates

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kAPNItemsSection)
    {
        if (indexPath.row < $.APNs.count) // not the add button
        {
            LTAPN *apn = $.APNs[indexPath.row];
            _APNUUID = apn.UUID;
        }
        else
        {
            _APNUUID = nil;
        }
        [self performSegueWithIdentifier:@"detail" sender:self];
    }
    else
    {
        if (indexPath.row == 1)
        {
            [self performSegueWithIdentifier:@"browser" sender:nil];
        }
    }
}


#pragma mark - Navigation

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *destination = [segue destinationViewController];
    
    if ([destination isKindOfClass:[LTAPNViewController class]])
    {
        [(LTAPNViewController *) destination setAPNUUID : _APNUUID];
    }
    else if ([destination isKindOfClass:[LTWebViewController class]])
    {
        [(LTWebViewController *) destination setURLString: $.address];
    }
}

#pragma mark - Toggle Server

- (void) toggleServer:(UISwitch *)switchButton
{
    $.delegate = self;
    if (switchButton.isOn)
    {
        [_activityIndicator startAnimating];
        [$ startServer];
    }
    else
    {
        [$ stopServer];
    }
    
    switchButton.enabled = NO;
}

#pragma mark - Server Delegate

- (void) serverDidStart
{
    [self reloadServerSwitch];
}

- (void) serverDidStop
{
    [self reloadServerSwitch];
}

- (void) serverDidFailToStart
{
    [self reloadServerSwitch];
}

- (void) reloadServerSwitch
{
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                  withRowAnimation:UITableViewRowAnimationAutomatic];
    [_activityIndicator stopAnimating];
    _switchButton.enabled = YES;
}

#pragma mark - About

- (IBAction)showAbout:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"APN for iOS is developed by Lex Tang.", nil)
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"No, thanks", nil)
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"Follow @lexrus on Twitter", nil), nil];
    [actionSheet showFromBarButtonItem:sender animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Follow @lexrus on Twitter", nil)])
    {
        if ([self appsInstalledWithScheme:@"tweetbot://"])
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tweetbot:///user_profile/lexrus"]];
        }
        else if ([self appsInstalledWithScheme:@"twitter://"])
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=lexrus"]];
        }
        else
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/lexrus"]];
        }
    }
}

- (BOOL) appsInstalledWithScheme:(NSString *)applicationScheme {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:applicationScheme]];
}

@end
