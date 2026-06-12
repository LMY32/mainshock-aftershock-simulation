%% 库仑应力变化 (Coulomb Failure Function, CFF)
% 计算主震对周围点的库仑应力变化
%
% CFF = Δτ + μ'·ΔS_n
%
% 输入：
%   mainshock - 主震参数
%   observation_point - 观测点（可为另一个余震）
%   mu_friction - 有效摩擦系数
%
% 输出：
%   CFF - 库仑应力变化 (kPa)
%   delta_tau - 剪应力变化 (kPa)
%   delta_sn - 正应力变化 (kPa)
%

function [CFF, delta_tau, delta_sn] = coulomb_stress(mainshock, observation_point, mu_friction)
    % 常数
    if nargin < 3
        mu_friction = 0.6;  % 默认摩擦系数
    end
    
    % 地球参数
    R_earth = 6371;         % 地球半径 (km)
    
    % 计算主震破裂参数
    [rupture] = mainshock_model(mainshock);
    
    % 计算观测点到主震的距离
    obs_lat = observation_point.latitude;
    obs_lon = observation_point.longitude;
    obs_depth = observation_point.depth;
    
    main_lat = mainshock.latitude;
    main_lon = mainshock.longitude;
    main_depth = mainshock.depth;
    
    % Haversine 公式计算大圆距离
    dLat = deg2rad(obs_lat - main_lat);
    dLon = deg2rad(obs_lon - main_lon);
    
    a = sin(dLat/2)^2 + cos(deg2rad(main_lat)) * cos(deg2rad(obs_lat)) * sin(dLon/2)^2;
    c = 2 * asin(sqrt(a));
    horizontal_distance = R_earth * c;  % km
    
    % 垂直距离
    vertical_distance = obs_depth - main_depth;  % km
    
    % 总距离
    total_distance = sqrt(horizontal_distance^2 + vertical_distance^2);  % km
    
    % 避免距离为0
    if total_distance < 0.1
        total_distance = 0.1;
    end
    
    % 归一化的应力与距离的关系
    % 简化模型：应力随距离反比衰减
    % 实际应用中应使用更复杂的弹性位移解（如Okada模型）
    
    % 基于Eshelby椭球模型的简化
    stress_factor = rupture.stress_drop * rupture.area / (total_distance * 1000)^2;  % kPa
    
    % 估计剪应力和正应力变化
    % 这里使用简化的方向因子
    theta = atan2(vertical_distance, horizontal_distance);  % 角度
    
    % 根据断层机制调整
    strike_rad = deg2rad(mainshock.strike);
    dip_rad = deg2rad(mainshock.dip);
    rake_rad = deg2rad(mainshock.rake);
    
    % 方向余弦
    dir_cos = cos(strike_rad) * cos(dip_rad);
    
    % 应力分量（简化模型）
    delta_tau = stress_factor * abs(sin(2 * (theta - dip_rad)) * cos(rake_rad)) * dir_cos;  % 剪应力
    delta_sn = stress_factor * sin(2 * (theta - dip_rad)) * sin(rake_rad);                   % 正应力
    
    % 库仑应力变化
    CFF = delta_tau + mu_friction * delta_sn;
    
end
