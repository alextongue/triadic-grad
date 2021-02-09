close all; clear all;

%% SPECTRA PARAMETERS
begin = 400; % (starting pitch)
partials = 10; % (number of harmonics to create)
rolloff = 9; % (negative db/octave)
temperament = 1; % (1 = JUST; 2 = EQUAL)
interval1 = 4; % (interval 1-2 in semitones)
interval2 = 3; % (interval 2-3 in semitones)
scale = 1; % (1 = LOG; 2 = LINEAR)

%% PLAYBACK PARAMETERS
playenable = 1; % playback enable
Fs = 44100; % sampling frequency (MATLAB default 8192)
time = 0.75; % time in seconds of each sound
cycles = 6; % num. cycles to show of lower frequency

%% create coefficients for 12 tone chroma: JUST and EQUAL temperament
temp = zeros(2,12);
temp(1,:) = [16/15 9/8 6/5 5/4 4/3 7/5 3/2 8/5 5/3 9/5 15/8 2];
for i = 1:12
    temp(2,i) = 2^(i/12);
end

% generate spectra
tone1f = zeros(1,partials); tone1a = zeros(1,partials);
tone2f = zeros(1,partials); tone2a = zeros(1,partials);
tone3f = zeros(1,partials); tone3a = zeros(1,partials);

% calculate fundamentals
tone1f(1) = begin;
tone2f(1) = begin*temp(temperament,interval1);
tone3f(1) = tone2f(1)*temp(temperament,interval2);

% calculate harmonics, amplitudes
for i = 1:partials
    tone1f(i) = i*tone1f(1);
    tone2f(i) = i*tone2f(1);
    tone3f(i) = i*tone3f(1);
    tone1a(i) = 10^((-rolloff*log2(tone1f(i)/tone1f(1)))/20);
    tone2a(i) = 10^((-rolloff*log2(tone2f(i)/tone2f(1)))/20);
    tone3a(i) = 10^((-rolloff*log2(tone3f(i)/tone3f(1)))/20);
end

%% plot spectra
fig = figure;
fig.Name = 'Spectra';
axis1 = zeros(4,1);

subplot(4,1,1);
prop = stem(tone1f, tone1a);
prop.Color = [0 .447 .741];
prop.Marker = '.'; prop.MarkerSize = 10;
title(['Tone 1: f_0= ',num2str(tone1f(1)),' Hz']);
ax = gca;
axis1(1) = ax; % save edited axis handle to use when linking subsequent handles

subplot(4,1,2);
prop = stem(tone2f, tone2a);
prop.Color = [.8 .5 .3];
prop.Marker = '.'; prop.MarkerSize = 10;
title(['Tone 2: f_0= ',num2str(tone2f(1)),' Hz']);
axis1(2) = gca;

subplot(4,1,3);
prop = stem(tone3f, tone3a);
prop.Color = [.8 .3 .5];
prop.Marker = '.'; prop.MarkerSize = 10;
title(['Tone 3: f_0= ',num2str(tone3f(1)),' Hz']);
axis1(3) = gca;

subplot(4,1,4); hold on;
title('Tone 1 + Tone 2');
prop = stem(tone1f, tone1a, '.');
prop.Color = [0 .447 .741]; prop.Marker = '.'; prop.MarkerSize = 10;
prop = stem(tone2f, tone1a, '.');
prop.Color = [.8 .5 .3]; prop.Marker = '.'; prop.MarkerSize = 10;
prop = stem(tone3f, tone3a, '.');
prop.Color = [.8 .3 .5]; prop.Marker = '.'; prop.MarkerSize = 10;
axis1(4) = gca;

% axis properties
hlink = linkprop(axis1,{'Xscale','XLimMode','XLim','XGrid','YLim'});
if scale == 1
    ax.XScale = 'log';
    ax.XLimMode = 'manual';
    ax.XLim = [10^floor(log10(tone1f(1))), 10^ceil(log10(tone3f(partials)))];
end
if scale == 2
    ax.XScale = 'linear';
    ax.XLimMode = 'manual';
    ax.XLim = [floor(tone1f(1)/100)*100, ceil(tone3f(partials)/100)*100];
end 
ax.YLim = [0, 1.25];
ax.XGrid = 'on';

%% generate sound files
sound1 = zeros(time*Fs,1);
sound2 = zeros(time*Fs,1);
sound3 = zeros(time*Fs,1);
soundint = zeros(time*Fs,1);
for i = 1:1:partials
    for j = 1:1:time*Fs
        sound1(j) = sound1(j) + tone1a(i)*sin(2*pi*tone1f(i)*j/Fs);
        sound2(j) = sound2(j) + tone1a(i)*sin(2*pi*tone2f(i)*j/Fs);
        sound3(j) = sound3(j) + tone1a(i)*sin(2*pi*tone3f(i)*j/Fs);
    end
end
soundall = sound1 + sound2 + sound3;
samples = floor(cycles/tone1f(1)*Fs);

%% plot sound files
fig = figure;
fig.Name = 'Sounds';
axis2 = zeros(4,1);

subplot(4,1,1);
prop = plot(sound1(1:floor(samples)));
prop.Color = [0 .447 .741]; prop.LineWidth = 1;
title(['Tone 1: f_0= ',num2str(tone1f(1)),' Hz']);
ax = gca;
axis2(1) = ax;

subplot(4,1,2);
prop = plot(sound2(1:samples));
prop.Color = [.8 .5 .3]; prop.LineWidth = 1;
title(['Tone 2: f_0= ',num2str(tone2f(1)),' Hz']);
axis2(2) = gca;

subplot(4,1,3);
prop = plot(sound2(1:samples));
prop.Color = [.8 .3 .5]; prop.LineWidth = 1;
title(['Tone 3: f_0= ',num2str(tone3f(1)),' Hz']);
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