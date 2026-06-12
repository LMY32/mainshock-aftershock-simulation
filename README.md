# 主震-余震序列模拟系统 (Mainshock-Aftershock Sequence Simulation)

## 项目概述

本项目是一个基于 MATLAB 的主震-余震序列数值模拟系统，考虑震源物理过程的影响。该系统集成了多个地震学模型，用于生成、分析和可视化主震-余震序列。

### 核心功能

- **ETAS 模型** - 流行病型余震序列（Epidemic Type Aftershock Sequence）
- **Omori-Utsu 衰减** - 余震时间衰减规律
- **库仑应力变化（CFF）** - 震源物理触发机制
- **动态破裂过程** - 主震破裂传播模拟
- **完整分析工具** - 震级分布、时空统计、参数反演
- **科学可视化** - 序列图、空间分布、统计分析

## 项目结构

```
mainshock-aftershock-simulation/
├── README.md
├── main_simulation.m
├── core/
│   ├── mainshock_model.m
│   ├── omori_utsu_model.m
│   ├── etas_model.m
│   ├── gutenberg_richter.m
│   └── coulomb_stress.m
├── simulation/
│   ├── generate_aftershock_sequence.m
│   ├── dynamic_rupture_process.m
│   └── source_parameter_random.m
├── analysis/
│   ├── magnitude_distribution.m
│   ├── temporal_analysis.m
│   ├── spatial_analysis.m
│   └── parameter_inversion.m
├── visualization/
│   ├── plot_sequence.m
│   ├── plot_spatial_distribution.m
│   ├── plot_magnitude_frequency.m
│   ├── plot_cumulative_moment.m
│   └── plot_statistics.m
├── data/
│   └── example_data.mat
└── examples/
    ├── example_basic_simulation.m
    ├── example_cff_triggering.m
    └── example_parameter_study.m
```

## 快速开始

```matlab
cd mainshock-aftershock-simulation
main_simulation
```

## 理论基础

### Omori-Utsu 模型

余震发生率衰减：λ(t) = K / (c + t)^p

### ETAS 模型

自激点过程：λ(t,x,y) = μ + Σ α·10^(β·(m_i - m_0))·(t - t_i + c)^(-p)

### 库仑应力变化（CFF）

ΔCFF = Δτ + μ'·ΔS_n

## 参考文献

1. Utsu et al. (1995) - Omori formula centenary
2. Ogata (1998) - ETAS model development
3. King et al. (1994) - Static stress triggering
4. Zhuang et al. (2002) - Stochastic declustering

## 许可证

MIT License
