%% 主震-余震序列模拟主程序
% 该程序演示了完整的主震-余震序列模拟工作流
% 包括：数据生成、模型拟合、分析和可视化
%
% 作者: Seismic Simulation Team
% 日期: 2026-06-12

clear; clc; close all;

%% 1. 设置模拟参数
fprintf('\n========== 主震-余震序列模拟系统 ==========\n');
fprintf('正在初始化模拟参数...\n\n');

% 主震参数
mainshock.magnitude = 7.5;              % 主震震级
mainshock.depth = 15;                   % 震源深度 (km)
mainshock.latitude = 35.0;              % 纬度
mainshock.longitude = 139.0;            % 经度
mainshock.strike = 30;                  % 走向 (度)
mainshock.dip = 60;                     % 倾角 (度)
mainshock.rake = 90;                    % 滑动角 (度)
mainshock.rigidity = 3.2e10;            % 刚度 (Pa)
mainshock.time = 0;                     % 主震发生时刻 (秒)

% 模拟参数
params.K = 0.15;                        % Omori K参数
params.p = 0.9;                         % Omori 衰减指数 p
params.c = 0.01;                        % 时间偏移参数 c (秒)
params.alpha = 0.7;                     % ETAS alpha参数
params.beta = 1.0;                      % ETAS beta参数
params.mu = 0.01;                       % 背景地震率 (events/day)
params.mu_friction = 0.6;               % 有效摩擦系数
params.Mc = 3.0;                        % 完整震级
params.max_magnitude = mainshock.magnitude - 1.0;  % 最大余震震级
params.simulation_days = 365;           % 模拟天数
params.n_simulations = 100;             % 蒙特卡洛模拟次数

fprintf('主震参数：\n');
fprintf('  震级: M%.1f\n', mainshock.magnitude);
fprintf('  深度: %.1f km\n', mainshock.depth);
fprintf('  位置: (%.2f, %.2f)\n', mainshock.latitude, mainshock.longitude);
fprintf('\n模拟参数：\n');
fprintf('  模拟时长: %.0f 天\n', params.simulation_days);
fprintf('  完整震级: M%.1f\n', params.Mc);
fprintf('  蒙特卡洛样本: %d\n\n', params.n_simulations);

%% 2. 生成余震序列
fprintf('正在生成余震序列...\n');
aftershock_catalog = cell(params.n_simulations, 1);

for i = 1:params.n_simulations
    if mod(i, 10) == 0
        fprintf('  进度: %d/%d\n', i, params.n_simulations);
    end
    % 使用薄板模型生成随机余震序列
    [aftershock_catalog{i}] = generate_aftershock_sequence(mainshock, params);
end

fprintf('\n生成完成！总计 %d 条余震序列\n\n', params.n_simulations);

%% 3. 统计和分析
fprintf('正在进行统计分析...\n');

% 合并所有序列用于统计
all_aftershocks = vertcat(aftershock_catalog{:});

% 计算统计量
total_events = height(all_aftershocks);
avg_events_per_sequence = total_events / params.n_simulations;

fprintf('  总事件数: %d\n', total_events);
fprintf('  平均序列长度: %.1f 事件/序列\n', avg_events_per_sequence);

% Gutenberg-Richter 关系
[gr_a, gr_b, r_value] = magnitude_distribution(all_aftershocks);
fprintf('  G-R 参数: a=%.3f, b=%.3f (R=%.3f)\n', gr_a, gr_b, r_value);

% 时间分析 (Omori参数反演)
[omori_K, omori_p, omori_c] = temporal_analysis(all_aftershocks, params.simulation_days);
fprintf('  反演 Omori 参数: K=%.3f, p=%.3f, c=%.5f\n', omori_K, omori_p, omori_c);

% 空间分析
[spatial_stats] = spatial_analysis(all_aftershocks, mainshock);
fprintf('  空间集中度: %.3f km\n', spatial_stats.mean_distance);

fprintf('\n分析完成！\n\n');

%% 4. 库仑应力变化分析
fprintf('正在计算库仑应力变化 (CFF)...\n');

% 计算单个序列的 CFF
first_sequence = aftershock_catalog{1};
if height(first_sequence) > 0
    % 为前10个余震计算 CFF
    n_aftershocks_to_compute = min(10, height(first_sequence));
    
    cff_values = zeros(n_aftershocks_to_compute, 1);
    for i = 1:n_aftershocks_to_compute
        aftershock = first_sequence(i, :);
        [cff, ~, ~] = coulomb_stress(mainshock, aftershock, params.mu_friction);
        cff_values(i) = cff;
    end
    
    fprintf('  前 %d 个余震的平均 CFF: %.2f kPa\n', n_aftershocks_to_compute, mean(cff_values));
    fprintf('  CFF 范围: [%.2f, %.2f] kPa\n', min(cff_values), max(cff_values));
end

fprintf('\nCFF 计算完成！\n\n');

%% 5. 可视化
fprintf('正在生成可视化图表...\n');

% 创建图形窗口
figure('Position', [100, 100, 1400, 900]);

% 5.1 余震时间序列
subplot(2, 3, 1);
first_seq = aftershock_catalog{1};
if height(first_seq) > 0
    scatter(first_seq.time_days, first_seq.magnitude, 30, first_seq.magnitude, 'filled');
    hold on;
    plot([0, 0], [params.Mc, params.max_magnitude+1], 'r*', 'MarkerSize', 15, 'LineWidth', 2);
    xlabel('时间 (天)', 'FontSize', 11);
    ylabel('震级 (M)', 'FontSize', 11);
    title('余震时间序列', 'FontSize', 12, 'FontWeight', 'bold');
    colorbar;
    grid on;
    set(gca, 'YScale', 'linear');
