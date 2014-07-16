//
//  WebSocketRailsConnection.h
//  WebSocketRails-iOS
//
//  Created by Evgeny Lavrik on 17.12.13.
//  Copyright (c) 2013 Evgeny Lavrik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SRWebSocket.h>
@class WebSocketRailsEvent;
@class WebSocketRailsConnection;

typedef NS_ENUM(NSUInteger, WSRDispatcherState) {
    WSRDispatcherStateConnected,
    WSRDispatcherStateConnecting,
    WSRDispatcherStateDisconnected
};

@protocol WebSocketRailsConnectionDelegate <NSObject>

@property (readonly) WSRDispatcherState state;

- (void)connection:(WebSocketRailsConnection *)connection didReceiveMessages:(NSDictionary *)messages;

@optional

- (void)connectionDidOpen:(WebSocketRailsConnection *)connection;
- (void)connection:(WebSocketRailsConnection *)connection didFailWithError:(NSError *)error;
- (void)connection:(WebSocketRailsConnection *)connection didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;

@end

@interface WebSocketRailsConnection : NSObject

@property (weak) id<WebSocketRailsConnectionDelegate> delegate;

- (id)initWithUrl:(NSURL *)url delegate:(id<WebSocketRailsConnectionDelegate>)delegate;

- (void)trigger:(WebSocketRailsEvent *)event;
- (void)flushQueue:(NSNumber *)id;

- (void)disconnect;

@end
