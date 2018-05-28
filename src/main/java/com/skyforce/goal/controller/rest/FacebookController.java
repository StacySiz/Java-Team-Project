package com.skyforce.goal.controller.rest;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.security.Principal;

@RestController
public class FacebookController {

    @GetMapping("/registerFb")
    public Principal registerFb(Principal principal) {
        return principal;
    }
}
