package com.skyforce.goal.controller;

import com.skyforce.goal.model.Notification;
import com.skyforce.goal.service.NotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.Message;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@Controller
public class NotificationController {
    @Autowired
    private SimpMessagingTemplate template;

    @Autowired
    private NotificationService notificationService;

//    @GetMapping("/user/activity")
//    public String getActivity(){
//
//
//        return "activity";
//    }
    @MessageMapping("/activity/{login}")
    public void sendActivity(@PathVariable("login") String login){
        Notification notification = new Notification("Someone just subscribed!");
        notificationService.notify(notification,login);
    }
//    public void sendMessage(Message<?> message, @DestinationVariable("login")String login) {
//        System.out.println(message);
//        template.convertAndSend("/activity/" + login, "hello!");
//    }

}
