function c = get_team_code(legend, index)
    str = char(legend(index));
    c   = str(end-2:end);
end