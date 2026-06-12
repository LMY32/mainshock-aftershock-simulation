%% Gutenberg-Richter 关系
% 计算地震震级的频率-大小分布参数
%
% G-R 关系: log10(N) = a - b·M
%
% 输入：
%   magnitudes - 震级数组
%   Mc - 完整震级
%
% 输出：
%   a - G-R 参数 a
%   b - G-R 参数 b
%   r_value - 拟合相关系数
%

function [a, b, r_value] = gutenberg_richter(magnitudes, Mc)
    if nargin < 2
        Mc = 3.0;  % 默认完整震级
    end
    
    % 提取大于完整震级的地震
    valid_mags = magnitudes(magnitudes >= Mc);
    
    if isempty(valid_mags)
        a = 0;
        b = 1.0;
        r_value = 0;
        return;
    end
    
    % 计算累积数量
    mag_range = Mc:0.1:max(valid_mags)+0.5;
    cumulative_count = zeros(size(mag_range));
    
    for i = 1:length(mag_range)
        cumulative_count(i) = sum(valid_mags >= mag_range(i));
    end
    
    % 移除零值以用于对数拟合
    valid_idx = cumulative_count > 0;
    mag_range = mag_range(valid_idx);
    cumulative_count = cumulative_count(valid_idx);
    
    if length(mag_range) < 2
        a = 0;
        b = 1.0;
        r_value = 0;
        return;
    end
    
    % 对数线性拟合: log10(N) = a - b·M
    % 使用最小二乘法
    log10_N = log10(cumulative_count);
    
    % 线性回归: y = -b·x + a
    p = polyfit(mag_range, log10_N, 1);
    b = -p(1);
    a = p(2);
    
    % 计算相关系数
    y_pred = polyval(p, mag_range);
    ss_res = sum((log10_N - y_pred).^2);
    ss_tot = sum((log10_N - mean(log10_N)).^2);
    r_value = sqrt(1 - ss_res / ss_tot);
    
end
