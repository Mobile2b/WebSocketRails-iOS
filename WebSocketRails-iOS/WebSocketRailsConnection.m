//
//  WebSocketRailsConnection.m
//  WebSocketRails-iOS
//
//  Created by Evgeny Lavrik on 17.12.13.
//  Copyright (c) 2013 Evgeny Lavrik. All rights reserved.
//

#import "WebSocketRailsConnection.h"
#import "WebSocketRailsEvent.h"

@interface WebSocketRailsConnection() <SRWebSocketDelegate>

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSMutableArray *message_queue;
@property (nonatomic, strong) SRWebSocket *webSocket;

@end

@implementation WebSocketRailsConnection

- (id)initWithUrl:(NSURL *)url delegate:(id<WebSocketRailsConnectionDelegate>)delegate;
{
    self = [super init];
    if (self) {
        _url = url;
        _delegate = delegate;
        _message_queue = [NSMutableArray array];
        
        _webSocket = [SRWebSocket.alloc initWithURL:_url];
        _webSocket.delegate = self;
        [_webSocket open];
    }
    return self;
}

- (void)trigger:(WebSocketRailsEvent *)event
{
    if (_delegate.state != WSRDispatcherStateConnected)
    {
        @synchronized(self)
        {
            [_message_queue addObject:event];
        }
    }
    else
    {
        [_webSocket send:[event serialize]];
    }
}

- (void)flushQueue:(NSNumber *)id
{
    @synchronized(self)
    {
        for (WebSocketRailsEvent *event in _message_queue)
        {
            NSString *serializedEvent = [event serialize];
            [_webSocket send:serializedEvent];
        }
        self.message_queue = [NSMutableArray array]; // clear the message queue, as we have now send everything
    }
}

- (void)disconnect
{
    [_webSocket close];
}

#pragma mark - SRWebSocketDelegate
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    // data here is an array of WebSocketRails messages (or events)
    id messageData = [message isKindOfClass:[NSData class]] ? message : [message dataUsingEncoding:NSUTF8StringEncoding];
    id data = [NSJSONSerialization JSONObjectWithData:messageData options:NSJSONReadingMutableContainers error:nil];
    [_delegate connection:self didReceiveMessages:data];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    [self.delegate connection:self didCloseWithCode:code reason:reason wasClean:wasClean];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    [self.delegate connection:self didFailWithError:error];
}

@end
