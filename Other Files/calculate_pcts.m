teams       = ['ANA', 'ARI', 'BOS', 'BUF', 'CGY', 'CAR', 'CHI', 'COL', ...
               'CBJ', 'DAL', 'DET', 'EDM', 'FLA', 'LAK', 'MIN', 'MTL', ...
               'NSH', 'NJD', 'NYI', 'NYR', 'OTT', 'PHI', 'PIT', 'SJS', ...
               'STL', 'TBL', 'TOR', 'VAN', 'WSH', 'WPG'];
all_pcts    = [ ];
end_date    = [2015, 12, 31];
projection  = 1;

% calculate pcts for each team
for i = 1:(length(teams)/3)
   team = teams((i*3-2):(i*3)); % pull team name
   pcts = calculate_team_pcts(team, i, end_date); % calculate pcts
   all_pcts = [all_pcts; pcts; NaN(1,size(pcts,2))]; % add data to table
end

% determine positions for actual pcts (as opposed to NaN rows)
t = [0; find(~(all_pcts(:,1) < Inf))];

% pull game data
games = csvread('all_games_201516.csv', 2, 0);
unplayed_rng = find(games(:,2) > end_date(1) | ...
                 games(:,2) == end_date(1) & games(:,3) > end_date(2) | ...
                 games(:,2) == end_date(1) & games(:,3) == end_date(2) & games(:,4) > end_date(3));
played_rng = setdiff(games(:,1),unplayed_rng);
played   = games(played_rng,:);
unplayed = games(unplayed_rng,:);
unplayed(:,[6 7 9 10 11]) = 0;

%%
% calculate team pcts
all_pcts    = [ ];
games_to_analyze = [10, 20, 30, 50, Inf];
for i = 1:30
    pcts_t  = zeros(size(games_to_analyze,2), 8);
    games_t = played((played(:,5) == i | played(:,8) == i),:);
    n_games = size(games_t,1);
    
    % calculate pcts for each team j
    for j = 1:size(games_to_analyze,2)
        l   = min(games_to_analyze(j), n_games);
        rng = (n_games - (l - 1)):n_games;
        
        n_OT = sum(games_t(rng,11) == 1);
        n_SO = sum(games_t(rng,11) == 2);
        pcts_t(j,1) = sum(games_t(rng,11) == 0 & ...   % pct of reg loses
                         ((games_t(rng,5) == i & games_t(rng,7) == 0) | ...
                          (games_t(rng,8) == i & games_t(rng,10) == 0))) / l;
        pcts_t(j,2) = sum(games_t(rng,11) == 0 & ...   % pct of reg wins
                         ((games_t(rng,5) == i & games_t(rng,7) == 1) | ...
                          (games_t(rng,8) == i & games_t(rng,10) == 1))) / l;
        pcts_t(j,3) = (n_OT + n_SO) / l;               % pct of games to OT
        pcts_t(j,4) = sum(games_t(rng,11) == 1 & ...   % pct of OT loses
                         ((games_t(rng,5) == i & games_t(rng,7) == 0) | ...
                          (games_t(rng,8) == i & games_t(rng,10) == 0)))...
                          / (n_OT + n_SO);
        pcts_t(j,5) = sum(games_t(rng,11) == 1 & ...   % pct of OT wins
                         ((games_t(rng,5) == i & games_t(rng,7) == 1) | ...
                          (games_t(rng,8) == i & games_t(rng,10) == 1)))...
                          / (n_OT + n_SO);
        pcts_t(j,6) = (n_SO) / (n_OT + n_SO);          % pct of OT to SO
        pcts_t(j,7) = sum(games_t(rng,11) == 2 & ...   % pct of SO loses
                         ((games_t(rng,5) == i & games_t(rng,7) == 0) | ...
                          (games_t(rng,8) == i & games_t(rng,10) == 0)))...
                          / (n_SO);
        pcts_t(j,8) = sum(games_t(rng,11) == 2 & ...   % pct of SO wins
                         ((games_t(rng,5) == i & games_t(rng,7) == 1) | ...
                          (games_t(rng,8) == i & games_t(rng,10) == 1)))...
                          / (n_SO);
    end
    
    all_pcts = [all_pcts; pcts; NaN(1,size(pcts_t,2))]; % add data to table
end

%%
% using projection pcts, simulate remaining unplayed games
for i = 1:size(unplayed,1)
    team_ixs   = [unplayed(i, 5), unplayed(i, 8)];
    teamA_pcts = all_pcts((t(team_ixs(1))+1):(t(team_ixs(1)+1)-1),:);
    teamB_pcts = all_pcts((t(team_ixs(2))+1):(t(team_ixs(2)+1)-1),:);
    result     = determine_game_results(teamA_pcts(:,:), teamB_pcts(:,:));
    unplayed(i,11) = result(projection,1);
    if (result(projection,2) > result(projection,3)) % team A won
        unplayed(i,7) = 1;
    else % team B won
        unplayed(i,10) = 1;
    end
