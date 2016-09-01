teamA_str = 'SJS';
teamB_str = 'PIT';
teamA_i   = ceil(strfind(teams,teamA_str) / 3);
teamB_i   = ceil(strfind(teams,teamB_str) / 3);

num_iter = 1;
avgs     = [0 0 0];
for i = 1:num_iter
    [teamA_goals, teamB_goals, inOT] = calculate_game_score(goal_pcts, teamA_i, teamB_i);
    avgs = avgs + [teamA_goals, teamB_goals, inOT];
end

avgs = avgs / num_iter


