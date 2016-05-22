function [points] = generate_points_matrix(dates, games)
% arguments:
% - dates: array containing distinct days games are played on
% - games: matrix of game data (taken from CSV file)
%
% returns:
% - points: matrix containing points earned throughout season for each team

    points = [dates zeros(size(dates,1),30)];
    for i = games(:,1)'
        date_i  = find(dates == datenum(games(i,2),games(i,3),games(i,4)));
        teamA_i = games(i,5);
        teamB_i = games(i,8);

        if (sum(points(date_i,2:end)) == 0 && date_i > 1)
            points(date_i,2:end) = points(date_i - 1,2:end);
        end

        if (games(i,7) == 1) % if teamA won
            points(date_i, teamA_i + 1) = points(date_i, teamA_i + 1) + 2;
            points(date_i, teamB_i + 1) = points(date_i, teamB_i + 1) + games(i,11);
        else                 % if teamB won
            points(date_i, teamA_i + 1) = points(date_i, teamA_i + 1) + games(i,11);
            points(date_i, teamB_i + 1) = points(date_i, teamB_i + 1) + 2;
        end
    end
end

