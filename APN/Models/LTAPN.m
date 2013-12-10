//
//  LTAPN.m
//
//  Created by Lex  on 11/25/13
//  Copyright (c) 2013 LexTang.com. All rights reserved.
//

#import "LTAPN.h"
#import "LTAPNField.h"

NSString *const kLTAPNUUID = @"uuid";
NSString *const kLTAPNPort = @"port";
NSString *const kLTAPNPassword = @"password";
NSString *const kLTAPNSummary = @"summary";
NSString *const kLTAPNCode = @"code";
NSString *const kLTAPNUsername = @"username";
NSString *const kLTAPNHost = @"host";
NSString *const kLTAPNName = @"name";


@interface LTAPN ()

- (id) objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation LTAPN

@synthesize UUID = _UUID;
@synthesize port = _port;
@synthesize password = _password;
@synthesize summary = _summary;
@synthesize code = _code;
@synthesize username = _username;
@synthesize host = _host;


+ (LTAPN *) modelObjectWithDictionary:(NSDictionary *)dict
{
    LTAPN *instance = [[LTAPN alloc] initWithDictionary:dict];
    
    return instance;
}

- (instancetype) initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    if (self && [dict isKindOfClass:[NSDictionary class]])
    {
        self.UUID = [self objectOrNilForKey:kLTAPNUUID fromDictionary:dict];
        self.port = [[self objectOrNilForKey:kLTAPNPort fromDictionary:dict] unsignedIntegerValue];
        self.password = [self objectOrNilForKey:kLTAPNPassword fromDictionary:dict];
        self.summary = [self objectOrNilForKey:kLTAPNSummary fromDictionary:dict];
        self.code = [self objectOrNilForKey:kLTAPNCode fromDictionary:dict];
        self.username = [self objectOrNilForKey:kLTAPNUsername fromDictionary:dict];
        self.host = [self objectOrNilForKey:kLTAPNHost fromDictionary:dict];
        
    }
    
    return self;
    
}

- (NSDictionary *) dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    
    [mutableDict setValue:self.UUID forKey:kLTAPNUUID];
    [mutableDict setValue:[NSNumber numberWithUnsignedInteger:self.port] forKey:kLTAPNPort];
    [mutableDict setValue:self.password forKey:kLTAPNPassword];
    [mutableDict setValue:self.summary forKey:kLTAPNSummary];
    [mutableDict setValue:self.code forKey:kLTAPNCode];
    [mutableDict setValue:self.username forKey:kLTAPNUsername];
    [mutableDict setValue:self.host forKey:kLTAPNHost];
    
    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

- (NSString *) UUID
{
    if (!_UUID)
    {
        _UUID = [[NSUUID UUID] UUIDString];
    }
    return _UUID;
}

#pragma mark - Helper Method
- (id) objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    
    return [object isEqual:[NSNull null]] ? nil : object;
}


#pragma mark - NSCoding Methods

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    self.UUID = [aDecoder decodeObjectForKey:kLTAPNUUID];
    self.port = [aDecoder decodeIntegerForKey:kLTAPNPort];
    self.password = [aDecoder decodeObjectForKey:kLTAPNPassword];
    self.summary = [aDecoder decodeObjectForKey:kLTAPNSummary];
    self.code = [aDecoder decodeObjectForKey:kLTAPNCode];
    self.username = [aDecoder decodeObjectForKey:kLTAPNUsername];
    self.host = [aDecoder decodeObjectForKey:kLTAPNHost];
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_UUID forKey:kLTAPNUUID];
    [aCoder encodeInteger:_port forKey:kLTAPNPort];
    [aCoder encodeObject:_password forKey:kLTAPNPassword];
    [aCoder encodeObject:_summary forKey:kLTAPNSummary];
    [aCoder encodeObject:_code forKey:kLTAPNCode];
    [aCoder encodeObject:_username forKey:kLTAPNUsername];
    [aCoder encodeObject:_host forKey:kLTAPNHost];
}


- (id) objectForKeyedSubscript:(NSString *)key
{
    if ([key isEqualToString:kLTAPNCode])
    {
        return self.code;
    }
    else if ([key isEqualToString:kLTAPNSummary])
    {
        return self.summary;
    }
    else if ([key isEqualToString:kLTAPNHost])
    {
        return self.host;
    }
    else if ([key isEqualToString:kLTAPNPort])
    {
        return [@(self.port)stringValue];
    }
    else if ([key isEqualToString:kLTAPNUsername])
    {
        return self.username;
    }
    else if ([key isEqualToString:kLTAPNPassword])
    {
        return self.password;
    }
    return nil;
}

- (void) setObject:(id)obj forKeyedSubscript:(NSString *)key
{
    if ([key isEqualToString:kLTAPNCode])
    {
        self.code = obj;
    }
    else if ([key isEqualToString:kLTAPNSummary])
    {
        self.summary = obj;
    }
    else if ([key isEqualToString:kLTAPNHost])
    {
        self.host = obj;
    }
    else if ([key isEqualToString:kLTAPNPort])
    {
        self.port = [obj integerValue];
    }
    else if ([key isEqualToString:kLTAPNUsername])
    {
        self.username = obj;
    }
    else if ([key isEqualToString:kLTAPNPassword])
    {
        self.password = obj;
    }
}

@end
