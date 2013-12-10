//
//  LTWebViewController.h
//  APN
//
//  Created by Lex on 11/27/13.
//  Copyright (c) 2013 LexTang.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LTWebViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, copy) NSString *URLString;

- (IBAction) share:(id)sender;
@end
