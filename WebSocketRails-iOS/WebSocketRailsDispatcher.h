//
//  WebSocketRailsDispatcher.h
//  WebSocketRails-iOS
//
//  Created by Evgeny Lavrik on 17.12.13.
//  Copyright (c) 2013 Evgeny Lavrik. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>
#import "WebSocketRailsEvent.h"
#import "WebSocketRailsChannel.h"
#import "WebSocketRailsTypes.h"

@class WebSocketRailsChannel;

typedef NS_ENUM(NSUInteger, WSRDispatcherState) {
    WSRDispatcherStateConnected,
    WSRDispatcherStateConnecting,
    WSRDispatcherStateDisconnected
};

@interface WebSocketRailsDispatcher : NSObject

@property (assign) WSRDispatcherState state;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSMutableDictionary *channels;
@property (nonatomic, strong) NSNumber *connectionId;

- (id)initWithUrl:(NSURL *)url;

- (void)dispatch:(WebSocketRailsEvent *)event;
- (void)newMessage:(NSArray *)data;
/**
 *  Use this method so register add a callback for the specified event name. The callback will be called every time an event with this name occurs, which is not a channel-specific event.
 *
 *  @param eventName the name of the event for which the callback should be registered. See WSRSpecialEventNames for some special connection-related cases.
 *  @param callback  the callback to call whenever such an event occurs
 *
 *  @discussion You can also use this to register a callback e.g. for a connection-close event (WSRSpecialEventNames.ConnectionClosed)
 */
- (void)bindToEventWithName:(NSString *)eventName callback:(EventCompletionBlock)callback;
- (void)trigger:(NSString *)eventName data:(id)data success:(EventCompletionBlock)success failure:(EventCompletionBlock)failure;
- (void)triggerEvent:(WebSocketRailsEvent *)event;

/**
 *  Creates a new channel object (or returns an existing channel) that handles events on the specified channel. Use the returned channel object to register for specific events in that channel.
 *
 *  @param channelName the name of the channel to subscribe to.
 *
 *  @return a WebSocketRailsChannel object which can be used to listen to specific events in that channel
 * 
 *  @see -unsubscribe
 */
- (WebSocketRailsChannel *)subscribeToChannelWithName:(NSString *)channelName;

/**
 *  Sends an unsubscribe message (if a subscription existed) for the specified channel and destroys the channel.
 *
 *  @param channelName the name of the channel to unsubscribe from
 *
 *  @discussion Be careful, this unsubscribes from the channel completely, so other listeners of this channel would be unsubscribed as well.
 */
- (void)unsubscribeFromChannelWithName:(NSString *)channelName;

- (void)disconnect;

@end
