function R = determine_game_results(teamA_pcts, teamB_pcts)
    % input:
    %   team: 3-letter team code (ex: NYR)
    % output:
    %   R: array containing points from outcomes for varying projections
    %      (see below for guide)
    
    % Formatting of R:
    % columns (in order): 
    %   [Decided in Reg-OT-SO (0, 1, 2), Pts for A, Pts for B]
    % row, using projection (in order):
    %   [last 10 games, L20, L30, L50, season]
    
    m = size(teamA_pcts, 1); % number of projections
    R = zeros(m,3);
    
    for i = 1:m
        [max1, ix1] = max([teamA_pcts(i,1) + teamB_pcts(i,2),   % B wins in reg
                           teamA_pcts(i,2) + teamB_pcts(i,1),   % A wins in reg
                           teamA_pcts(i,3) + teamB_pcts(i,3)]); % Go to OT
        [max2, ix2] = max([teamA_pcts(i,4) + teamB_pcts(i,5),   % B wins in OT
                           teamA_pcts(i,5) + teamB_pcts(i,4),   % A wins in OT
                           teamA_pcts(i,6) + teamB_pcts(i,6)]); % Go to SO
        [max3, ix3] = max([teamA_pcts(i,7) + teamB_pcts(i,8),   % B wins in SO
                           teamA_pcts(i,8) + teamB_pcts(i,7)]); % A wins in SO
                       
        if (ix1 == 1) % B wins in reg
            R(i,:) = [0, 0, 2];
        elseif (ix1 == 2) % A wins in reg
            R(i,:) = [0, 2, 0];   
        elseif (ix1 == 3 && ix2 == 1) % B wins in OT
            R(i,:) = [1, 1, 2];
        elseif (ix1 == 3 && ix2 == 2) % A wins in OT
            R(i,:) = [1, 2, 1];
        elseif (ix1 == 3 && ix2 == 3 && ix3 == 1) % B wins in SO
            R(i,:) = [2, 1, 2];
        elseif (ix1 == 3 && ix2 == 3 && ix3 == 2) % A wins in SO
            R(i,:) = [2, 2, 1]; 
        end
    end
end