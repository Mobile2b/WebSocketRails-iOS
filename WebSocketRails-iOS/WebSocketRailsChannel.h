//
//  WebSocketRailsChannel.h
//  WebSocketRails-iOS
//
//  Created by Evgeny Lavrik on 17.12.13.
//  Copyright (c) 2013 Evgeny Lavrik. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>
#import "WebSocketRailsEvent.h"
#import "WebSocketRailsDispatcher.h"
#import "WebSocketRailsTypes.h"

@class WebSocketRailsDispatcher;

@interface WebSocketRailsChannel : NSObject

@property (nonatomic, assign) BOOL isPrivate;

- (id)initWithName:(NSString *)name dispatcher:(WebSocketRailsDispatcher *)dispatcher private:(BOOL)private;

/**
 *  Use this method to add a callback for the specified event name. The callback will be called every time an event with this name occurs in this channel.
 *
 *  @param eventName the name of the event for which the callback should be registered.
 *  @param callback  the callback to call whenever such an event occurs
 */
- (void)bindToEventWithName:(NSString *)eventName callback:(EventCompletionBlock)callback;

- (void)dispatch:(NSString *)eventName message:(id)message;
- (void)destroy;

- (void)trigger:(NSString *)eventName message:(id)message;

@end
