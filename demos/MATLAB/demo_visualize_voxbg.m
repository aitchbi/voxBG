clc
clear 
close all

which_graph = 1;
path_spm12  = []; 

%-Plot settings.
opts = struct;
opts.saveFigs         = false;
opts.plot_ref         = true;
opts.plot_atom        = true;
opts.plot_odf         = true;
opts.plot_graph       = true;
opts.plot_odf_subset  = false;
opts.whichODFroi      = 1; % 1 2
opts.largePlots       = false;
opts.odfsWithUnderlay = false;
opts.atom_colormap    = 'inferno'; %'inferno', 'hot', 'RdBu', 'fslRender3', 'pink', 'viridis', ...
opts.plotType         = 'imagesc'; %'imagesc', 'contour'
opts.plane            = 'axial';
opts.slice            = 70;
opts.bbwidth          = 21;
opts.tau              = 7;
opts.flipColormap     = false;
opts.GaussianFWHM     = []; % 4,6,.. or [] to skip
opts.MaskedGaussian   = 1; % also plot masked Gaussian?
opts.plotTissueMasks  = true; % GM, WM, or GM+WM for cerebrum graph
opts.plotForColorbar  = false; % plot extra atom graph just for colorbar?
opts.whichRefImage    = 'mask'; % 't1w','mask'
opts.whichUnderlay    = 'none'; % 't1w', 'none'
opts.Alpha            = 'mask';
opts.ChebOrd          = []; % default used: 50
opts.whichKernelType  = 'heatK'; % 'LPHP' '57' 'heatK'
opts.PrintNodeIndex   = false;
opts.PrintNodeIndex   = true;
opts.FigMenuBar       = 'none'; % 'figure' | 'none'

%-Settings, fixed. 
%--------------------------------------------------------------------------
ID = '100307';

gtypes = {
    'gmlh.res2000.spaceT1w' % lh CHC voxBG
    'gmrh.res2000.spaceT1w' % rh ...
    'gmlh.res1250.spaceT1w' 
    'gmrh.res1250.spaceT1w' 
    };
gtype = gtypes{which_graph};


d_scr     = fileparts(mfilename('fullpath'));
d_demos   = fileparts(d_scr);
d_main    = fileparts(d_demos);
d_src     = fullfile(d_main,'src','MATLAB'); 
d_hcpdata = fullfile(d_demos,'data','HCP','dataset');
addpath(genpath(d_src));

d_savefigs = fullfile(d_demos,'figs');
if ~exist(d_savefigs,'dir')
    mkdir(d_savefigs)
end

if ~isempty(path_spm12)
    addpath(path_spm12);
end

%-Load voxBG.
%--------------------------------------------------------------------------
d_graph = fullfile(d_hcpdata,ID,'T1w','graph',strrep(gtype,'.','_'));
n_graph = sprintf('G.%s.mat',gtype);
f_load = fullfile(d_graph,n_graph);
d = load(f_load);
G = d.G;

%-Visualize voxBG.
%--------------------------------------------------------------------------
loadODfs = false; % ok if false, but makes recalling hb_inspect_graph after a change to opts fileds slow

d = fullfile(d_savefigs,strrep(gtype,'.','_'));
opts.d_savefigs = d;
if ~exist(d,'dir')
    mkdir(d);
end

if loadODfs
    d = load(G.f.odf.fib_mat,'odf').odf;
    if size(d,2)~=G.N
        d = d(:,G.pruning.ind_pre_pruning_A_remained_post_pruning);
        assert(size(d,2)==G.N);
    end
    opts.odfs = repmat(d,2,1);
    opts.vertices = load(G.f.odf.fib_mat,'odf_vertices').odf_vertices;
end

% nodes = 
voxbg_inspect(G,opts)

disp('done.');
