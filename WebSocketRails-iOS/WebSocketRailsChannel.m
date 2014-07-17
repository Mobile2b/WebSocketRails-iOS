//
//  WebSocketRailsChannel.m
//  WebSocketRails-iOS
//
//  Created by Evgeny Lavrik on 17.12.13.
//  Copyright (c) 2013 Evgeny Lavrik. All rights reserved.
//

#import "WebSocketRailsChannel.h"

NSString *const WSRChannelSubscriptionMessageDataChannelKey = @"channel";

@interface WebSocketRailsChannel()

@property (nonatomic, strong) NSString *eventName;
@property (nonatomic, strong) NSMutableDictionary *callbacks;
@property (nonatomic, strong) NSString *channelName;
@property (nonatomic, strong) WebSocketRailsDispatcher *dispatcher;
@property (readonly, getter = isPrivate) BOOL private;

@end

@implementation WebSocketRailsChannel

- (id)initWithName:(NSString *)channelName dispatcher:(WebSocketRailsDispatcher *)dispatcher private:(BOOL)private
{
    self = [super init];
    if (self) {
        
        _channelName = channelName;
        _dispatcher = dispatcher;
        _private = private;
        
        // Mutable disctionary of mutable arrays
        _callbacks = [NSMutableDictionary dictionary];
        
        [self sendSubscriptionEvent];
    }
    return self;
}

- (void)resubscribe
{
    [self sendSubscriptionEvent];
}

- (void)sendSubscriptionEvent
{
    NSString *eventName = [self isPrivate] ? WSRSpecialEventNames.WebSocketRailsSubscribePrivate : WSRSpecialEventNames.WebSocketRailsSubscribe;
    WebSocketRailsEvent *event = [WebSocketRailsEvent.alloc initWithData:@[
                                                                           eventName,
                                                                           @{WSREventAttributeKeys.data:
                                                                                 @{WSRChannelSubscriptionMessageDataChannelKey : _channelName}
                                                                             }
                                                                           ]
                                                                 success:nil failure:nil];
    
    [self.dispatcher triggerEvent:event];
}

- (void)bindToEventWithName:(NSString *)eventName callback:(EventCompletionBlock)callback;
{
    if (!_callbacks[eventName])
        _callbacks[eventName] = [NSMutableArray array];
    
    [_callbacks[eventName] addObject:[callback copy]];
}

- (void)trigger:(NSString *)eventName message:(id)message
{
    WebSocketRailsEvent *event = [WebSocketRailsEvent.alloc initWithData:@[
                                                                           eventName,
                                                                           @{WSREventAttributeKeys.channel: _channelName,
                                                                             WSREventAttributeKeys.data: message
                                                                             }
                                                                           ]
                                                                 success:nil
                                                                 failure:nil];
    [_dispatcher triggerEvent:event];
}

- (void)dispatch:(NSString *)eventName message:(id)message
{
    if (!_callbacks[eventName])
        return;
    
    for (EventCompletionBlock callback in _callbacks[eventName])
    {
        callback(message);
    }
}

- (void)destroy
{
    NSString *eventName = WSRSpecialEventNames.WebSocketRailsUnscubscribe;
    WebSocketRailsEvent *event = [WebSocketRailsEvent.alloc initWithData:@[
                                                                           eventName,
                                                                           @{WSREventAttributeKeys.data:
                                                                                 @{WSRChannelSubscriptionMessageDataChannelKey : _channelName}
                                                                             }
                                                                           ]
                                  ];
    
    [_dispatcher triggerEvent:event];
    [_callbacks removeAllObjects];
}

@end
