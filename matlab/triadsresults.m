close all; clear all;

total = [27 23 4];
correct = [11 8 3];
percentages = ceil((correct./total)*100);

labels = categorical({'Total', 'Musical', 'Not Musical'});

figure;
bar(labels{:,1}, percentages);