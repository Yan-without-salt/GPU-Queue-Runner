#!/bin/bash
# 通用GPU排队脚本

# 检查是否有传入程序命令
if [ $# -eq 0 ]; then
    echo "错误：请指定要运行的程序命令"
    echo "使用方法：./queue_pinn.sh <程序命令>"
    exit 1
fi

# 获取程序命令
PROGRAM_CMD="$@"
echo "=== 开始排队等待GPU空闲 ==="
echo "开始时间: $(date)"
echo "要运行的程序: $PROGRAM_CMD"
echo ""

# 确保日志目录存在
mkdir -p queue_logs

# 保存程序命令到文件（用于status命令显示）
echo "$PROGRAM_CMD" > queue_logs/.smart_program

# 记录状态
echo "状态: WAITING" > queue_logs/current_status.txt

# 等待条件：GPU空闲内存 > 8GB 且 GPU利用率 < 75%
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
    
    # 如果GPU空闲内存大于8GB且利用率低于75%，开始运行
    if [ "$FREE_MEM" -gt 8000 ] && [ "$GPU_UTIL" -lt 75 ]; then
        echo "GPU条件满足，开始运行程序..."
        echo "状态: RUNNING" > queue_logs/current_status.txt
        
        # 激活conda环境（如果需要，可以注释掉）
        source /public/home/clxy_zncl_ylq/apps/anaconda3/etc/profile.d/conda.sh
        conda activate ML
        
        # 运行程序，8小时超时
        timeout 28800 $PROGRAM_CMD
        
        # 程序结束
        EXIT_CODE=$?
        if [ $EXIT_CODE -eq 0 ]; then
            echo "状态: COMPLETED" > queue_logs/current_status.txt
            echo "程序成功结束"
        elif [ $EXIT_CODE -eq 124 ]; then
            echo "状态: TIMEOUT" > queue_logs/current_status.txt
            echo "程序因超时被终止"
        else
            echo "状态: FAILED" > queue_logs/current_status.txt
            echo "程序异常退出，错误码: $EXIT_CODE"
        fi
        
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
