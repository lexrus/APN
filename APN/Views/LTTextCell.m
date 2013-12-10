//
//  LTTextCell.m
//  APN
//
//  Created by Lex on 11/23/13.
//  Copyright (c) 2013 LexTang.com. All rights reserved.
//

#import "LTTextCell.h"

@implementation LTTextCell

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self.textLabel setFont:[UIFont systemFontOfSize:16]];
        self.textLabel.adjustsFontSizeToFitWidth = YES;
        self.textLabel.minimumScaleFactor = .5;
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.frame = CGRectMake(15,
                                      0,
                                      self.bounds.size.width - 30 - self.textField.bounds.size.width,
                                      self.bounds.size.height);
}

@end
