close all; clear all;

% SPECTRA PARAMETERS
begin = 261.626; % (starting pitch)
partials = 2; % (number of harmonics to create)
rolloff = 0; % (negative db/octave)
temperament = 2; % (1 = JUST; 2 = EQUAL)
interval1 = 4; % (interval 1-2 in semictones)
interval2 = 3; % (interval 2-3 in semitones)

array_consis = [1 3; 1 4; 1 7; 4 7; 3 1; 4 1; 7 1; 7 4];
array_inconsis = [2 4; 2 6; 4 6; 4 2; 6 2; 6 4];
loop = 1;

% PLAYBACK PARAMETERS
playenable = 1; % playback enable
Fs = 44100; % sampling frequency (MATLAB default 8192)
time = 0.75; % time in seconds of each sound
cycles = 6; % num. cycles to show of lower frequency

% create coefficients for 12 tone chroma: JUST and EQUAL temperament
temp = zeros(2,12);
temp(1,:) = [16/15 9/8 6/5 5/4 4/3 7/5 3/2 8/5 5/3 9/5 15/8 2];
for i = 1:12
    temp(2,i) = 2^(i/12);
end

% initialize arrays
rand1 = zeros(1,2);
rand1_indx = randperm(numel(array_consis(:,1)),2); % randomly get two indices of array_consis
rand2_indx = randperm(numel(array_inconsis(:,1)),1); % randomly get one index of array_inconsis
array_mix = vertcat(array_consis(rand1_indx(1),:), array_consis(rand1_indx(2),:), array_inconsis(rand2_indx,:));

% initialize
tone1f = zeros(1,partials); tone1a = zeros(1,partials);
tone2f = zeros(1,partials); tone2a = zeros(1,partials);
tone3f = zeros(1,partials); tone3a = zeros(1,partials);
soundall = zeros(time*Fs,3);
array_mix_shuffle = array_mix(randperm(numel(array_mix(:,1))),:);

for a = 1:numel(array_mix_shuffle(:,1))
    % set fundamentals
    tone1f(1) = begin;
    tone2f(1) = begin*temp(temperament,array_mix_shuffle(a, 1));
    tone3f(1) = tone2f(1)*temp(temperament,array_mix_shuffle(a, 2));
    
    % calculate harmonics, amplitudes
    for i = 1:partials
        tone1f(i) = i*tone1f(1);
        tone2f(i) = i*tone2f(1);
        tone3f(i) = i*tone3f(1);
        tone1a(i) = 10^((-rolloff*log2(tone1f(i)/tone1f(1)))/20);
        tone2a(i) = 10^((-rolloff*log2(tone2f(i)/tone2f(1)))/20);
        tone3a(i) = 10^((-rolloff*log2(tone3f(i)/tone3f(1)))/20);
    end
    
    % generate sound files
    sound1 = zeros(time*Fs,1);
    sound2 = zeros(time*Fs,1);
    sound3 = zeros(time*Fs,1);
    for i = 1:1:partials
        for j = 1:1:time*Fs
            sound1(j) = sound1(j) + tone1a(i)*sin(2*pi*tone1f(i)*j/Fs);
            sound2(j) = sound2(j) + tone1a(i)*sin(2*pi*tone2f(i)*j/Fs);
            sound3(j) = sound3(j) + tone1a(i)*sin(2*pi*tone3f(i)*j/Fs);
        end
    end
    soundall(:,a) = sound1 + sound2 + sound3;
end

% PLAY SOUND FILES (not a very elegant implementation)
pause on;
dumb = 1;
while dumb == 1
    pause;
    for a = 1:numel(soundall(1,:))
        soundsc(soundall(:,a),Fs); pause(time);
        pause(time);
    end
    if loop == 0
        dumb = 0;
    end
end
pause off;