end

% 5.2 震级频率关系 (Gutenberg-Richter)
subplot(2, 3, 2);
if height(all_aftershocks) > 0
    magnitudes = all_aftershocks.magnitude;
    mag_range = params.Mc:0.1:params.max_magnitude+1;
    cumulative_count = histcounts(magnitudes, [mag_range, inf], 'Normalization', 'count');
    cumulative_count = cumsum(cumulative_count(end:-1:1));
    cumulative_count = cumulative_count(end:-1:1);
    
    semilogy(mag_range(1:end-1), cumulative_count+1, 'o-', 'LineWidth', 2, 'MarkerSize', 6);
    hold on;
    
    % 理论 G-R 关系
    mag_theory = params.Mc:0.1:params.max_magnitude+1;
    log10_N = gr_a - gr_b * mag_theory;
    N_theory = 10.^log10_N;
    semilogy(mag_theory, N_theory, 'r--', 'LineWidth', 2, 'DisplayName', sprintf('G-R: b=%.2f', gr_b));
    
    xlabel('震级 (M)', 'FontSize', 11);
    ylabel('累积数量 (N)', 'FontSize', 11);
    title('Gutenberg-Richter 关系', 'FontSize', 12, 'FontWeight', 'bold');
    legend('观测', '理论', 'FontSize', 10);
    grid on;
end

% 5.3 空间分布
subplot(2, 3, 3);
if height(first_seq) > 0
    scatter(first_seq.longitude, first_seq.latitude, 30, first_seq.magnitude, 'filled');
    hold on;
    plot(mainshock.longitude, mainshock.latitude, 'r*', 'MarkerSize', 20, 'LineWidth', 2);
    xlabel('经度 (°)', 'FontSize', 11);
    ylabel('纬度 (°)', 'FontSize', 11);
    title('空间分布图', 'FontSize', 12, 'FontWeight', 'bold');
    colorbar;
    grid on;
    axis equal;
end

% 5.4 余震数随时间的变化
subplot(2, 3, 4);
if height(all_aftershocks) > 0
    time_bins = linspace(0, params.simulation_days, 50);
    event_counts = histcounts(all_aftershocks.time_days, time_bins);
    bar(time_bins(1:end-1), event_counts, 'FaceColor', [0.2, 0.5, 0.8]);
    xlabel('时间 (天)', 'FontSize', 11);
    ylabel('事件数', 'FontSize', 11);
    title('余震数随时间的分布', 'FontSize', 12, 'FontWeight', 'bold');
    grid on;
end

% 5.5 Omori 衰减曲线
subplot(2, 3, 5);
if height(all_aftershocks) > 0
    time_days = all_aftershocks.time_days;
    time_days(time_days < 0.01) = 0.01;  % 避免 log(0)
    
    % 计算衰减曲线
    t_theory = logspace(-2, log10(params.simulation_days), 100);
    lambda_theory = omori_K ./ (omori_c + t_theory).^omori_p;
    
    % 计算实际衰减（使用时间窗口内的事件数）
    loglog(time_days, 1:length(time_days), 'o', 'MarkerSize', 3, 'Alpha', 0.5);
    hold on;
    loglog(t_theory, lambda_theory * length(time_days) / lambda_theory(end), 'r-', 'LineWidth', 2);
    
    xlabel('时间 (天)', 'FontSize', 11);
    ylabel('累积事件数', 'FontSize', 11);
    title('Omori 衰减规律', 'FontSize', 12, 'FontWeight', 'bold');
    legend('观测', sprintf('理论: p=%.2f', omori_p), 'FontSize', 10);
    grid on;
end

% 5.6 震级分布直方图
subplot(2, 3, 6);
if height(all_aftershocks) > 0
    histogram(all_aftershocks.magnitude, 'BinEdges', params.Mc:0.2:params.max_magnitude+1, 'FaceColor', [0.8, 0.3, 0.3]);
    xlabel('震级 (M)', 'FontSize', 11);
    ylabel('频数', 'FontSize', 11);
    title('震级分布直方图', 'FontSize', 12, 'FontWeight', 'bold');
    grid on;
end

sgtitle('主震-余震序列模拟结果分析', 'FontSize', 14, 'FontWeight', 'bold');
fprintf('\n可视化完成！\n\n');

%% 6. 生成统计报告
fprintf('========== 模拟统计报告 ==========\n');
fprintf('\n基本统计：\n');
fprintf('  蒙特卡洛模拟数: %d\n', params.n_simulations);
fprintf('  总事件数: %d\n', total_events);
fprintf('  平均每序列事件数: %.1f\n', avg_events_per_sequence);
fprintf('  模拟时间: %.1f 天\n', params.simulation_days);
fprintf('\nSeismic Parameters:\n');
fprintf('  Gutenberg-Richter: log10(N) = %.3f - %.3f·M\n', gr_a, gr_b);
fprintf('  Omori Parameters: K=%.3f, p=%.3f, c=%.5f\n', omori_K, omori_p, omori_c);
fprintf('  背景地震率: %.3f events/day\n', params.mu);
fprintf('\n========================================\n\n');

fprintf('模拟完成！\n');
fprintf('更多功能请参考示例文件: examples/ 目录\n\n');
