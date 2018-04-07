package com.skyforce.goal.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.Date;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class GoalDto {
    private String goalName;
    private String description;
    //private int price;
    private Date dateEnd;
}
