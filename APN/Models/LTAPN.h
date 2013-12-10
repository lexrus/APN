//
//  LTAPN.h
//
//  Created by Lex  on 11/25/13
//  Copyright (c) 2013 LexTang.com. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const kLTAPNUUID;
FOUNDATION_EXPORT NSString *const kLTAPNPort;
FOUNDATION_EXPORT NSString *const kLTAPNPassword;
FOUNDATION_EXPORT NSString *const kLTAPNSummary;
FOUNDATION_EXPORT NSString *const kLTAPNCode;
FOUNDATION_EXPORT NSString *const kLTAPNUsername;
FOUNDATION_EXPORT NSString *const kLTAPNHost;

@class LTAPNField;

@interface LTAPN : NSObject <NSCoding>

@property (nonatomic, strong) NSString *UUID;
@property (nonatomic, assign) NSUInteger port;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *summary;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *host;

+ (LTAPN *) modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype) initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *) dictionaryRepresentation;

- (id) objectForKeyedSubscript:(NSString *)key;
- (void) setObject:(id)obj forKeyedSubscript:(NSString *)key;

@end
