function fig = plotInteriorComparison(t, v, map)
%PLOTINTERIORCOMPARISON Compare a cut through the original mesh and its result.
%   fig = plotInteriorComparison(t,v,map) takes M-by-4 tetrahedra, original
%   vertex positions v and mapped positions map in the same vertex order.
%   Each mesh is framed in its own coordinates. Rotation and zoom are linked.

% Select whole tetrahedra in the final map, then use the same faces in both views.
x = map(:,1);
centerX = mean(reshape(x(t(:)),size(t)),2);
keep = centerX >= median(x);
allOuter = freeBoundary(triangulation(t,map));

% The boundary of the retained mesh includes its exposed interior triangles.
retained = t(keep,:);
solidFaces = zeros(0,3);
if ~isempty(retained)
    [vertexIds,~,localIds] = unique(retained(:));
    localMesh = triangulation(reshape(localIds,size(retained)),map(vertexIds,:));
    solidFaces = vertexIds(freeBoundary(localMesh));
end
% Only the removed side's exterior contributes to the translucent shell.
onSolid = ismember(sort(allOuter,2),sort(solidFaces,2),'rows');
shellFaces = allOuter(~onSolid,:);

fig = figure('Color','w','Name','Interior comparison','NumberTitle','off', ...
    'Position',[120 120 820 440],'Renderer','opengl');
layout = tiledlayout(fig,1,2,'TileSpacing','compact','Padding','compact');
vertices = {v,map};
panelTitles = {'Original mesh','Final map'};
pink = [255 208 208]/255;
ax = gobjects(1,2);
for n = 1:2
    ax(n) = nexttile(layout);
    xyz = vertices{n};
    low = min(xyz,[],1);
    high = max(xyz,[],1);
    center = (low+high)/2;
    halfWidth = 0.535 * max(high-low);
    limits = [center-halfWidth; center+halfWidth];
    hold(ax(n),'on');
    if ~isempty(shellFaces)
        patch(ax(n),'Faces',shellFaces,'Vertices',xyz, ...
            'FaceColor',pink,'FaceAlpha',0.12,'EdgeColor','none', ...
            'FaceLighting','none','Tag','removed shell');
    end
    if ~isempty(solidFaces)
        patch(ax(n),'Faces',solidFaces,'Vertices',xyz, ...
            'FaceColor',pink,'FaceAlpha',1,'EdgeColor',[0.20 0.16 0.17], ...
            'EdgeAlpha',0.46,'LineWidth',0.42,'FaceLighting','flat', ...
            'AmbientStrength',0.60,'DiffuseStrength',0.53,'SpecularStrength',0, ...
            'Tag','retained mesh');
    end
    axis(ax(n),'equal');
    set(ax(n),'XLim',limits(:,1).','YLim',limits(:,2).','ZLim',limits(:,3).', ...
        'Projection','orthographic','Visible','off');
    view(ax(n),[-0.62 -1 0.38]);
    camlight(ax(n),'headlight');
    title(ax(n),panelTitles{n},'Visible','on','FontWeight','normal','FontSize',14, ...
        'Color',[0.15 0.15 0.16]);
end
camera = linkprop(ax,{'View','CameraViewAngle'});
setappdata(fig,'InteriorCameraLink',camera);
end
