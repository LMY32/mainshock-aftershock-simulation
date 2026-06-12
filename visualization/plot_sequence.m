%% 绘制余震时间序列
%
% 输入：
%   catalog - 地震目录表
%   mainshock - 主震参数（可选）
%

function [] = plot_sequence(catalog, mainshock)
    if nargin < 2
        mainshock = [];
    end
    
    figure('Position', [100, 100, 1000, 600]);
    
    if istable(catalog) && height(catalog) > 0
        scatter(catalog.time_days, catalog.magnitude, 50, catalog.magnitude, 'filled');
        hold on;
        
        if ~isempty(mainshock)
            plot(0, mainshock.magnitude, 'r*', 'MarkerSize', 20, 'LineWidth', 2);
        end
        
        colorbar;
        xlabel('时间 (天)', 'FontSize', 12);
        ylabel('震级 (M)', 'FontSize', 12);
        title('余震时间序列', 'FontSize', 14, 'FontWeight', 'bold');
        grid on;
    end
    
end
