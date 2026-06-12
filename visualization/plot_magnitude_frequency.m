%% 绘制Gutenberg-Richter关系
%
% 输入：
%   catalog - 地震目录表
%

function [] = plot_magnitude_frequency(catalog)
    figure('Position', [100, 100, 1000, 600]);
    
    if istable(catalog) && height(catalog) > 0
        magnitudes = catalog.magnitude;
        Mc = min(magnitudes) - 0.1;
        
        mag_range = Mc:0.1:max(magnitudes)+0.5;
        cumulative_count = histcounts(magnitudes, [mag_range, inf], 'Normalization', 'count');
        cumulative_count = cumsum(cumulative_count(end:-1:1));
        cumulative_count = cumulative_count(end:-1:1);
        
        semilogy(mag_range(1:end-1), cumulative_count(1:end-1)+1, 'o-', 'LineWidth', 2, 'MarkerSize', 6);
        
        xlabel('震级 (M)', 'FontSize', 12);
        ylabel('累积数量', 'FontSize', 12);
        title('Gutenberg-Richter关系', 'FontSize', 14, 'FontWeight', 'bold');
        grid on;
    end
    
end
