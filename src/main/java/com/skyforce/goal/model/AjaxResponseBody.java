package com.skyforce.goal.model;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class AjaxResponseBody {

    String msg;
    List<User> result;

}
