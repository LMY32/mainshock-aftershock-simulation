%% 空间分布分析
% 分析余震的空间分布特性
%
% 输入：
%   catalog - 地震目录表
%   mainshock - 主震参数
%
% 输出：
%   spatial_stats - 空间统计量结构体
%

function [spatial_stats] = spatial_analysis(catalog, mainshock)
    if ~istable(catalog) || height(catalog) == 0
        spatial_stats.mean_distance = 0;
        spatial_stats.std_distance = 0;
        spatial_stats.max_distance = 0;
        spatial_stats.concentration = 0;
        return;
    end
    
    % 计算到主震的距离
    R_earth = 6371;  % km
    
    lats = catalog.latitude;
    lons = catalog.longitude;
    depths = catalog.depth;
    
    main_lat = mainshock.latitude;
    main_lon = mainshock.longitude;
    main_depth = mainshock.depth;
    
    % Haversine公式
    dLat = deg2rad(lats - main_lat);
    dLon = deg2rad(lons - main_lon);
    
    a = sin(dLat/2).^2 + cos(deg2rad(main_lat)) * cos(deg2rad(lats)) .* sin(dLon/2).^2;
    c = 2 * asin(sqrt(a));
    horizontal_distance = R_earth * c;  % km
    
    % 垂直距离
    vertical_distance = abs(depths - main_depth);  % km
    
    % 总距离
    total_distance = sqrt(horizontal_distance.^2 + vertical_distance.^2);  % km
    
    % ���计
    spatial_stats.mean_distance = mean(total_distance);
    spatial_stats.std_distance = std(total_distance);
    spatial_stats.max_distance = max(total_distance);
    spatial_stats.min_distance = min(total_distance);
    spatial_stats.median_distance = median(total_distance);
    
    % 空间集中度（距离内90%的事件）
    spatial_stats.concentration = prctile(total_distance, 90);
    
end
