%% ETAS (Epidemic Type Aftershock Sequence) 模型
% 自激点过程模型，每个地震都有触发后续地震的能力
%
% 模型：λ(t,x,y) = μ + Σ α·10^(β·(m_i - m_0))·(t - t_i + c)^(-p)
%
% 输入：
%   time - 观测时间点数组
%   events - 事件表，包含字段: time, magnitude
%   params - 模型参数结构体
%
% 输出：
%   lambda - 在给定时间的发生率
%

function [lambda] = etas_model(time, events, params)
    % 默认参数
    if ~isfield(params, 'mu')
        params.mu = 0.01;           % 背景地震率
    end
    if ~isfield(params, 'K')
        params.K = 0.1;
    end
    if ~isfield(params, 'alpha')
        params.alpha = 0.7;
    end
    if ~isfield(params, 'beta')
        params.beta = 1.0;
    end
    if ~isfield(params, 'p')
        params.p = 0.9;
    end
    if ~isfield(params, 'c')
        params.c = 0.01;
    end
    if ~isfield(params, 'm0')
        params.m0 = 3.0;            % 参考震级
    end
    
    % 初始化
    lambda = ones(size(time)) * params.mu;  % 背景地震率
    
    % 遍历所有过去的地震
    if ~isempty(events) && istable(events)
        for i = 1:height(events)
            event_time = events.time(i);
            event_mag = events.magnitude(i);
            
            % 计算该地震对当前时间的贡献
            % λ_i(t) = α·10^(β·(m_i - m_0))·(t - t_i + c)^(-p)
            time_since_event = time - event_time;
            
            % 只考虑主事件发生之后的时间
            valid_idx = time_since_event > 0;
            
            if any(valid_idx)
                magnitude_factor = params.alpha * 10^(params.beta * (event_mag - params.m0));
                lambda_contribution = magnitude_factor ./ (params.c + time_since_event).^params.p;
                lambda(valid_idx) = lambda(valid_idx) + lambda_contribution(valid_idx);
            end
        end
    end
    
    % 处理异常值
    lambda(isnan(lambda) | isinf(lambda)) = params.mu;
    lambda = max(lambda, 1e-6);  % 避免负值
    
end
