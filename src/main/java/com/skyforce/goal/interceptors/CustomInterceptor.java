//package com.skyforce.goal.interceptors;
//
//import org.springframework.messaging.Message;
//import org.springframework.messaging.MessageChannel;
//import org.springframework.messaging.simp.stomp.StompCommand;
//import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
//import org.springframework.messaging.support.ChannelInterceptorAdapter;
//import org.springframework.messaging.support.MessageHeaderAccessor;
//import org.springframework.stereotype.Component;
//
//@Component
//public class CustomInterceptor extends ChannelInterceptorAdapter {
//
//    @Override
//    public Message<?> preSend(Message<?> message, MessageChannel channel) {
//        StompHeaderAccessor accessor = MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);
//        if (accessor.getCommand().equals(StompCommand.CONNECT)) {
//            System.out.println("client connected");
//        } else if (accessor.getCommand().equals(StompCommand.SUBSCRIBE)) {
//            System.out.println("+1 subscriber");
//        } else if (accessor.getCommand().equals(StompCommand.SEND)) {
//            System.out.println("Message [" + message + "] was sent");
//        }
//        return message;
//    }
//}