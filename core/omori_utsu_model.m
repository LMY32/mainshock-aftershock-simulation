%% Omori-Utsu 余震衰减模型
% 经典的余震数随时间衰减规律
%
% 模型：λ(t) = K / (c + t)^p
%
% 输入：
%   time - 时间数组 (秒)
%   K - 主要参数
%   c - 时间偏移参数 (秒)
%   p - 衰减指数
%
% 输出：
%   lambda - 发生率 (events/second)
%

function [lambda] = omori_utsu_model(time, K, c, p)
    % 处理向量化输入
    if nargin < 4
        p = 0.9;        % 默认衰减指数
    end
    if nargin < 3
        c = 0.01;       % 默认时间偏移 (秒)
    end
    if nargin < 2
        K = 0.1;        % 默认参数
    end
    
    % Omori-Utsu 公式
    % λ(t) = K / (c + t)^p
    lambda = K ./ (c + time).^p;
    
    % 处理 NaN 或 Inf
    lambda(isnan(lambda) | isinf(lambda)) = 0;
    
end
