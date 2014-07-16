//
//  WebSocketRailsEvent.h
//  WebSocketRails-iOS
//
//  Created by Evgeny Lavrik on 17.12.13.
//  Copyright (c) 2013 Evgeny Lavrik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebSocketRailsTypes.h"

extern const struct WSRSpecialEventNames {
    __unsafe_unretained NSString *ClientConnected;
    __unsafe_unretained NSString *WebSocketRailsPong;
    __unsafe_unretained NSString *WebSocketRailsPing;
    __unsafe_unretained NSString *WebSocketRailsSubscribe;
    __unsafe_unretained NSString *WebSocketRailsSubscribePrivate;
    __unsafe_unretained NSString *WebSocketRailsUnscubscribe;
} WSRSpecialEventNames;

extern const struct WSREventAttributeKeys {
    __unsafe_unretained NSString *id;
    __unsafe_unretained NSString *channel;
    __unsafe_unretained NSString *data;
    __unsafe_unretained NSString *success;
} WSREventAttributeKeys;

@interface WebSocketRailsEvent : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) id attr;
@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, strong) NSString *channel;
@property (nonatomic, strong) id data;
@property (nonatomic, strong) NSNumber *connectionId;
@property (nonatomic, assign) BOOL success;
@property (nonatomic, assign) BOOL result;

- (id)initWithData:(id)data;
- (id)initWithData:(id)data success:(EventCompletionBlock)success failure:(EventCompletionBlock)failure;

- (BOOL)isChannel;
- (BOOL)isResult;
- (BOOL)isPing;
- (NSString *)serialize;
- (id)attributes;

- (void)runCallbacks:(BOOL)success eventData:(id)eventData;

@end
