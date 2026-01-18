#!/bin/bash
# 修复版的排队脚本

echo "=== 开始排队等待GPU空闲 ==="
echo "开始时间: $(date)"
echo ""

# 记录状态
echo "状态: WAITING" > queue_logs/current_status.txt

# 等待条件：GPU空闲内存 > 2GB 且 GPU利用率 < 50%
while true; do
    # 获取GPU信息
    FREE_MEM=$(nvidia-smi --query-gpu=memory.free --format=csv,noheader,nounits 2>/dev/null | head -1)
    GPU_UTIL=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -1)
    
    if [ -z "$FREE_MEM" ]; then
        FREE_MEM=0
    fi
    if [ -z "$GPU_UTIL" ]; then
        GPU_UTIL=100
    fi
    
    # 显示当前状态
    echo "[$(date '+%H:%M:%S')] GPU空闲内存: ${FREE_MEM}MB, GPU利用率: ${GPU_UTIL}%"
    
    # 如果GPU空闲内存大于2GB且利用率低于50%，开始运行
    if [ "$FREE_MEM" -gt 8000 ] && [ "$GPU_UTIL" -lt 75 ]; then
        echo "GPU条件满足，开始运行程序..."
        echo "状态: RUNNING" > queue_logs/current_status.txt
        
        # 激活conda环境
        source /public/home/clxy_zncl_ylq/apps/anaconda3/etc/profile.d/conda.sh
        conda activate ML
        
        # 运行程序，8小时超时
        timeout 28800 python code_pinn-3D
        
        # 程序结束
        echo "状态: COMPLETED" > queue_logs/current_status.txt
        echo "程序结束时间: $(date)"
        break
    else
        # 如果GPU被完全占用（利用率>90%），延长等待时间
        if [ "$GPU_UTIL" -gt 90 ]; then
            echo "GPU被完全占用，等待10分钟..."
            sleep 600
        else
            echo "等待GPU空闲，5分钟后再次检查..."
            sleep 300
        fi
    fi
done
