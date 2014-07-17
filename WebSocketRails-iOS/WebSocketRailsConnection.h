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
@property (nonatomic, strong) NSNumber *connectionId;

- (id)initWithUrl:(NSURL *)url delegate:(id<WebSocketRailsConnectionDelegate>)delegate;

/**
 *  Sends a message for the specified event (with the connection id of this connection) or enqueues the message to be send later if the connection is not (yet) connected.
 *
 *  @param event the event to send. This will be serialized and the connection-id will be added before sending it.
 */
- (void)trigger:(WebSocketRailsEvent *)event;

/**
 *  Sends all the enqueued messages (the connection id of the connection at the moment this method is called will be used to send the messages)
 */
- (void)flushQueue;

- (void)disconnect;

@end
