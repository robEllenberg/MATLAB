function h = show_model(model,varargin)
% SHOW_MODEL Make a 3D patch plot of a triangle-based model.
%
% Plot a 3D model.
%
% This is used to plot a 3D surface mesh model read from a .stl file (a
% stereolithography file format defining a 2D surface as a set of
% triangles). This is essentially just a function for simplifying the
% process of plotting a 3D mesh, so that it can be plotted with syntax
% similar to a typical plot.
%
% Usage:
%     h = show_model(model,varargin);
%
% Example:
%     [bone.v, bone.f, bone.n, bone.c, bone.stltitle] = stlread('33091_bone_outer_002.stl'); %load the meshes
%     [skin.v, skin.f, skin.n, skin.c, skin.stltitle] = stlread('33091_WholeArm_002.stl');
% 
%     [bone.v, bone.f]=patchslim(bone.v, bone.f); % shrink the meshes a bit
%     [skin.v, skin.f]=patchslim(skin.v, skin.f);
% 
%     bone.c = repmat(hex2dec('D3')/255,[size(bone.v,1),3]); % Color the meshes... I'm using RGB hex colors (HTML tables are easy to find)
%     skin.c = repmat(hex2dec(['F4';'A4';'60'])'/255,[size(skin.v,1),1]);
% 
%     show_model(skin,'FaceColor',skin.c(1,:),'LineStyle','none','FaceAlpha',0.3); % this is a command I created to plot 3D meshes with less typing.
%     hold on;
%     show_model(bone,'LineStyle','none','FaceColor',repmat(hex2dec('D3')/255,[1,3]))
%     axis equal
%
% See also stlread, patchslim, patch, show_model
%
% Written by Francis Esmonde-White, 2010

if nargin > 1
    h = patch('Faces',model.f,'Vertices',model.v,'FaceVertexCData',model.c,varargin{:});
else
    h = patch('Faces',model.f,'Vertices',model.v,'FaceVertexCData',model.c);
end

end