%% 基础模拟示例
% 演示最基本的主震-余震序列模拟过程
%

clear; clc; close all;

fprintf('\n========== 基础模拟示例 ==========\n\n');

%% 设置参数
mainshock.magnitude = 7.0;
mainshock.depth = 15;
mainshock.latitude = 35.0;
mainshock.longitude = 139.0;
mainshock.strike = 30;
mainshock.dip = 60;
mainshock.rake = 90;

params.K = 0.12;
params.p = 0.9;
params.c = 0.01;
params.alpha = 0.7;
params.beta = 1.0;
params.mu = 0.01;
params.mu_friction = 0.6;
params.Mc = 3.0;
params.max_magnitude = mainshock.magnitude - 1.0;
params.simulation_days = 100;
params.n_simulations = 50;

%% 生成序列
fprintf('生成50条余震序列...\n');
afterstock_catalog = cell(50, 1);
for i = 1:50
    afterstock_catalog{i} = generate_aftershock_sequence(mainshock, params);
end

all_events = vertcat(afterstock_catalog{:});

%% 分析
fprintf('\n分析结果:\n');
fprintf('总事件数: %d\n', height(all_events));
fprintf('平均每序列: %.1f 事件\n', height(all_events)/50);

%% 可视化
figure('Position', [100, 100, 1200, 800]);

subplot(2, 2, 1);
first_seq = afterstock_catalog{1};
if height(first_seq) > 0
    scatter(first_seq.time_days, first_seq.magnitude, 30, first_seq.magnitude, 'filled');
end
xlabel('时间 (天)');
ylabel('震级');
title('单条序列');
grid on;

subplot(2, 2, 2);
if height(all_events) > 0
    mag_range = params.Mc:0.1:params.max_magnitude+1;
    cum_count = histcounts(all_events.magnitude, [mag_range, inf]);
    cum_count = cumsum(cum_count(end:-1:1));
    cum_count = cum_count(end:-1:1);
    semilogy(mag_range(1:end-1), cum_count+1, 'o-');
end
xlabel('震级');
ylabel('累积数量');
title('G-R关系');
grid on;

subplot(2, 2, 3);
if height(first_seq) > 0
    scatter(first_seq.longitude, first_seq.latitude, 30, first_seq.magnitude, 'filled');
    hold on;
    plot(mainshock.longitude, mainshock.latitude, 'r*', 'MarkerSize', 15);
end
xlabel('经度');
ylabel('纬度');
title('空间分布');
axis equal;
grid on;

subplot(2, 2, 4);
if height(all_events) > 0
    histogram(all_events.magnitude, 'BinEdges', params.Mc:0.2:params.max_magnitude+1);
end
xlabel('震级');
ylabel('频数');
title('震级分布直方图');
grid on;

fprintf('\n完成！\n');
