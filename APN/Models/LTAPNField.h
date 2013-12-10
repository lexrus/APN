//
//  LTAPN.h
//  APN
//
//  Created by Lex on 11/23/13.
//  Copyright (c) 2013 LexTang.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, LTFieldType)
{
    LTTextFieldType,
    LTButtonFieldType,
    LTSwitchFieldType,
    LTPasswordFieldType,
    LTPortFieldType
};

@interface LTAPNField : NSObject

@property (nonatomic, copy) NSString *fieldName;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, assign) LTFieldType fieldType;
@property (nonatomic, copy) NSString *fieldValue;
@property (nonatomic, assign, getter = isRequired) BOOL required;

+ (LTAPNField *) fieldWithName:(NSString *)fieldName
                         title:(NSString *)title
                         value:(id)cellValue
                      required:(BOOL)required;

@end
