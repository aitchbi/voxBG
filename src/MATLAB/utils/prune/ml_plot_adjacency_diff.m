function ml_plot_adjacency_diff(A,B,mask,slice,outline,center,varargin)
% ML_PLOT_ADJACENCY_DIFF Plot adjacency diff.
%   ML_PLOT_ADJACENCY_DIFF(A,B,mask,slice)
%       Plots the edges in adjacency matrix A that are not in B. mask is a
%       3D tensor whose non-zero elements, indexed linearly, correspond to
%       the nodes in A. slice specifies the z coordinate of the xy plane
%       with which to slice the mask volume. Only edges within in this
%       plane is plotted.
%   ML_PLOT_ADJACENCY_DIFF(A,B,mask,slice,outline)
%       outline specifies the outlining of the voxels. Possible values:
%           'none' - no outlining (default).
%           'grid' - a grid is drawn outlining all voxels.
%           'diff' - only voxels that differ are outlined.
%   ML_PLOT_ADJACENCY_DIFF(A,B,mask,slice,outline,center)
%       center specifies whether or not the center of the voxels that
%       differ should be marked with a small circle. Default is false.
%   ML_PLOT_ADJACENCY_DIFF(A,B,mask,slice,outline,center,options)
%       options is a list of key-value pairs specifying how the different
%       kinds of edges are plotted. The key is one of the characters '-',
%       '|', '/' and '\', and the value is the line specifications (line
%       style, marker and color) of the plotted edges.
%
%   Example:
%       ml_plot_adjacency_diff(A,B,mask,130,'diff',true,'-','r','|','b');
%
%   Author:
%       Martin Larsson
%       March 2017

    if ~exist('outline','var')
        outline = 'none';
    end
    if ~exist('center','var')
        center = false;
    end

    edges = setdiff(find(A),find(B));
    indices = find(mask);
    
    [a,b] = ind2sub(size(A),edges);
    keep = a > b;
    ab = zeros(1,length(edges));
    ab(1:2:end) = a(keep);
    ab(2:2:end) = b(keep);

    [x,y,z] = ind2sub(size(mask),indices(ab)');

    x = reshape(x,2,length(x)/2);
    y = reshape(y,2,length(y)/2);
    z = reshape(z,2,length(z)/2);

    keep = z == slice;
    keep = keep(1,:) & keep(2,:);

    x = x(:,keep);
    y = y(:,keep);

    % Plot mask.
    imshow(mask(:,:,slice)');
    tf = ishold;
    hold on

    noptions = length(varargin);
    if mod(noptions,2) ~= 0
        error('Number of options must be a multiple of two.');
    else
        % Remove edges we are not interested in.
        if noptions > 0
            dirs = '-/|\';
            dir = (x(1,:)-x(2,:))+3*(y(1,:)-y(2,:));

            keep = false(size(dir));
            for i=1:2:noptions
                if ~ismember(varargin{i},dirs)
                    error(['Edge direction must be ''-'', ''|'', ''/'' '...
                        'or ''\''.']);
                end
                keep = keep | (dir == find(dirs==varargin{i}));
            end
            x = x(:,keep);
            y = y(:,keep);
            dir = dir(keep);
        end

        % Plot black squares.
        voxels = unique([x(:) y(:)],'rows');
        if strcmpi(outline,'diff')
            xs = repmat(voxels(:,1)',5,1);
            ys = repmat(voxels(:,2)',5,1);
            xs = xs+repmat([-0.5; -0.5; 0.5; 0.5; -0.5],1,size(xs,2));
            ys = ys+repmat([-0.5; 0.5; 0.5; -0.5; -0.5],1,size(ys,2));
            plot(xs,ys,'k');
        end

        % Plot edges.
        if noptions > 0
            for i=1:2:noptions
                diri = find(dirs == varargin{i});
                plot(x(:,dir == diri),y(:,dir == diri),varargin{i+1},...
                    'linewidth',2);
            end
        else
            plot(x,y,'r','linewidth',2);
        end

        % Plot black circles.
        if center
            circle_pts = 17;
            t = linspace(0,2*pi,circle_pts)';
            cx = 0.125*cos(t);
            cy = 0.125*sin(t);
            xs = repmat(voxels(:,1)',circle_pts,1);
            ys = repmat(voxels(:,2)',circle_pts,1);
            xs = xs+repmat(cx,1,size(xs,2));
            ys = ys+repmat(cy,1,size(ys,2));
            fill(xs,ys,'k');
        end
    end

    % Flip axes.
    ax = gca;
    ax.XDir = 'reverse';
    ax.YDir = 'normal';

    % Enable grid but hide ticks.
    if strcmpi(outline,'grid')
        axis on
        grid on
        ax.XTick = 1.5:size(mask,1);
        ax.YTick = 1.5:size(mask,2);
        ax.XColor = 'none';
        ax.YColor = 'none';
    end

    % Restore hold state.
    if ~tf
        hold off
    end
end
