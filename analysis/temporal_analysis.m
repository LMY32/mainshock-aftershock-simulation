%% 时间统计分析
% 分析余震序列的时间特性，反演Omori参数
%
% 输入：
%   catalog - 地震目录表
%   simulation_days - 模拟时间（天）
%
% 输出：
%   K - Omori K参数
%   p - Omori p参数
%   c - Omori c参数
%

function [K, p, c] = temporal_analysis(catalog, simulation_days)
    if ~istable(catalog) || height(catalog) < 10
        K = 0.1;
        p = 0.9;
        c = 0.01;
        return;
    end
    
    time_days = catalog.time_days;
    
    % 时间窗口
    time_windows = linspace(0, max(time_days), 30);
    event_counts = histcounts(time_days, time_windows);
    window_centers = (time_windows(1:end-1) + time_windows(2:end)) / 2;
    
    % 移除零值
    valid_idx = event_counts > 0;
    window_centers = window_centers(valid_idx);
    event_counts = event_counts(valid_idx);
    
    if length(window_centers) < 3
        K = 0.1;
        p = 0.9;
        c = 0.01;
        return;
    end
    
    % 对Omori模型进行对数线性拟合
    % ln(λ(t)) = ln(K) - p*ln(c+t)
    log_counts = log(event_counts + 0.1);  % 避免log(0)
    log_time = log(window_centers + 0.01);  % 避免log(0)
    
    % 线性回归
    p_coef = polyfit(log_time, log_counts, 1);
    p = -p_coef(1);  % Omori p参数
    K = exp(p_coef(2));  % Omori K参数
    c = 0.01;  % c参数固定
    
    % 确保参数合理
    if p < 0.5
        p = 0.5;
    elseif p > 1.5
        p = 1.5;
    end
    
end
