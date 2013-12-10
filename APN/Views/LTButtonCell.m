//
//  LTButtonCell.m
//  APN
//
//  Created by Lex on 11/22/13.
//  Copyright (c) 2013 LexTang.com. All rights reserved.
//

#import "LTButtonCell.h"

@implementation LTButtonCell

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.textLabel.font = [UIFont boldSystemFontOfSize:16];
    }
    return self;
}

@end
