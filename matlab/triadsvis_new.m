close all; clear all;

% PARAMETERS
f_start = 200; % starting frequency (arbitrary)
f_end = 2*f_start;
res = 50;
range = 12;
partials = 2;

%coord = zeros(res,res,res,1);
%coord(1,:,1) = linspace(0,8,300);
%coord(1,1,:) = linspace(0,8,300);

tension = zeros(res,res,1);
valence = zeros(res,res,1);

% coordinates in absolute frequencies 
coord = zeros(res,2*partials);
for p = 1:partials
    coord(:,2*p) = linspace(p*f_start,p*f_end,res);
    coord(:,2*p-1) = coord(:,2*p);
end

% coordinates in semitones from f0 (12TET)
semicoord = zeros(res,2);
for i = 1:res
    semicoord(i,1) = freq2semi(f_start,coord(i,1),2);
end
semicoord(:,2) = semicoord(:,1);


%i is low, j is high?
a = .60;
e = 1.558;
diff = zeros(partials.^2,1);

for i = 1:res
    for j = 1:res
        for h1 = 1:3*partials-2
            for h2 = h1:3*partials-2
                diff = freq2semi(coord(i,h1),coord(j,h2),2);
                tension(i,j) = tension(i,j) + cooktension(diff,a);
                valence(i,j) = valence(i,j) + cookvalence(diff,e);
            end
        end
    end
end

% create ryb colormap
ryb = zeros(res,3); % [R G B]
ryb(1:res/2,1) = linspace(0,1,res/2);
ryb(res/2+1:res,1) = ones(res/2,1);
ryb(1:res/2,2) = linspace(0,1,res/2);
ryb(res/2+1:res,2) = linspace(1,0,res/2);
ryb(1:res/2,3) = linspace(1,0,res/2);


% show figures
axis = zeros(1,2); % (for synchronizing views when using rotate3d)

fig = figure;
fig.Name = 'Tension';
sur = surf(semicoord(:,1), semicoord(:,2), tension);
sur.LineStyle = 'none';
sur.FaceAlpha = 0.5;
colormap(ryb); colorbar;
xlabel('Upper Interval (semitones)');
ylabel('Lower Interval (semitones)');
axis(1) = gca;
rotate3d on;

fig = figure;
fig.Name = 'Valence';
sur = surf(coord(:,1), coord(:,2), valence);
sur.LineStyle = 'none';
sur.FaceAlpha = 0.5;
colormap(ryb); colorbar;
xlabel('Upper Interval (semitones)');
ylabel('Lower Interval (semitones)');
axis(2) = gca;
rotate3d on;

hlink = linkprop(axis,{'CameraPosition','CameraUpVector'});

%image('XData',data(:,1),'YData',data(:,2));
%contourslice(coord(:,1), coord(:,2), coordz, 1, [], []);
