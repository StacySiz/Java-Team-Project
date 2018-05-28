package com.skyforce.goal.service;

import com.skyforce.goal.model.Notification;

public interface NotificationService {
    public void notify(Notification notification,String login);
}
