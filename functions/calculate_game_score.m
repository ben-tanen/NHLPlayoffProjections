function [teamA_goals, teamB_goals, inOT] = calculate_game_score(goal_pcts, teamA_i, teamB_i);
% arguments:
% - goal_pcts: matrix of goal pcts for all teams (see
%              calculate_goal_pcts.m)
% - teamA_i:   index for teamA
% - teamB_i:   index for teamB

% returns:
% - teamA_goals: simulated number of goals scored by teamA
% - teamB_goals: simulated number of goals scored by teamB

teamA_goals = max(find([0 cumsum(goal_pcts(teamA_i,1:15))] <= rand())) - 1;
teamB_goals = max(find([0 cumsum(goal_pcts(teamB_i,1:15))] <= rand())) - 1;

% if game goes to OT
if (teamA_goals == teamB_goals)
    inOT = 1;
    
    % if teamA has better OT odds
    if (goal_pcts(teamA_i,16) >= goal_pcts(teamB_i,16)) 
        teamA_goals = teamA_goals + 1;
    else
        teamB_goals = teamB_goals + 1;
    end
else, inOT = 0;
end

