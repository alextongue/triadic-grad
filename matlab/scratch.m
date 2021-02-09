close all; clear all;
% PARAMETERS
f_start = 100; % starting frequency (arbitrary)
f_end = 2*f_start;
steps = 100;
range = 12;
partials = 1;

a = 0.60; e = 1.558;

% create coordinate grid by starting frequency (arbitrary)
coord_freq = zeros(steps,2);
coord_freq(:,1) = linspace(f_start,f_end,steps);
coord_freq(:,2) = coord_freq(:,1);

% create coordinate grid by semitone distance (12TET)
coord_semi = zeros(steps,2);
for i = 1:steps
    coord_semi(i,1) = freq2semi(f_start, coord_freq(i,1), 2);
end
coord_semi(:,2) = coord_semi(:,1);

tensions = zeros(steps,steps);
valences = zeros(steps,steps);
diff_freq = zeros(3*partials,2); % columns: [freq ampl]

for i = 1:steps
    for j = 1:steps
        for k = 1:partials
            m = 3*(k-1);
            diff_freq(m+1,1) = k*f_start;
            diff_freq(m+2,1) = k*coord_freq(i,1);
            diff_freq(m+3,1) = k*coord_freq(j,2);
            diff_freq(m+1,2) = 0.5.^(k-1); % CHANGE LATER
            diff_freq(m+2,2) = 0.5.^(k-1);
            diff_freq(m+3,2) = 0.5.^(k-1);
            sortrows(diff_freq);
            for n = 1:numel(diff_freq(:,1))-2 % between all components, calculate ten/val's
                difflo = freq2semi(diff_freq(n,1), diff_freq(n+1,1), 2);
                diffhi = freq2semi(diff_freq(n+1,1), diff_freq(n+2,1), 2);
                tensions(i,j) = tensions(i,j) + cooktension(difflo-diffhi,a);
                valences(i,j) = valences(i,j) + cookvalence(difflo-diffhi,e);
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

%{
% components = [freq ampl]
allcomponents = zeros(3*partials,2);

% coordinates in absolute frequencies 
coord = zeros(res,2*partials);
for p = 1:partials
    coord(:,2*p) = linspace(p*f_start,p*f_end,res);
    coord(:,2*p-1) = coord(:,2*p);
end

cell = zeros(3*partials,1);
for i = 1:res
    for j = 1:res
        cellfreq = coordfreq(i,1), coordfreq(i,2);
        cellsort = sort(cell);


tension = zeros(res,res,1);
valence = zeros(res,res,1);

%components = 3*partials;

calcs = 0;
for i = 1:3*partials-1
    calcs = blah+i;
end

% this is an array containing all of the differences between components
diffs = zeros(res,res,blah);


%}
