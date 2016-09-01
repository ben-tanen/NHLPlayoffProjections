% define teams and conferences
teams       = ['ANA', 'ARI', 'BOS', 'BUF', 'CGY', 'CAR', 'CHI', 'COL', ...
               'CBJ', 'DAL', 'DET', 'EDM', 'FLA', 'LAK', 'MIN', 'MTL', ...
               'NSH', 'NJD', 'NYI', 'NYR', 'OTT', 'PHI', 'PIT', 'SJS', ...
               'STL', 'TBL', 'TOR', 'VAN', 'WSH', 'WPG'];
metropolitan_rng = [6 9 18 19 20 22 23 29];
atlantic_rng     = [3 4 11 13 16 21 26 27];
central_rng      = [7 8 10 15 17 25 30];
pacific_rng      = [1 2  5 12 14 24 28];

% get game information and set start date for simultation 
sim_date    = [2016, 4, 10];
games       = csvread('all_games_201516.csv', 2, 0);
dates       = unique(datenum(games(:,2),games(:,3),games(:,4)));
real_points = generate_points_matrix(dates, games);

% get games played (given start date)
played_rng    = find(games(:,2) <  sim_date(1) | ... % year is less
                     games(:,2) == sim_date(1)   ...
                   & games(:,3) <  sim_date(2) | ... % month is less
                     games(:,2) == sim_date(1) & games(:,3) == sim_date(2) ...
                   & games(:,4) <= sim_date(3)); % day is less (or equal)
unplayed_rng  = setdiff(games(:,1),played_rng);
               
% stores pcts of particular team to score certain number of goals
% goals_pcts(i,j ) = prob of team i scoring j goals in reg. time (1 <= j <= 15)
% goals_pcts(i,j ) = prob of team i letting up j goals in regulation
%                    (16 <= j <= 30)
% goals_pcts(i,31) = prob of team i scoring in OT
goal_pcts = zeros(30,31);
for i = 1:30,
    [GF_pcts, GA_pcts, OG_pcts] = calculate_goal_pcts(i, games, played_rng);
    goal_pcts(i,:)              = [GF_pcts, GA_pcts, OG_pcts];
end

%% simulate season many times
num_iter   = 100; 
avg_points = [dates zeros(size(dates,1),30)];

% monte carlo simulation
for n = 1:num_iter
    % determine outcome of remaining games
    games(unplayed_rng,[6 7 9 10 11]) = 0; % reset unplayed games
    for i = unplayed_rng'
        % for each game, calculate score and adjust points
        teamA_i = games(i,5);
        teamB_i = games(i,8);
        [teamA_goals, teamB_goals, inOT] = calculate_game_score(goal_pcts, teamA_i, teamB_i);
        games(i,[6 7])  = [teamA_goals (teamA_goals > teamB_goals)];
        games(i,[9 10]) = [teamB_goals (teamA_goals < teamB_goals)];
        games(i,11)     = inOT;
    end

    % convert game results into points per team
    points = generate_points_matrix(dates, games);
    avg_points(:,2:end) = avg_points(:,2:end) + points(:,2:end);
end

avg_points(:,2:end) = avg_points(:,2:end) / num_iter;

