function out = cookvalence(diff,e)
    out = (2*diff/e)*exp((-(diff.^4)/4));
end