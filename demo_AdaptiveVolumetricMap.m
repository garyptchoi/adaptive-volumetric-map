%% Adaptive Volumetric Parameterization of Simply Connected 3-Manifolds

meshFile = 'Skull.mat';                    % or 'Indented_Sphere.mat' or 'Multi-lobed_Ball.mat'
here = fileparts(mfilename('fullpath'));
mesh = load(fullfile(here,meshFile),'v','t');
v = double(mesh.v);
t = mesh.t;

%% Model settings
method        = 'fix';                     % 'fix', 'adaptive', or 'free'
radii         = [0.8, 1, 1];               % prescribed for fix, starting axes for adaptive/free
population    = [ ];                       % [] uses source volumes, or supply one mass per tet
shapeWeight   = 0.1;                       % shape weight relative to a mass weight of 1
maxIterations = 100;                       % upper limit on main solver steps

% Adaptive ellipsoid setting
interval = 5;                              % main steps between attempts to update the semiaxes

% Free-boundary settings
numLayers           = 3;                   % number of auxiliary layers
layerThicknessRatio = 2;                   % per layer, in mean edge lengths on the normalized boundary

%% Run the solver
[map, info] = AdaptiveVolumetricMap(v, t, ...
    'Method',             method, ...
    'Radii',              radii, ...
    'Population',         population, ...
    'ShapeWeight',        shapeWeight, ...
    'MaxIterations',      maxIterations, ...
    'Interval',           interval, ...
    'NumLayers',          numLayers, ...
    'LayerThicknessRatio', layerThicknessRatio);

%% Visualize the result

% Boundary shape
[~, modelName] = fileparts(meshFile);
faces = freeBoundary(triangulation(t,v));

figure('Color','w','Name',[modelName ' / ' info.method],'NumberTitle','off');
subplot(1,2,1);
trisurf(faces,v(:,1),v(:,2),v(:,3),'FaceColor',[.70 .80 .91],'EdgeColor','none');
axis equal off; view(3); camlight; lighting gouraud; title('Original mesh');
subplot(1,2,2);
trisurf(faces,map(:,1),map(:,2),map(:,3),'FaceColor',[.91 .65 .47],'EdgeColor','none');
axis equal off; view(3); camlight; lighting gouraud; title('Final map');

% Interior shape
plotInteriorComparison(t, v, map);
