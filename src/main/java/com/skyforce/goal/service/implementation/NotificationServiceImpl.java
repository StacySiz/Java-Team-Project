package com.skyforce.goal.service.implementation;

import com.skyforce.goal.model.Notification;
import com.skyforce.goal.service.NotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

@Service
public class NotificationServiceImpl implements NotificationService {
    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    public void notify(Notification notification,String login){
        messagingTemplate.convertAndSendToUser(login,"/queue",notification);
        System.out.println("FINALLY ONE FUCKING SUB ");
    }
}
