%% 震级分布分析
% 计算Gutenberg-Richter关系参数
%
% 输入：
%   catalog - 地震目录表
%
% 输出：
%   a - G-R参数a
%   b - G-R参数b
%   r_value - 相关系数
%

function [a, b, r_value] = magnitude_distribution(catalog)
    if ~istable(catalog) || height(catalog) == 0
        a = 0;
        b = 1.0;
        r_value = 0;
        return;
    end
    
    magnitudes = catalog.magnitude;
    Mc = min(magnitudes) - 0.1;  % 完整震级取最小震级
    
    [a, b, r_value] = gutenberg_richter(magnitudes, Mc);
    
end
