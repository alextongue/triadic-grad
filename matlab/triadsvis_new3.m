close all; clear all; clc;

%% PARAMETERS
f_start = 100; % starting frequency (arbitrary)
steps = 80;
range = 8; % semitones
partials = 2;
dots_enable = 0;
dots = [4 3; 3 4; 3 3; 4 4; 3 5]; % [lo_interval hi_interval]
dots_lbl = {'maj'; 'min'; 'dim'; 'aug'; 'maj1 (?)'};
% for good showing: Az -32; El 14

%% create coordinate grid by starting frequency (arbitrary)
f_end = semi2freq(f_start, range, 2);
coord_freq = zeros(steps,2); % technically can be zeros(steps,1)
coord_freq(:,1) = linspace(f_start, f_end, steps);
coord_freq(:,2) = coord_freq(:,1); % technically not needed

%% create coordinate grid by semitone distance (12TET)
coord_semi = zeros(steps,2);
for i = 1:steps
    coord_semi(i,1) = freq2semi(f_start, coord_freq(i,1), 2);
end
coord_semi(:,2) = coord_semi(:,1);

%% create grid of absolute frequencies, by semitones
coord_absfreq = zeros(steps,steps,2);
for i = 1:steps
    for j = 1:steps
        coord_absfreq(i,j,1) = semi2freq(f_start, coord_semi(i,1), 2); % page 1 = middle note
        coord_absfreq(i,j,2) = semi2freq(coord_absfreq(i,j,1), coord_semi(j,1), 2); %top note
    end
end

%% TENSION/VALENCE CALCULATION
tensions = zeros(steps,steps);
valences = zeros(steps,steps);
comp_f = zeros(3*partials,2); % frequency components of all harmonics [freq ampl]
a = 0.60; e = 1.558;
for i = 1:steps
    for j = 1:steps
        
        for k = 1:partials
            m = 3*(k-1);
            comp_f(m+1,1) = k*f_start;
            comp_f(m+2,1) = k*coord_absfreq(i,j,1);
            comp_f(m+3,1) = k*coord_absfreq(i,j,2);
            comp_f(m+1,2) = 1.5.^(k-1); % rudimentary decay
            comp_f(m+2,2) = 1.5.^(k-1);
            comp_f(m+3,2) = 1.5.^(k-1);
        end
        comp_fsort = sortrows(comp_f);
        for n = 1:numel(comp_fsort(:,1))-2
            for p = numel(comp_fsort(:,1)):-1:n+2
                for q = n+1:p-1
                    lo = freq2semi(comp_fsort(n,1), comp_fsort(q,1), 2);
                    hi = freq2semi(comp_fsort(q,1), comp_fsort(p,1), 2);
                    diff = lo-hi;
                tensions(i,j) = tensions(i,j) + cooktension(diff,a);
                valences(i,j) = valences(i,j) + cookvalence(diff,e);
                end
            end
        end
        
    end
end

%% NORMALIZE
tensions_n = mat2gray(tensions);
valences_n = mat2gray(valences);

%% calculate nearest indexes for dots
dots_tension = zeros(numel(dots(:,1)),1);
dots_valence = dots_tension;
for i = 1:numel(dots(:,1))
    dots_tension(i) = cooktension(dots(i,1) - dots(i,2),a);
    dots_valence(i) = cookvalence(dots(i,1) - dots(i,2),e);
end
dots_tension_n = mat2gray(dots_tension);
dots_valence_n = mat2gray(dots_valence);

% [R G B] colormap: blue to yellow to red
ryb = zeros(steps,3);
ryb(1:steps/2,1) = linspace(0,1,steps/2);
ryb(steps/2+1:steps,1) = ones(steps/2,1);
ryb(1:steps/2,2) = linspace(0,1,steps/2);
ryb(steps/2+1:steps,2) = linspace(1,0,steps/2);
ryb(1:steps/2,3) = linspace(1,0,steps/2);

% [R G B] colormap: purple to sea foam (this one looks nice)
grn = zeros(steps,3);
grn(1:steps/2,1) = linspace(0.5,0.4,steps/2);
grn(steps/2+1:steps,1) = linspace(0.4,0.4,steps/2);
grn(1:steps,2) = linspace(0.2,1.0,steps);
grn(1:steps/2,3) = linspace(0.5,0.6,steps/2);
grn(steps/2+1:steps,3) = linspace(0.6,0.6,steps/2);

% [R G B] colormap: goldenrod to gold
gld = zeros(steps,3);
gld(1:steps,1) = linspace(0.60, 1, steps);

gld(1:steps,2) = linspace(0.40, 1, steps);

%% show figures
axis = zeros(1,2); % (for synchronizing views when using rotate3d)

fig = figure;
fig.Name = 'Tension';
sur = surf(coord_semi(:,1), coord_semi(:,2), tensions_n); hold on;
sur.LineStyle = 'none'; sur.FaceAlpha = 0.90;
colormap(gld); colorbar;
if dots_enable == 1
    ste = stem3(dots(:,2), dots(:,1), dots_tension_n + 0.1);
    ste.LineWidth = 1.0;
    ste.Marker = '.';
    ste.MarkerSize = 20;
    ste.Color = 'k';
    text(dots(:,2) + 0.5, dots(:,1), dots_tension_n + 0.2, dots_lbl, 'HorizontalAlignment', 'center');
end
xlabel('Upper Interval (semitones)'); ylabel('Lower Interval (semitones)');
zlabel('Tension');
axis(1) = gca;
ax = gca;
ax.GridAlpha = 1.00;
rotate3d on;

fig = figure;
fig.Name = 'Valence';
sur = surf(coord_semi(:,1), coord_semi(:,2), valences_n); hold on;
sur.LineStyle = 'none'; sur.FaceAlpha = 0.90;
colormap(ryb); colorbar;
if dots_enable == 1
    ste = stem3(dots(:,2), dots(:,1), dots_valence_n + 0.1);
    ste.LineWidth = 1.0                             
    ste.Marker = '.'; 
    ste.MarkerSize = 20;
    ste.Color = 'k';
    text(dots(:,2) + 0.5, dots(:,1), dots_valence_n + 0.2, dots_lbl, 'HorizontalAlignment', 'center');
end
xlabel('Upper Interval (semitones)'); ylabel('Lower Interval (semitones)');
zlabel('Valence');
axis(2) = gca;
rotate3d on;

hlink = linkprop(axis,{'CameraPosition','CameraUpVector','GridAlpha'});
