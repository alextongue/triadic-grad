function out = cooktension(diff,a)
    out = exp(-((diff)/a).^2);
end