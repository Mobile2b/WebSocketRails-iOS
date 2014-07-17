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
        self.connectionId = @0;
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
        [self sendEvent:event];
    }
}

- (void)flushQueue
{
    @synchronized(self)
    {
        for (WebSocketRailsEvent *event in _message_queue)
        {
            [self sendEvent:event];
        }
        self.message_queue = [NSMutableArray array]; // clear the message queue, as we have now send everything
    }
}

- (void)sendEvent:(WebSocketRailsEvent *)eventToSend
{
    NSParameterAssert(self.delegate.state == WSRDispatcherStateConnected);
    eventToSend.connectionId = self.connectionId; // set the connection id of the event, as the creator of the event could not have known it or the event was created before the connection had an id.
    [_webSocket send:[eventToSend serialize]];
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
