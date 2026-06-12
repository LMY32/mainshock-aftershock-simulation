%% 生成余震序列
% 使用薄板随机模型生成主震后的余震序列
%
% 输入：
%   mainshock - 主震参数
%   params - 模拟参数
%
% 输出：
%   catalog - 余震目录表
%

function [catalog] = generate_aftershock_sequence(mainshock, params)
    % 提取参数
    K = params.K;
    p = params.p;
    c = params.c;
    alpha = params.alpha;
    beta = params.beta;
    Mc = params.Mc;
    max_magnitude = params.max_magnitude;
    simulation_days = params.simulation_days;
    
    % 时间转换
    simulation_seconds = simulation_days * 24 * 3600;  % 转换为秒
    
    % 初始化事件列表
    times = [];
    magnitudes = [];
    latitudes = [];
    longitudes = [];
    depths = [];
    
    % 主震破裂参数
    [rupture] = mainshock_model(mainshock);
    
    % 设置随机种子（可选）
    rng('shuffle');
    
    % 使用Hawkes过程生成事件
    current_time = 0;
    
    % 参考时间点用于计算发生率
    while current_time < simulation_seconds
        % 计算当前时间的背景发生率（Omori-Utsu）
        lambda_background = omori_utsu_model(current_time, K, c, p);
        
        % 如果有之前的地震，计算ETAS修正
        if ~isempty(times)
            % 创建临时事件表用于ETAS计算
            temp_events = table(times', magnitudes', 'VariableNames', {'time', 'magnitude'});
            lambda_etas = etas_model(current_time, temp_events, params);
        else
            lambda_etas = lambda_background;
        end
        
        % 总发生率
        lambda_total = lambda_etas;
        
        % 下一个事件的时间间隔（指数分布）
        if lambda_total > 0
            delta_t = -log(rand()) / lambda_total;
        else
            delta_t = inf;
        end
        
        current_time = current_time + delta_t;
        
        % 检查是否超过模拟时间
        if current_time >= simulation_seconds
            break;
        end
        
        % 生成地震的震级（按Gutenberg-Richter关系）
        % P(M >= m) = 10^(-b*(m - Mc))
        magnitude = Mc - (1/beta) * log10(rand());
        
        % 限制震级范围
        if magnitude > max_magnitude
            magnitude = max_magnitude;
        elseif magnitude < Mc
            magnitude = Mc + 0.1 * rand();  % 小于完整震级的事件
        end
        
        % 生成空间坐标（简化模型：高斯分布）
        % 空间集中度与地震矩成正相关
        spatial_scale = 5 * (magnitude - Mc + 1);  % km
        
        latitude = mainshock.latitude + spatial_scale * randn() / 111;  % 转换为度
        longitude = mainshock.longitude + spatial_scale * randn() / (111 * cos(deg2rad(mainshock.latitude)));
        depth = mainshock.depth + (randn() * 5);  % km，标准差5km
        
        % 限制深度
        depth = max(depth, 0);
        depth = min(depth, 50);
        
        % 存储事件
        times = [times; current_time];
        magnitudes = [magnitudes; magnitude];
        latitudes = [latitudes; latitude];
        longitudes = [longitudes; longitude];
        depths = [depths; depth];
    end
    
    % 转换时间为天数
    times_days = times / (24 * 3600);
    
    % 创建目录表
    catalog = table(
        times_days, ...
        times, ...
        magnitudes, ...
        latitudes, ...
        longitudes, ...
        depths, ...
        'VariableNames', {'time_days', 'time_seconds', 'magnitude', 'latitude', 'longitude', 'depth'}
    );
    
end