end

games(unplayed_rng,:) = unplayed;

% convert game results into points per team
points = [datenum(games(1,2),games(1,3),games(1,4)) zeros(1,30)];

for i = 1:size(games,1)
   d = datenum(games(i,2),games(i,3),games(i,4));
   if (d ~= points(end,1))
       points = [points; d points(end,2:end)];
   end
   
   if (games(i,7) == 1 & games(i,11) == 0)
       points(end,games(i,5)+1) = points(end,games(i,5)+1) + 2;
   elseif (games(i,10) == 1 & games(i,11) == 0)
       points(end,games(i,8)+1) = points(end,games(i,8)+1) + 2;
   elseif (games(i,7) == 1)
       points(end,games(i,5)+1) = points(end,games(i,5)+1) + 2;
       points(end,games(i,8)+1) = points(end,games(i,8)+1) + 1;
   else
       points(end,games(i,5)+1) = points(end,games(i,5)+1) + 1;
       points(end,games(i,8)+1) = points(end,games(i,8)+1) + 2;
   end
end

dates = datetime(points(1:end,1), 'ConvertFrom', 'datenum');

%% get eastern conference
metropolitan_rng = [6 9 18 19 20 22 23 29];
atlantic_rng     = [3 4 11 13 16 21 26 27];
central_rng      = [7 8 10 15 17 25 30];
pacific_rng      = [1 2  5 12 14 24 28];

eastern_rng      = union(metropolitan_rng, atlantic_rng);
western_rng      = union(central_rng, pacific_rng);

positions = NaN(size(points,1),30*2);

for i = 1:size(points,1) % loop through each day
    sorted_metropolitan = sort(points(i, metropolitan_rng + 1), 'descend');
    sorted_atlantic     = sort(points(i, atlantic_rng + 1), 'descend');
    sorted_eastern      = sort(points(i, eastern_rng + 1), 'descend');
    sorted_central      = sort(points(i, central_rng + 1), 'descend');
    sorted_pacific      = sort(points(i, pacific_rng + 1), 'descend');
    sorted_western      = sort(points(i, western_rng+1), 'descend');
    
    for j = 1:30 % loop through each team
        t_points = points(i,j+1);
        if (find(j == eastern_rng)) % team in eastern conference
            % calculate position in division
            if (find(j == metropolitan_rng)) % team in metro division
                positions(i,j*2-1) = sum(sorted_metropolitan > t_points) + 1;
            else
                positions(i,j*2-1) = sum(sorted_atlantic > t_points) + 1;
            end
            
            positions(i,j*2) = sum(sorted_eastern > t_points) + 1;
        else
            % calculate position in division
            if (find(j == central_rng)) % team in central division
                positions(i,j*2-1) = sum(sorted_central > t_points) + 1;
            else
                positions(i,j*2-1) = sum(sorted_pacific > t_points) + 1;
            end
            
            positions(i,j*2) = sum(sorted_western > t_points) + 1;
        end
    end
end

top3_ixs = find(positions(:,20*2 - 1) <= 3)


%%
team_colors = zeros(30,3);
team_colors(19,:) = [245, 125,  49] / 255; % NYI orange
team_colors(20,:) = [  1,  97, 171] / 255; % NYR blue
team_colors(29,:) = [224,  23,  59] / 255; % WSH red

hold on
for t = [10, 20, 29]
    top3_ixs = find(positions(:,t*2 - 1) <= 1);
    for i = find(diff(top3_ixs) == 1)
        ds = [dates(top3_ixs(i)), dates(top3_ixs(i+1))]
        ys = [points(top3_ixs(i),t+1), points(top3_ixs(i+1),t+1)]
        %plot(, ...
        %    '-', 'Color', team_colors(t,:))
    end
    % plot(dates(top3_ixs), points(top3_ixs,t+1), '-') 
end
% plot(dates(top3_ixs), points(top3_ixs,20+1),'o')
hold off


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
team_colors(19,:) = [245, 125,  49] / 255; % NYI orange
team_colors(20,:) = [  1,  97, 171] / 255; % NYR blue
team_colors(29,:) = [224,  23,  59] / 255; % WSH red

% get end date
d = datetime(end_date(1),end_date(2),end_date(3));

teams_to_plot = [10, 20, 29];

clf
hold on
plot([d d], [0, 140], '-', 'Color', [0 0 0], 'DisplayName', 'Simulation Begins');

for t = teams_to_plot
    plot(dates, a_points(:,t + 1), '-', 'Color', team_colors(t,:), 'DisplayName', strcat(teams(t*3-2:t*3), ' Actual'));
    plot(dates, points(:,t + 1), '--', 'Color', team_colors(t,:),  'DisplayName', strcat(teams(t*3-2:t*3), ' Projected'));
end

axis([datenum(2015,10,1) datenum(2016,4,10) 0 125])
title(strcat('Actual Performance vs. Projected (Simulation Starting  ',datestr(d), ')'))
legend('Location','northwest')
hold off

 