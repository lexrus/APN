//
//  LTAPNManager.h
//  APN
//
//  Created by Lex on 11/24/13.
//  Copyright (c) 2013 LexTang.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LTAPNManagerDelegate <NSObject>

- (void) serverDidStart;
- (void) serverDidFailToStart;
- (void) serverDidStop;

@end

@interface LTAPNManager : NSObject

@property (nonatomic, strong) NSMutableArray *APNs;
@property (nonatomic, readonly) BOOL isServerOn;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, readonly) NSString *hostName;
@property (nonatomic, weak) id<LTAPNManagerDelegate> delegate;

+ (LTAPNManager *) shared;

- (BOOL) synchronize;
- (void) updateFiles;
- (BOOL) startServer;
- (void) rebroadcast;
- (void) stopServer;

@end
