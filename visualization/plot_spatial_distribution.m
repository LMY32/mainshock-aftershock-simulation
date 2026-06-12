%% 绘制空间分布图
%
% 输入：
%   catalog - 地震目录表
%   mainshock - 主震参数（可选）
%

function [] = plot_spatial_distribution(catalog, mainshock)
    if nargin < 2
        mainshock = [];
    end
    
    figure('Position', [100, 100, 1000, 600]);
    
    if istable(catalog) && height(catalog) > 0
        scatter(catalog.longitude, catalog.latitude, 50, catalog.magnitude, 'filled');
        hold on;
        
        if ~isempty(mainshock)
            plot(mainshock.longitude, mainshock.latitude, 'r*', 'MarkerSize', 20, 'LineWidth', 2);
        end
        
        colorbar;
        xlabel('经度 (°)', 'FontSize', 12);
        ylabel('纬度 (°)', 'FontSize', 12);
        title('空间分布图', 'FontSize', 14, 'FontWeight', 'bold');
        axis equal;
        grid on;
    end
    
end
