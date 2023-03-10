close all; clearvars; clc;

%% SPECTRA PARAMETERS
f0          = 400; % (starting pitch)
partials    = 10; % (number of harmonics to create, excl. f0)
rolloff     = 9; % (rolloff db/octave)
intervals   = [4,3]; % (chord intervals 1-2, 2-3 in semitones)
temperament = 1; % (1 = JUST; 2 = EQUAL)
fscale      = 1; % (1 = LOG; 2 = LINEAR)

%% PLAYBACK PARAMETERS
playenable = 1; % playback enable
Fs = 48000; % sampling frequency (MATLAB default 8192)
time = 0.75; % time in seconds of each sound
cycles = 6; % num. cycles to show of lower frequency

%% Create interval coefficients for 12 tone chroma: JUST and EQUAL temperament
tempertable = zeros(2,12);
tempertable(1,:) = [16/15, 9/8, 6/5, 5/4, 4/3, 7/5, 3/2, 8/5, 5/3, 9/5, 15/8, 2];
for jj = 1:12
    tempertable(2,jj) = 2^(jj/12);
end
partials_all = partials+1;

% generate spectra
for ii = 1:numel(intervals)+1
    notes(ii).freq = zeros(1,partials_all);
    notes(ii).ampl = zeros(1,partials_all);

    % calculate fundamentals
    if ii==1
        notes(ii).freq(1) = f0;
    else
        notes(ii).freq(1) = ...
            notes(ii-1).freq(1) ...
            * tempertable(temperament,intervals(ii-1));
    end

    % calculate harmonics, amplitudes
    for jj = 1:partials_all
        notes(ii).freq(jj) = jj*notes(ii).freq(1);
        notes(ii).ampl(jj) = 10^( ...
            (-rolloff*log2(notes(ii).freq(jj)/notes(ii).freq(1))) ...
            /20);
    end
end
%% plot spectra
fig = figure;
fig.Name = 'Spectra';
axis1 = zeros(4,1);

subplot(4,1,1);
prop = stem(notes(1).freq, notes(1).ampl);
prop.Color = [0 .447 .741];
prop.Marker = '.'; prop.MarkerSize = 10;
title(['Tone 1: f_0= ',num2str(notes(1).freq(1)),' Hz']);
ax = gca;
axis1(1) = ax; % save edited axis handle to use when linking subsequent handles

subplot(4,1,2);
prop = stem(notes(2).freq, notes(2).ampl);
prop.Color = [.8 .5 .3];
prop.Marker = '.'; prop.MarkerSize = 10;
title(['Tone 2: f_0= ',num2str(notes(2).freq(1)),' Hz']);
axis1(2) = gca;

subplot(4,1,3);
prop = stem(notes(3).freq, notes(3).ampl);
prop.Color = [.8 .3 .5];
prop.Marker = '.'; prop.MarkerSize = 10;
title(['Tone 3: f_0= ',num2str(notes(3).freq(1)),' Hz']);
axis1(3) = gca;

subplot(4,1,4); hold on;
title('Tone 1 + Tone 2');
prop = stem(notes(1).freq, notes(1).ampl, '.');
prop.Color = [0 .447 .741]; prop.Marker = '.'; prop.MarkerSize = 10;
prop = stem(notes(2).freq, notes(2).ampl, '.');
prop.Color = [.8 .5 .3]; prop.Marker = '.'; prop.MarkerSize = 10;
prop = stem(notes(3).freq, notes(3).ampl, '.');
prop.Color = [.8 .3 .5]; prop.Marker = '.'; prop.MarkerSize = 10;
axis1(4) = gca;

% axis properties
hlink = linkprop(axis1,{'Xscale','XLimMode','XLim','XGrid','YLim'});
if fscale == 1
    ax.XScale = 'log';
    ax.XLimMode = 'manual';
    ax.XLim = [10^floor(log10(notes(1).freq(1))), 10^ceil(log10(notes(3).freq(partials_all)))];
end
if fscale == 2
    ax.XScale = 'linear';
    ax.XLimMode = 'manual';
    ax.XLim = [floor(notes(1).freq(1)/100)*100, ceil(notes(3).freq(partials_all)/100)*100];
end 
ax.YLim = [0, 1.25];
ax.XGrid = 'on';

%% generate sound files
sound1 = zeros(time*Fs,1);
sound2 = zeros(time*Fs,1);
sound3 = zeros(time*Fs,1);
soundint = zeros(time*Fs,1);
for jj = 1:1:partials_all
    for j = 1:1:time*Fs
        sound1(j) = sound1(j) + n1_ampl(jj)*sin(2*pi*n1_freq(jj)*j/Fs);
        sound2(j) = sound2(j) + n1_ampl(jj)*sin(2*pi*n2_freq(jj)*j/Fs);
        sound3(j) = sound3(j) + n1_ampl(jj)*sin(2*pi*n3_freq(jj)*j/Fs);
    end
end
soundall = sound1 + sound2 + sound3;
samples = floor(cycles/n1_freq(1)*Fs);

%% plot sound files
fig = figure;
fig.Name = 'Sounds';
axis2 = zeros(4,1);

subplot(4,1,1);
prop = plot(sound1(1:floor(samples)));
prop.Color = [0 .447 .741]; prop.LineWidth = 1;
title(['Tone 1: f_0= ',num2str(n1_freq(1)),' Hz']);
ax = gca;
axis2(1) = ax;

subplot(4,1,2);
prop = plot(sound2(1:samples));
prop.Color = [.8 .5 .3]; prop.LineWidth = 1;
title(['Tone 2: f_0= ',num2str(n2_freq(1)),' Hz']);
axis2(2) = gca;

subplot(4,1,3);
prop = plot(sound2(1:samples));
prop.Color = [.8 .3 .5]; prop.LineWidth = 1;
title(['Tone 3: f_0= ',num2str(n3_freq(1)),' Hz']);
axis2(3) = gca;

subplot(4,1,4);
prop = plot(soundall(1:samples));
prop.Color = [.300 .300 .300]; prop.LineWidth = 1;
title('Tone 1 + Tone 2');
axis2(4) = gca;

hlink = linkprop(axis2,{'XTick','XTickLabel'});
ax.XTick = linspace(0, time*Fs, time*5);
ax.XTickLabel = linspace(0, time*Fs, time*5);

% PLAY SOUND FILES
if playenable == 1
    pause on; pause;
    soundsc(sound1,Fs); pause(time); pause(time/4);
    soundsc(sound2,Fs); pause(time); pause(time/4);
    soundsc(sound3,Fs); pause(time); pause(time/4);
    soundsc(soundall,Fs); pause(time);
    pause off;
end