%% plotting point data (projected vs. actual)
% team colors
team_colors = zeros(30,3);
team_colors(1,:)  = [145, 118,  75] / 255; % ANA gold
team_colors(2,:)  = [132,  31,  39] / 255; % ARI red
team_colors(3,:)  = [255, 196,  34] / 255; % BOS yellow
team_colors(4,:)  = [  0,  46,  98] / 255; % BUF blue
team_colors(5,:)  = [224,  58,  62] / 255; % CGY red
team_colors(6,:)  = [224,  58,  62] / 255; % CAR red
team_colors(7,:)  = [227,  38,  58] / 255; % CHI red
team_colors(8,:)  = [139,  41,  66] / 255; % COL maroon
team_colors(9,:)  = [  0,  40,  92] / 255; % CBJ blue
team_colors(10,:) = [  0, 106,  78] / 255; % DAL green
team_colors(11,:) = [236,  31,  38] / 255; % DET red
team_colors(12,:) = [230, 106,  32] / 255; % EDM orange
team_colors(13,:) = [213, 156,   5] / 255; % FLA yellow
team_colors(14,:) = [  0,   0,   0] / 255; % LAK black
team_colors(15,:) = [  2,  87,  54] / 255; % MIN green
team_colors(16,:) = [191,  47,  56] / 255; % MTL red
team_colors(17,:) = [253, 187,  47] / 255; % NSH yellow
team_colors(18,:) = [224,  58,  62] / 255; % NJD red
team_colors(19,:) = [245, 125,  49] / 255; % NYI orange
team_colors(20,:) = [  1,  97, 171] / 255; % NYR blue
team_colors(21,:) = [228,  23,  62] / 255; % OTT red
team_colors(22,:) = [244, 121,  64] / 255; % PHL orange
team_colors(23,:) = [209, 189, 128] / 255; % PIT gold
team_colors(24,:) = [  5,  83,  93] / 255; % SJS blue
team_colors(25,:) = [  5,  70, 160] / 255; % STL blue
team_colors(26,:) = [  1,  62, 125] / 255; % TBL blue
team_colors(27,:) = [  0,  55, 119] / 255; % TOR blue
team_colors(28,:) = [  4, 122,  74] / 255; % VAN green
team_colors(29,:) = [224,  23,  59] / 255; % WSH red
team_colors(30,:) = [168, 169, 173] / 255; % WPG silver

teams_to_plot     = [1, 16, 23];
clf

% plot simultation starting date
d = datetime(sim_date(1),sim_date(2),sim_date(3));
plot([d d], [0, 140], '-', 'Color', [0 0 0], 'DisplayName', 'Simulation Begins');

% plot team data
hold on
for t = teams_to_plot
    plot(dates, real_points(:,t + 1), '-', 'Color', team_colors(t,:), 'DisplayName', strcat(teams(t*3-2:t*3), ' Actual'));
    plot(dates, avg_points(:,t + 1), '--', 'Color', team_colors(t,:), 'DisplayName', strcat(teams(t*3-2:t*3), ' Projected'));
end

axis([datenum(2015,10,1) datenum(2016,4,10) 0 125])
title(strcat('Actual Performance vs. Projected (Simulation Starting   ',datestr(d), ')'))
legend('Location','northwest')
ylabel('Points')
hold off

%% generate standings
proj_div_rank  = zeros(1,30);
proj_conf_rank = zeros(1,30);
real_div_rank  = zeros(1,30);
real_conf_rank = zeros(1,30);

proj_sorted_a = sort(avg_points(end,atlantic_rng+1),'descend');
proj_sorted_m = sort(avg_points(end,metropolitan_rng+1),'descend');
proj_sorted_e = sort(avg_points(end,union(atlantic_rng,metropolitan_rng)+1),'descend');
proj_sorted_p = sort(avg_points(end,pacific_rng+1),'descend');
proj_sorted_c = sort(avg_points(end,central_rng+1),'descend');
proj_sorted_w = sort(avg_points(end,union(central_rng,pacific_rng)+1),'descend');

real_sorted_a = sort(real_points(end,atlantic_rng+1),'descend');
real_sorted_m = sort(real_points(end,metropolitan_rng+1),'descend');
real_sorted_e = sort(real_points(end,union(atlantic_rng,metropolitan_rng)+1),'descend');
real_sorted_p = sort(real_points(end,pacific_rng+1),'descend');
real_sorted_c = sort(real_points(end,central_rng+1),'descend');
real_sorted_w = sort(real_points(end,union(central_rng,pacific_rng)+1),'descend');

