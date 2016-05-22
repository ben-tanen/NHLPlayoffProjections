function M = calculate_team_pcts(team, ix, end_date)
    % input:
    %   team: 3-letter team code (ex: NYR)
    %   end_date: when to stop looking at data
    % output:
    %   M: array containing outcome percentages for varying situations
    %      (see below for guide)
    
    % Formatting of M:
    % columns (in order): 
    %   [Reg-L %, Reg-W %, Go-to-OT %, OT-L %, OT-W %, SO, SO-L %, SO-W %]
    % row (in order):
    %   [last 10 games, L20, L30, L50, season]
    
    n = 8; % number of percentages per projection
    m = 5; % number of projections
    M = zeros(m,n);
    
    games_file = strjoin({team, '_games_201516.csv'}, '');
    games = csvread(games_file, 2, 0);
    
    played = games(:,2) < end_date(1) | ... % year is less
             games(:,2) == end_date(1) ...
             & games(:,3) < end_date(2) | ... % month is less
             games(:,2) == end_date(1) & games(:,3) == end_date(2) ...
             & games(:,4) <= end_date(3); % day is less (or equal)
   
    games = games(find(played),:);
    num_games = size(games,1);
    
    games_to_analyze = [10, 20, 30, 50, Inf];
    for i = 1:m
        l   = min(games_to_analyze(i), num_games);
        rng = (num_games - (l - 1)):num_games;
        
        n_OT = sum(games(rng,5) == 2 | games(rng,5) == 3);
        n_SO = sum(games(rng,5) == 4 | games(rng,5) == 5);
        M(i,1) = sum(games(rng,5) == 0) / l;             % pct of reg loses
        M(i,2) = sum(games(rng,5) == 1) / l;             % pct of reg wins
        M(i,3) = (n_OT + n_SO) / l;                      % pct of reg games to OT
        M(i,4) = sum(games(rng,5) == 2) / (n_OT + n_SO); % pct of OT loses
        M(i,5) = sum(games(rng,5) == 3) / (n_OT + n_SO); % pct of OT wins
        M(i,6) = (n_SO) / (n_OT + n_SO);                 % pct of OT games to SO
        M(i,7) = sum(games(rng,5) == 4) / n_SO;          % pct of SO loses
        M(i,8) = sum(games(rng,5) == 5) / n_SO;          % pct of SO wins 
    end;
end