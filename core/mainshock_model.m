%% 主震参数化模型
% 根据主震震级和物理参数，计算破裂尺度、应力降等
%
% 输入：
%   mainshock - 结构体，包含主震参数
% 输出：
%   rupture - 破裂参数
%

function [rupture] = mainshock_model(mainshock)
    % 常数
    mu = 3.2e10;                    % 刚度 (Pa)
    
    % 从震级计算地震矩 (Hanks & Kanamori 1979)
    % log10(M0) = 1.5*Mw + 4.4
    M0 = 10^(1.5 * mainshock.magnitude + 4.4);  % N·m
    
    % 破裂尺度关系
    % 基于 Wells & Coppersmith (1994)
    switch true
        case mainshock.magnitude < 5
            % 小震
            log_length = 0.5 * mainshock.magnitude - 2.8;  % 长度
            log_width = 0.3 * mainshock.magnitude - 1.4;   % 宽度
        case mainshock.magnitude < 7
            % 中等地震
            log_length = 0.56 * mainshock.magnitude - 2.9;
            log_width = 0.41 * mainshock.magnitude - 1.61;
        otherwise
            % 大地震
            log_length = 0.63 * mainshock.magnitude - 3.55;
            log_width = 0.5 * mainshock.magnitude - 2.36;
    end
    
    rupture.length = 10^log_length * 1000;      % 破裂长度 (m)
    rupture.width = 10^log_width * 1000;        % 破裂宽度 (m)
    rupture.area = rupture.length * rupture.width;  % 破裂面积 (m^2)
    
    % 平均滑动量
    % Mo = mu * A * u
    rupture.mean_slip = M0 / (mu * rupture.area);  % 平均滑动 (m)
    
    % 应力降 (stress drop)
    % Δσ = M0 / (2*A) * (L + W) / (L * W)
    rupture.stress_drop = (M0 / (2 * rupture.area)) * ((rupture.length + rupture.width) / (rupture.length * rupture.width));
    
    % 储存地震矩
    rupture.M0 = M0;
    rupture.magnitude = mainshock.magnitude;
    
    % 主震位置
    rupture.latitude = mainshock.latitude;
    rupture.longitude = mainshock.longitude;
    rupture.depth = mainshock.depth;
    
    % 断层机制
    rupture.strike = mainshock.strike;
    rupture.dip = mainshock.dip;
    rupture.rake = mainshock.rake;
    
end
