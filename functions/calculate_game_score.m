function [teamA_goals, teamB_goals, inOT] = calculate_game_score(goal_pcts, teamA_i, teamB_i);
% arguments:
% - goal_pcts: matrix of goal pcts for all teams (see
%              calculate_goal_pcts.m)
% - teamA_i:   index for teamA
% - teamB_i:   index for teamB

% returns:
% - teamA_goals: simulated number of goals scored by teamA
% - teamB_goals: simulated number of goals scored by teamB

% number of goals scored by team A and B based on team A's pcts
teamAA_goals = max(find([0 cumsum(goal_pcts(teamA_i,1:15))]  <= rand())) - 1;
teamAB_goals = max(find([0 cumsum(goal_pcts(teamA_i,16:30))] <= rand())) - 1;

% number of goals scored by team A and B based on team B's pcts
teamBB_goals = max(find([0 cumsum(goal_pcts(teamB_i,1:15))]  <= rand())) - 1;
teamBA_goals = max(find([0 cumsum(goal_pcts(teamA_i,16:30))] <= rand())) - 1;

% find average for goals scored
teamA_goals = mean([teamAA_goals, teamBA_goals]);
teamB_goals = mean([teamBB_goals, teamAB_goals]);

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

