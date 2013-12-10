//
//  LTAPNManager.m
//  APN
//
//  Created by Lex on 11/24/13.
//  Copyright (c) 2013 LexTang.com. All rights reserved.
//

#import "LTAPNManager.h"
#import "HTTPServer.h"
#import "LTHTTPConnection.h"
#import "LTAPN.h"
#import <ifaddrs.h>
#import <arpa/inet.h>


static float kServerStartTimeout = 10;

@interface LTAPNManager () <NSNetServiceBrowserDelegate, NSNetServiceDelegate>

@property (nonatomic, strong) HTTPServer *server;

@end

@implementation LTAPNManager
{
    float _serverStartTimeoutTicker;
    NSTimer *_timer;
    BOOL _isServerOn;
    NSNetServiceBrowser *_netServiceBrowser;
    NSNetService *_netService;
}

+ (LTAPNManager *) shared
{
    static dispatch_once_t once;
    static LTAPNManager *instance;
    
    dispatch_once(&once, ^{
        instance = [[LTAPNManager alloc] init];
    });
    return instance;
}

- (NSString *) documentRoot
{
    static dispatch_once_t documentRootToken;
    static NSString *documentRoot;
    
    dispatch_once(&documentRootToken, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentRoot = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    });
    return documentRoot;
}

- (NSString *) filename
{
    static dispatch_once_t filenameToken;
    static NSString *filename;
    
    dispatch_once(&filenameToken, ^{
        filename = [[self documentRoot] stringByAppendingPathComponent:@"APNs.plist"];
    });
    return filename;
}

- (NSMutableArray *) APNs
{
    if (_APNs)
    {
        return _APNs;
    }
    else if ([[NSFileManager defaultManager] fileExistsAtPath:[self filename]])
    {
        NSArray *serializedAPNs = [NSArray arrayWithContentsOfFile:[self filename]];
        NSMutableArray *APNs = [NSMutableArray array];
        if (serializedAPNs && [serializedAPNs isKindOfClass:[NSArray class]])
        {
            for (NSDictionary *APNDict in serializedAPNs)
            {
                [APNs addObject:[LTAPN modelObjectWithDictionary:APNDict]];
            }
            _APNs = APNs;
            return _APNs;
        }
    }
    else
    {
        _APNs = [NSMutableArray array];
    }
    return _APNs;
}

- (BOOL) synchronize
{
    NSMutableArray *serializedAPNs = [NSMutableArray array];
    
    for (LTAPN *APN in self.APNs)
    {
        [serializedAPNs addObject:[APN dictionaryRepresentation]];
    }
    [self updateFiles];
    return [serializedAPNs writeToFile:[self filename] atomically:YES];
}

- (void) updateFiles
{
    NSString *configsDirectory = [[self documentRoot] stringByAppendingPathComponent:@"configs"];
    BOOL isDirectory;
    
    if (!([[NSFileManager defaultManager] fileExistsAtPath:configsDirectory isDirectory:&isDirectory] && isDirectory))
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:configsDirectory withIntermediateDirectories:YES attributes:NULL error:NULL];
    }
    
    NSString *configTemplatePath = [[NSBundle mainBundle] pathForResource:@"apn" ofType:@"mobileconfig"];
    NSDictionary *configTemplate = [NSDictionary dictionaryWithContentsOfFile:configTemplatePath];
    
    for (LTAPN *APN in self.APNs)
    {
        NSMutableDictionary *config = [configTemplate mutableCopy];
        NSMutableDictionary *apnDict = config[@"PayloadContent"][0][@"PayloadContent"][0][@"DefaultsData"][@"apns"][0];
        
        apnDict[@"apn"] = APN.code;
        
        if (APN.password && APN.password.length > 0)
        {
            apnDict[@"password"] = APN.password;
        }
        else
        {
            [apnDict removeObjectForKey:@"password"];
        }
        
        if (APN.username && APN.username.length > 0)
        {
            apnDict[@"username"] = APN.username;
        }
        else
        {
            [apnDict removeObjectForKey:@"username"];
        }
        
        if (APN.host && APN.port > 0)
        {
            apnDict[@"proxy"] = APN.host;
            apnDict[@"proxyPort"] = @(APN.port);
        }
        else
        {
            [apnDict removeObjectForKey:@"proxy"];
            [apnDict removeObjectForKey:@"proxyPort"];
        }
        
        if (APN.summary && APN.summary.length > 0)
        {
            config[@"PayloadDescription"] = APN.summary;
        }
        else if (APN.host && APN.port > 0)
        {
            config[@"PayloadDescription"] = [NSString stringWithFormat:@"%@:%i", APN.host, APN.port];
        }
        
        config[@"PayloadDisplayName"] = APN.code;
        
        config[@"PayloadContent"][0][@"PayloadUUID"] = [[NSUUID UUID] UUIDString];
        config[@"PayloadUUID"] = APN.UUID;
        
        NSString *configFilePath = [configsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mobileconfig", APN.UUID]];
        [config writeToFile:configFilePath atomically:YES];
        
    }
    
    [self updateIndexHTML];
}

