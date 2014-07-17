//
//  WebSocketRailsEvent.m
//  WebSocketRails-iOS
//
//  Created by Evgeny Lavrik on 17.12.13.
//  Copyright (c) 2013 Evgeny Lavrik. All rights reserved.
//

#import "WebSocketRailsEvent.h"

const struct WSRSpecialEventNames WSRSpecialEventNames = {
    .ClientConnected = @"client_connected",
    .WebSocketRailsPong = @"websocket_rails.pong",
    .WebSocketRailsPing = @"websocket_rails.ping",
    .WebSocketRailsSubscribe = @"websocket_rails.subscribe",
    .WebSocketRailsSubscribePrivate = @"websocket_rails.subscribe_private",
    .WebSocketRailsUnscubscribe = @"websocket_rails.unsubscribe"
};

const struct WSREventAttributeKeys WSREventAttributeKeys = {
    .id = @"id",
    .channel = @"channel",
    .data = @"data",
    .success = @"success"
};

@interface WebSocketRailsEvent()

@property (nonatomic, copy) EventCompletionBlock successCallback;
@property (nonatomic, copy) EventCompletionBlock failureCallback;

@end

@implementation WebSocketRailsEvent

- (id)initWithData:(id)data success:(EventCompletionBlock)success failure:(EventCompletionBlock)failure
{
    self = [super init];
    if (self) {
        _name = data[0];
        _attr = data[1];
        
        if (_attr)
        {
            if (_attr[WSREventAttributeKeys.id] && _attr[WSREventAttributeKeys.id] != [NSNull null])
                _id = _attr[WSREventAttributeKeys.id];
            else
                _id = [NSNumber numberWithInt:rand()];
            
            if (_attr[WSREventAttributeKeys.channel] && _attr[WSREventAttributeKeys.channel] != [NSNull null])
                _channel = _attr[WSREventAttributeKeys.channel];
            
            if (_attr[WSREventAttributeKeys.data] && _attr[WSREventAttributeKeys.data] != [NSNull null])
                _data = _attr[WSREventAttributeKeys.data];
            
            if ([data count] > 2 && data[2] && data[2] != [NSNull null])
                _connectionId = data[2];
            else
                _connectionId = @0;
            
            if (_attr[WSREventAttributeKeys.success] && _attr[WSREventAttributeKeys.success] != [NSNull null])
            {
                _result = YES;
                _success = (BOOL) _attr[WSREventAttributeKeys.success];
            }
        }
        
        self.successCallback = success;
        self.failureCallback = failure;
    }
    return self;
}

- (id)initWithData:(id)data{
    return [self initWithData:data success:nil failure:nil];
}

- (BOOL)isChannel
{
    return [_channel length];
}

- (BOOL)isResult
{
    return _result;
}

- (BOOL)isPing
{
    return [_name isEqualToString:WSRSpecialEventNames.WebSocketRailsPing];
}

- (NSString *)serialize
{
    NSArray *array =
            @[_name,
             [self attributes]
              ]; // TODO: shouldn't the connection_id be serialized as well? But it's not done in the JavaScript client either: https://github.com/websocket-rails/websocket-rails/blob/master/lib/assets/javascripts/websocket_rails/event.js.coffee
    
    return [NSString.alloc initWithData:[NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
}

- (id)attributes
{
    return @{WSREventAttributeKeys.id: _id ?: [NSNull null],
             WSREventAttributeKeys.channel: _channel ?: [NSNull null],
             WSREventAttributeKeys.data: _data ?: [NSNull null]
             };
}

- (void)runCallbacks:(BOOL)success eventData:(id)eventData
{
    if (success && _successCallback)
        _successCallback(eventData);
    else {
    
    if (_failureCallback)
        _failureCallback(eventData);
    }
}

@end