for team_i = 1:30
    % determine division and conference
    if (sum(ismember(pacific_rng, team_i)) == 1)
        proj_div_rank(team_i)  = find(avg_points(end,team_i+1) == proj_sorted_p,1);
        proj_conf_rank(team_i) = find(avg_points(end,team_i+1) == proj_sorted_w,1);
        real_div_rank(team_i)  = find(real_points(end,team_i+1) == real_sorted_p,1);
        real_conf_rank(team_i) = find(real_points(end,team_i+1) == real_sorted_w,1);
        
    elseif (sum(ismember(central_rng, team_i)) == 1)
        proj_div_rank(team_i)  = find(avg_points(end,team_i+1) == proj_sorted_c,1);
        proj_conf_rank(team_i) = find(avg_points(end,team_i+1) == proj_sorted_w,1);
        real_div_rank(team_i)  = find(real_points(end,team_i+1) == real_sorted_c,1);
        real_conf_rank(team_i) = find(real_points(end,team_i+1) == real_sorted_w,1);
        
    elseif (sum(ismember(atlantic_rng, team_i)) == 1)
        proj_div_rank(team_i)  = find(avg_points(end,team_i+1) == proj_sorted_a,1);
        proj_conf_rank(team_i) = find(avg_points(end,team_i+1) == proj_sorted_e,1);
        real_div_rank(team_i)  = find(real_points(end,team_i+1) == real_sorted_a,1);
        real_conf_rank(team_i) = find(real_points(end,team_i+1) == real_sorted_e,1);
        
    elseif (sum(ismember(metropolitan_rng, team_i)) == 1)
        proj_div_rank(team_i)  = find(avg_points(end,team_i+1) == proj_sorted_m,1);
        proj_conf_rank(team_i) = find(avg_points(end,team_i+1) == proj_sorted_e,1);
        real_div_rank(team_i)  = find(real_points(end,team_i+1) == real_sorted_m,1);
        real_conf_rank(team_i) = find(real_points(end,team_i+1) == real_sorted_e,1);
    end
end

%% error analysis
cutoff = 7;
under_cutoff = 0;

team_means = mean(real_points(:,2:end) - avg_points(:,2:end));
for i = 1:30
    team_diff = real_points(:,i+1) - avg_points(:,i+1);
    [max_team_v, max_team_i] = max(abs(team_diff));
    conf_rank_diff = real_conf_rank(i) - proj_conf_rank(i);
    div_rank_diff  = real_div_rank(i)  - proj_div_rank(i);
    
    if (abs(real_points(end,i+1) - avg_points(end,i+1)) <= cutoff), under_cutoff = under_cutoff + 1;
    end;
    
    disp([teams(i*3-2:i*3), ' => max difference:  ', num2str(real_points(max_team_i,i+1) - avg_points(max_team_i,i+1))]);
    disp(['       mean difference: ', num2str(team_means(i))]);
    disp(['       end difference:  ', num2str(real_points(end,i+1) - avg_points(end,i+1)), ' [', num2str(real_points(end,i+1)), ', ', num2str(avg_points(end,i+1)),']']);
    disp(['       conf. rank diff: ', num2str(real_conf_rank(i) - proj_conf_rank(i)), ' [', num2str(real_conf_rank(i)), ', ', num2str(proj_conf_rank(i)), ']']);
    disp(['       div.  rank diff: ', num2str(real_div_rank(i) - proj_div_rank(i)), ' [', num2str(real_div_rank(i)), ', ', num2str(proj_div_rank(i)), ']']);
end

disp(' ');
disp(['avg diff in conf rank:    ', num2str(mean(abs(real_conf_rank - proj_conf_rank)))]);
disp(['avg diff in div rank:     ', num2str(mean(abs(real_div_rank - proj_div_rank)))]);
disp(['overall mean diff (abs):  ', num2str(mean(mean(abs(real_points(:,2:end) - avg_points(:,2:end)))))]);

% end difference
diff  = real_points(end,2:end) - avg_points(end,2:end);
[max_v,   max_i]    = max(diff);
[min_v,   min_i]    = min(diff);

disp(['average end diff (abs):   ', num2str(mean(abs(diff)))]);
disp(['max end diff (pos):       ', num2str(max_v), '  (', teams(max_i*3-2:max_i*3), ')']);
disp(['max end diff (neg):       ', num2str(min_v), ' (', teams(min_i*3-2:min_i*3), ')']);
disp(['teams under pt_diff (', num2str(cutoff),'):  ', num2str(under_cutoff)]);