- (void) updateIndexHTML
{
    NSMutableArray *html = [NSMutableArray array];
    [html addObject:@"<html><head><meta charset='utf-8'><title>iPhone APN Configuration Server</title><meta name='viewport' content='width=device-width, user-scalable=no'></head><body>"];
    
    [html addObject:@"<style>body,ul{font-family:'Helvetica';font-size:18px;margin:0;padding:0}ul{padding-left:15px}li{list-style:none;border-bottom:1px solid #ddd;padding:1em 0}a{color:#0091FF;text-decoration:none}.footer{font-size:13px;color:#ccc}</style>"];
    [html addObject:@"<ul>"];
    
    for (LTAPN *APN in self.APNs)
    {
        NSString *description = APN.summary;
        if (!description && (APN.host && APN.port > 0))
        {
            description = [NSString stringWithFormat:@"%@:%i", APN.host, APN.port];
        }
        else
        {
            description = [APN.UUID substringToIndex:5];
        }
        [html addObject:[NSString stringWithFormat:@"<li><a href=\"/configs/%@.mobileconfig\">%@ - %@</a></li>", APN.UUID, APN.code, description]];
    }
    
    [html addObject:@"<li><small class='footer'>Powered by <a href='https://itunes.apple.com/us/app/apn/id759886896?ls=1&mt=8'>APN for iOS</a></small></li>"];
    [html addObject:@"</ul></body></html>"];
    
    NSString *htmlString = [html componentsJoinedByString:@"\n"];
    
    NSString *indexHTMLPath = [NSString stringWithFormat:@"%@/index.htm", [self documentRoot]];
    if ([htmlString writeToFile:indexHTMLPath atomically:YES encoding:NSUTF8StringEncoding error:NULL])
    {
        
    }
}

#pragma mark - HTTP Server

- (HTTPServer *) server
{
    if (!_server)
    {
        _server = [[HTTPServer alloc] init];
        [_server setPort:1983];
        [_server setDomain:@"local."];
        [_server setType:@"_http._tcp."];
        [_server setName:NSLocalizedString(@"APN Configration Server", nil)];
        [_server setDocumentRoot:[self documentRoot]];
        [_server setConnectionClass:[LTHTTPConnection class]];
    }
    return _server;
}

- (NSString *) address
{
    NSString *host = self.hostName;
    if (!host)
    {
        host = [self ipaddr];
    }
    if (!host)
    {
        host = @"localhost";
    }
    return [NSString stringWithFormat:@"http://%@:%i/", host, self.server.port];
}

- (BOOL) startServer
{
    if (!self.isServerOn)
    {
        _serverStartTimeoutTicker = .0;
        NSError *error = nil;
        [self.server start:&error];
        if (noErr != error.code)
        {
            NSLog(@"%@", error);
        }
        
        if (!_timer)
        {
            _timer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(checkPublishedName) userInfo:nil repeats:YES];
        }
    }
    
    return _isServerOn;
}

- (void) stopServer
{
    [self.server stop];
    if (!_timer)
    {
        _timer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(checkPublishedName) userInfo:nil repeats:YES];
    }
}

- (void) rebroadcast
{
    if (self.isServerOn)
    {
        [self.server republishBonjour];
    }
}

- (BOOL) isServerOn
{
    if (self.server.isRunning)
    {
        return YES;
    }
    return _isServerOn;
}

#pragma mark - Timer

- (void) checkPublishedName
{
    _serverStartTimeoutTicker += .1;
    if (_serverStartTimeoutTicker > kServerStartTimeout)
    {
        
        NSObject *delegate = self.delegate;
        if (delegate && [delegate respondsToSelector:@selector(serverDidFailToStart)])
        {
            _isServerOn = NO;
            [delegate performSelector:@selector(serverDidFailToStart)];
        }
        
        [self resetTimer];
        return;
    }
    
    if (self.server.publishedName && self.server.publishedName.length > 0)
    {
        
        _netServiceBrowser = [[NSNetServiceBrowser alloc] init];
        [_netServiceBrowser setDelegate:self];
        [_netServiceBrowser searchForServicesOfType:@"_http._tcp." inDomain:@"local."];
        
        [self resetTimer];
    }
    else if (!self.server.isRunning)
    {
        NSObject *delegate = self.delegate;
        if (delegate && [delegate respondsToSelector:@selector(serverDidStop)])
        {
            _isServerOn = NO;
            [delegate performSelector:@selector(serverDidStop)];
        }
        [self resetTimer];
    }
}

- (void) resetTimer
{
    if (_timer)
    {
        [_timer invalidate];
        _timer = nil;
        _serverStartTimeoutTicker = 0;
    }
}

#pragma mark - Service search delegate

- (void) netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
    _netService = aNetService;
    _netService.delegate = self;
    [_netService resolveWithTimeout:4.0];
}

- (void) netServiceDidResolveAddress:(NSNetService *)service
{
    if (service.hostName && service.hostName.length > 0 && [service.name isEqualToString:self.server.name])
    {
        _hostName = service.hostName;
        
        [self callServerDidStartDelegate];
    }
    
    NSLog(@"netServiceDidResolveAddress: %@", service.hostName);
}

- (void) netServiceDidStop:(NSNetService *)service
{
    if (!_hostName)
    {
        _hostName = [self ipaddr];
        if (self.isServerOn)
        {
            [self callServerDidStartDelegate];
        }
    }
}

- (void) callServerDidStartDelegate
{
    NSObject *delegate = self.delegate;
    
    if (delegate && [delegate respondsToSelector:@selector(serverDidStart)])
    {
        NSLog(@"%@ %@", self.server.name, [self address]);
        _isServerOn = YES;
        [delegate performSelector:@selector(serverDidStart)];
    }
}

- (NSString *) ipaddr
{
    NSString *address = nil;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    
    int success = 0;
    
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        temp_addr = interfaces;
        while (temp_addr != NULL)
        {
            if (temp_addr->ifa_addr->sa_family == AF_INET)
            {
                if (strcmp(temp_addr->ifa_name, "en0") == 0)
                {
                    address = [NSString
                               stringWithUTF8String:
                               inet_ntoa(((struct sockaddr_in *)
                                          temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

@end
