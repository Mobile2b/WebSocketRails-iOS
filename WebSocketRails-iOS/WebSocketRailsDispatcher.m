//
//  WebSocketRailsDispatcher.m
//  WebSocketRails-iOS
//
//  Created by Evgeny Lavrik on 17.12.13.
//  Copyright (c) 2013 Evgeny Lavrik. All rights reserved.
//

#import "WebSocketRailsDispatcher.h"
#import "WebSocketRailsConnection.h"
#import "WebSocketRailsEvent.h"
#import "WebSocketRailsChannel.h"

NSString *const WSRConnectionIDMessageKey = @"connectionId";

@interface WebSocketRailsDispatcher() <WebSocketRailsConnectionDelegate, WebSocketRailsChannelEventSender>

@property (nonatomic, strong) NSMutableDictionary *queue;
@property (nonatomic, strong) NSMutableDictionary *callbacks;
@property (nonatomic, strong) WebSocketRailsConnection *connection;
@property (nonatomic, strong) NSMutableDictionary *channels;
@property (readwrite, assign) WSRDispatcherState state;

@end

@implementation WebSocketRailsDispatcher

@synthesize state = _state;

- (id)initWithUrl:(NSURL *)url
{
    self = [super init];
    if (self) {
        _url = url;
        _channels = [NSMutableDictionary dictionary];
        _queue = [NSMutableDictionary dictionary];
        _callbacks = [NSMutableDictionary dictionary];
        
        [self connect];
    }
    return self;
}

#pragma mark - Connection Delegate

- (void)connection:(WebSocketRailsConnection *)connection didReceiveMessages:(NSDictionary *)messages
{
    if (connection != self.connection)
    {
        // ignore
        return;
    }
    for (id socket_message in messages)
    {
        WebSocketRailsEvent *event = [WebSocketRailsEvent.alloc initWithData:socket_message];
        
        if ([event isResult])
        {
            if (_queue[event.id])
            {
                [_queue[event.id] runCallbacks:event.success eventData:event.data];
                [_queue removeObjectForKey:event.id];
            }
        } else if ([event isChannel]) {
            [self dispatchChannel:event];
        } else if ([event isPing]) {
            [self pong];
        } else {
            [self dispatch:event];
        }
        
        if ((_state == WSRDispatcherStateConnecting) && [event.name isEqualToString:WSRSpecialEventNames.ClientConnected])
        {
            [self connectionEstablished:event.data];
        }
    }
}

- (void)connection:(WebSocketRailsConnection *)connection didFailWithError:(NSError *)error
{
    if (connection != self.connection)
    {
        // ignore
        return;
    }
    self.state = WSRDispatcherStateDisconnected;
    if ([self.delegate respondsToSelector:@selector(dispatcher:connectionDidFailWithError:)])
    {
        [self.delegate dispatcher:self connectionDidFailWithError:error];
    }
}

- (void)connection:(WebSocketRailsConnection *)connection didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    if (connection != self.connection)
    {
        // ignore
        return;
    }
    self.state = WSRDispatcherStateDisconnected;
    if ([self.delegate respondsToSelector:@selector(dispatcher:connectionDidCloseWithCode:reason:wasClean:)])
    {
        [self.delegate dispatcher:self connectionDidCloseWithCode:code reason:reason wasClean:wasClean];
    }
}

- (void)connectionDidOpen:(WebSocketRailsConnection *)connection
{
    // We ignore this case as we are more interested in the 'ClientConnected' message and use that as a confirmation for a successful message. See -connection:didReceiveMessages: and -connectionEstablished:
}

#pragma mark - Public

- (void)reconnect
{
    NSParameterAssert(self.state == WSRDispatcherStateDisconnected);
    [self connect];
    
    // although no connection is established yet, we can already ask our channels to send their subscription messages again
    // the connection will just enqueue them and we flush the queue, once the connection is established
    for (NSString *channelName in self.channels)
    {
        [self.channels[channelName] resubscribe];
    }
}

- (void)bindToEventWithName:(NSString *)eventName callback:(EventCompletionBlock)callback
{
    if (!_callbacks[eventName])
        _callbacks[eventName] = [NSMutableArray array];
    
    [_callbacks[eventName] addObject:[callback copy]];
}

- (WebSocketRailsChannel *)subscribeToChannelWithName:(NSString *)channelName
{
    if (_channels[channelName])
        return _channels[channelName];
    
    WebSocketRailsChannel *channel = [WebSocketRailsChannel.alloc initWithName:channelName eventSender:self private:NO];
    _channels[channelName] = channel;
    return channel;
}

- (void)unsubscribeFromChannelWithName:(NSString *)channelName
{
    if (!_channels[channelName])
        return;
    
    [_channels[channelName] destroy];
    [_channels removeObjectForKey:channelName];
}

#pragma mark - Private

- (void)connect
{
    self.state = WSRDispatcherStateConnecting;
    self.connection = [WebSocketRailsConnection.alloc initWithUrl:self.url delegate:self];
}

- (void)connectionEstablished:(id)data
{
    _state = WSRDispatcherStateConnected;
    self.connection.connectionId = data[WSRConnectionIDMessageKey] ?: [NSNull null];
    
    if ([self.delegate respondsToSelector:@selector(dispatcherDidEstablishConnection:)])
    {
        [self.delegate dispatcherDidEstablishConnection:self];
    }
    
    [self.connection flushQueue];
}

- (void)trigger:(NSString *)eventName data:(id)data success:(EventCompletionBlock)success failure:(EventCompletionBlock)failure
{
    WebSocketRailsEvent *event = [WebSocketRailsEvent.alloc initWithData:@[eventName, data] success:success failure:failure];
    _queue[event.id] = event;
    [self.connection trigger:event];
}
 
 - (void)triggerEvent:(WebSocketRailsEvent *)event
 {
     if (_queue[event.id] && _queue[event.id] == event)
         return;
     
     _queue[event.id] = event;
     [_connection trigger:event];
 }

- (void)dispatch:(WebSocketRailsEvent *)event
{
    if (!_callbacks[event.name])
        return;
    
    for (EventCompletionBlock callback in _callbacks[event.name])
    {
        callback(event.data);
    }
}

- (void)dispatchChannel:(WebSocketRailsEvent *)event
{
    if (!_channels[event.channel])
        return;
    
    [_channels[event.channel] dispatch:event.name message:event.data];
}

- (void)pong
{
    WebSocketRailsEvent *pong = [WebSocketRailsEvent.alloc initWithData:@[WSRSpecialEventNames.WebSocketRailsPong, @{}]];
    [_connection trigger:pong];
}

- (void)disconnect
{
    self.state = WSRDispatcherStateDisconnected;
    [_connection disconnect];
}

@end
