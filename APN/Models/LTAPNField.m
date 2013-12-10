//
//  LTAPNField.m
//  APN
//
//  Created by Lex on 11/23/13.
//  Copyright (c) 2013 LexTang.com. All rights reserved.
//

#import "LTAPNField.h"

@implementation LTAPNField

+ (LTAPNField *) fieldWithName:(NSString *)fieldName
                         title:(NSString *)title
                         value:(NSString *)fieldValue
                      required:(BOOL)required
{
    LTAPNField *fieldData = [[LTAPNField alloc] init];
    
    fieldData.fieldName = fieldName;
    fieldData.title = title;
    fieldData.fieldType = LTTextFieldType;
    fieldData.fieldValue = fieldValue;
    fieldData.required = required;
    if (required)
    {
        fieldData.placeholder = NSLocalizedString(@"Required", nil);
    }
    return fieldData;
}

@end
