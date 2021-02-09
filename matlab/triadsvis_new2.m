close all; clear all;
% PARAMETERS
f_start = 100; % starting frequency (arbitrary)
f_end = 2*f_start;
steps = 100;
range = 12;
partials = 2;

a = 0.60; e = 1.558;

% create coordinate grid by starting frequency (arbitrary)
coord_freq = zeros(steps,2);
coord_freq(:,1) = linspace(f_start,f_end,steps);
coord_freq(:,2) = coord_freq(:,1);

coord_absfreq = zeros(steps,steps,2);

for i = 1:steps
    for j = 1:steps
        coord_absfreq(i,j,1) = coord_freq(i,1); %middle note
        coord_absfreq(i,j,2) = coord_absfreq(1,j,1) + coord_freq(j,1); %top note
    end
end


% create coordinate grid by semitone distance (12TET)
coord_semi = zeros(steps,2);
for i = 1:steps
    coord_semi(i,1) = freq2semi(f_start, coord_freq(i,1), 2);
end
coord_semi(:,2) = coord_semi(:,1);

tensions = zeros(steps,steps);
valences = zeros(steps,steps);
triad_freq = zeros(3*partials,2); % columns: [freq ampl]

for i = 1:steps
    for j = 1:steps
        for k = 1:partials
            m = 3*(k-1);
            triad_freq(m+1,1) = 0;
            triad_freq(m+2,1) = (k-1)*12 + (coord_semi(i,1));
            triad_freq(m+3,1) = (k-1)*12 + (coord_semi(j,2));
            triad_freq(m+1,2) = 0.9.^(k-1); % CHANGE LATER
            triad_freq(m+2,2) = 0.9.^(k-1);
            triad_freq(m+3,2) = 0.9.^(k-1);
            sort = sortrows(triad_freq);
            for n = 1:numel(sort(:,1))-2 % between all components, calculate ten/val's
                lo = sort(n,1) - sort(n+1,1);
                hi = sort(n+1,1) - sort(n+2,1);
                tensions(i,j) = tensions(i,j) + cooktension(lo-hi,a);
                valences(i,j) = valences(i,j) + cookvalence(lo-hi,e);
            end
        end
    end
end

% create ryb colormap
ryb = zeros(steps,3); % [R G B]
ryb(1:steps/2,1) = linspace(0,1,steps/2);
ryb(steps/2+1:steps,1) = ones(steps/2,1);
ryb(1:steps/2,2) = linspace(0,1,steps/2);
ryb(steps/2+1:steps,2) = linspace(1,0,steps/2);
ryb(1:steps/2,3) = linspace(1,0,steps/2);


% show figures
axis = zeros(1,2); % (for synchronizing views when using rotate3d)

fig = figure;
fig.Name = 'Tension';
sur = surf(coord_semi(:,1), coord_semi(:,2), tensions);
sur.LineStyle = 'none';
sur.FaceAlpha = 0.5;
colormap(ryb); colorbar;
xlabel('Upper Interval (semitones)');
ylabel('Lower Interval (semitones)');
axis(1) = gca;
rotate3d on;


fig = figure;
fig.Name = 'Valence';
sur = surf(coord_semi(:,1), coord_semi(:,2), valences);
sur.LineStyle = 'none';
sur.FaceAlpha = 0.5;
colormap(ryb); colorbar;
xlabel('Upper Interval (semitones)');
ylabel('Lower Interval (semitones)');
axis(2) = gca;
rotate3d on;


hlink = linkprop(axis,{'CameraPosition','CameraUpVector'});
