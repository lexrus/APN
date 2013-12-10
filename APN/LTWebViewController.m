//
//  LTWebViewController.m
//  APN
//
//  Created by Lex on 11/27/13.
//  Copyright (c) 2013 LexTang.com. All rights reserved.
//

#import "LTWebViewController.h"

@interface LTWebViewController () <UIWebViewDelegate>
{
    NSString *_URLString;
}

@end

@implementation LTWebViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_URLString)
    {
        self.title = _URLString;
        NSURL *URL = [NSURL URLWithString:_URLString];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [self.webView loadRequest:request];
    }
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) share:(id)sender
{
    __block UIBarButtonItem *shareButton = sender;
    
    [shareButton setEnabled:NO];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[_URLString] applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion: ^{
        [shareButton setEnabled:YES];
    }];
}

#pragma mark - WebView delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.absoluteString rangeOfString:@".mobileconfig" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    return YES;
}

@end
