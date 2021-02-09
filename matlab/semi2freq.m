function out = semi2freq(f0,semis,temperament)
    if temperament == 1
        out = 0;
    end
    if temperament == 2
        out = f0*2.^(semis/12);
    end
end