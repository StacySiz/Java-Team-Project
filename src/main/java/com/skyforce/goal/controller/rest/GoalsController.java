package com.skyforce.goal.controller.rest;

import com.skyforce.goal.model.Goal;
import com.skyforce.goal.model.User;
import com.skyforce.goal.service.AuthenticationService;
import com.skyforce.goal.service.GoalService;
import com.skyforce.goal.service.UserService;
//import com.skyforce.goal.service.implementation.HibernateSearchService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
public class GoalsController {


    @Autowired
    private AuthenticationService authenticationService;

    @Autowired
    private GoalService goalService;

    @Autowired
    private UserService userService;

    @GetMapping("/goals/{id}")
    public ResponseEntity<Goal> getGoalsById (@PathVariable ("id") Long id) {
        return ResponseEntity.ok(this.goalService.findGoalById(id));

    }

//    @GetMapping("/goal/{id}")
//    public String getGoalPage(Authentication authentication, Model model, @PathVariable("id") Long id) {
//        Goal goal = goalService.findGoalById(id);
//        model.addAttribute("goal", goal);
//        model.addAttribute("user", authenticationService.getUserByAuthentication(authentication));
//
//        return "goal";
//    }
//
//    @GetMapping("/user/myGoals")
//    public String getMyGoals(Authentication authentication, Model model) {
//        User user = authenticationService.getUserByAuthentication(authentication);
//        model.addAttribute("user", user);
//        model.addAttribute("myGoals", goalService.findGoalsByUser(user));
//
//        return "my-goals";
//    }

//    @GetMapping(value = "/search")
//    public String search(@RequestParam(value = "search", required = false) String q, Model model) {
//        List<Goal> searchResults = null;
//
//        model.addAttribute("search", searchResults);
//        return "search-test";
//    }

}
