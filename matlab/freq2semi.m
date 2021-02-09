function out = freq2semi(f0,f1,temperament)
    if temperament == 1
        out = 0;
    end
    if temperament == 2
        out = 12*log2(f1/f0);
    end
end