function [GF_pcts, GA_pcts, OG_pcts] = calculate_goal_pcts(team_i, games, played_rng)
% arguments:
% - team_i:     the index of the team to calculate
% - games:      matrix of game data (taken from CSV file)
% - played_rng: a range of games already played (given end date)

% returns:
% - GF_pcts: array containing probabilities of scoring particular
%            number of goals. 
%            ex: GF_pcts(4) = probability of scoring 4 goals
% - GA_pcts: array containing probabilities of letting up particular 
%            number of goals
%            ex: GA_pcts(4) = probability of scoring 4 goals
% - OT_goals_pcts: probability of a team scoring in OT

    team_home_rng = intersect(played_rng, find(games(:,5) == team_i));
    team_away_rng = intersect(played_rng, find(games(:,8) == team_i));
    team_reg_rng  = intersect(find(games(played_rng,11) == 0), union(team_away_rng,team_home_rng));
    team_OT_rng   = setdiff(union(team_away_rng,team_home_rng), team_reg_rng);
    team_win_rng  = union(intersect(find(games(:,7) == 1), team_home_rng), ...
                          intersect(find(games(:,10) == 1),team_away_rng));
    team_loss_rng = setdiff(union(team_away_rng,team_home_rng), team_win_rng);

    % determine the spread of goals scored and against in regular season
    GF_pcts = zeros(1,15);
    GA_pcts = zeros(1,15);
    for i = 1:15
        % number of times i goals scored in regular game
        reg_GF  = sum(games(intersect(team_home_rng, team_reg_rng), 6) == i - 1) + ...
                  sum(games(intersect(team_away_rng, team_reg_rng), 9) == i - 1);
              
        % number of times i goals scored against in regular game
        reg_GA  = sum(games(intersect(team_home_rng, team_reg_rng), 9) == i - 1) + ...
                  sum(games(intersect(team_away_rng, team_reg_rng), 6) == i - 1);

        % number of times i goals scored in OT game and team lost          
        OT_L_occurence = sum(games(intersect(intersect(team_home_rng,team_OT_rng),team_loss_rng),6) == i - 1) + ...
                         sum(games(intersect(intersect(team_away_rng,team_OT_rng),team_loss_rng),9) == i - 1);

        % number of times i + 1 goals scored in OT game and team won 
        OT_W_occurence = sum(games(intersect(intersect(team_home_rng,team_OT_rng),team_win_rng),6) == i) + ...
                         sum(games(intersect(intersect(team_away_rng,team_OT_rng),team_win_rng),9) == i);

        GF_pcts(i) = (reg_GF + OT_L_occurence + OT_W_occurence) / ...
                      size(union(team_home_rng,team_away_rng),1);
                  
        GA_pcts(i) = (reg_GA + OT_L_occurence + OT_W_occurence) / ...
                      size(union(team_home_rng,team_away_rng),1);
    end

    % determine OT goals
    OG_pcts = (sum(games(intersect(team_away_rng,team_OT_rng),10)) +  ...
                     sum(games(intersect(team_home_rng,team_OT_rng), 7))) / ...
                     max(size(team_OT_rng,1),1);
end

