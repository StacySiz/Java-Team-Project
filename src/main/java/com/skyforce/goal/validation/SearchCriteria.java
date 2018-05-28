package com.skyforce.goal.validation;

import lombok.Getter;
import lombok.Setter;
import org.hibernate.validator.constraints.NotBlank;

@Getter
@Setter
public class SearchCriteria {

    @NotBlank(message = "login can't empty!")
    String login;

}
