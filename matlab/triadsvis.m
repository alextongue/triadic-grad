close all; clear all;

% PARAMETERS
res = 150;
range = 12;
partials = 2;
f0 = 100; % starting frequency (arbitrary)

%coord = zeros(res,res,res,1);
%coord(1,:,1) = linspace(0,8,300);
%coord(1,1,:) = linspace(0,8,300);

tension = zeros(res,res,1);
valence = zeros(res,res,1);
coord = zeros(res,2);
coord(:,1) = linspace(0,range,res);
coord(:,2) = coord(:,1);

%i is low, j is high?
a = .60;
e = 1.558;
diff = zeros(partial.^2,1);
for i = partial.^2
    diff(i) = % one component minus the next.
end

for i = 1:res
    for j = 1:res
        diff = coord(i,1) - coord(j,2);
        tension(i,j) = exp(-((diff)/a).^2);
        valence(i,j) = (2*diff/e)*exp((-(diff.^4)/4));
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
sur = surf(coord(:,1), coord(:,2), tension);
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
