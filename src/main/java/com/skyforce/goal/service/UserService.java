package com.skyforce.goal.service;

import com.skyforce.goal.model.User;

import java.util.List;

public interface UserService {
    User findUserByLogin(String login);

    public List<User> findListOfUserByLogin(String login);

}

