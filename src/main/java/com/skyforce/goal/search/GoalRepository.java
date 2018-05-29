package com.skyforce.goal.search;

import com.skyforce.goal.model.Goal;
import com.skyforce.goal.model.User;
import org.springframework.data.elasticsearch.repository.ElasticsearchRepository;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface GoalRepository extends ElasticsearchRepository<Goal, Long> {
    Optional<Goal> findGoalByName(String name);

    List<Goal> findGoalsByUser(User user);

    Goal findGoalById(Long id);

    @Override
    Iterable<Goal> findAll();
}
