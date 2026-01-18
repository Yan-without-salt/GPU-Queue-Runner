#!/bin/bash
# 排队管理器

case "$1" in
    start)
        echo "启动智能排队系统..."
        
        # 检查是否已在运行
        if ps aux | grep "queue_pinn.sh" | grep -v grep > /dev/null; then
            echo "排队系统已在运行"
            exit 0
        fi
        
        # 启动修复版排队脚本
        nohup ./queue_pinn.sh > queue_logs/smart_run_$(date +%Y%m%d_%H%M%S).log 2>&1 &
        
        PID=$!
        echo $PID > queue_logs/.smart_pid
        echo "智能排队已启动，PID: $PID"
        ;;
        
    status)
        echo "=== 智能排队状态 ==="
        echo "检查时间: $(date)"
        echo ""
    
    # 方法1：检查PID文件
        if [ -f "queue_logs/.smart_pid" ]; then
            PID=$(cat queue_logs/.smart_pid 2>/dev/null)
            if ps -p $PID > /dev/null 2>&1; then
                echo "✓ 排队进程运行中（通过PID文件），PID: $PID"
            
            # 显示当前状态
                if [ -f "queue_logs/current_status.txt" ]; then
                    echo "当前状态:"
                    cat queue_logs/current_status.txt
                fi
            else
                echo "✗ 排队进程已结束"
                rm -f queue_logs/.smart_pid
            fi
        else
            echo "✗ 没有PID文件"
        fi
    
        echo ""
    
        # 方法2：直接检查进程
        echo "=== 直接进程检查 ==="
        if ps aux | grep "queue_pinn.sh" | grep -v grep > /dev/null; then
            echo "✓ queue_pinn.sh 进程确实在运行:"
            ps aux | grep "queue_pinn.sh" | grep -v grep
        else
            echo "✗ 没有找到 queue_pinn.sh 进程"
        fi
        
        echo ""
        echo "=== GPU详细状态 ==="
        nvidia-smi --query-gpu=name,memory.total,memory.used,memory.free,utilization.gpu --format=csv
        
        echo ""
        echo "=== 占用GPU的进程 ==="
        nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv 2>/dev/null | head -10
        # 注意：移除了 user 字段，因为不同版本的nvidia-smi可能字段名不同
        ;;
            
        stop)
            echo "停止智能排队..."
            if [ -f "queue_logs/.smart_pid" ]; then
                PID=$(cat queue_logs/.smart_pid)
                kill $PID 2>/dev/null
                rm -f queue_logs/.smart_pid
                echo "排队已停止"
            else
                echo "没有正在运行的排队任务"
            fi
            ;;
        
    force-cpu)
        echo "强制使用CPU运行..."
        CUDA_VISIBLE_DEVICES="" nohup timeout 28800 python code_pinn-3D > cpu_force_run_$(date +%Y%m%d_%H%M%S).log 2>&1 &
        echo "CPU强制运行已启动，PID: $!"
        ;;
        
    *)
        echo "使用方法:"
        echo "  ./queue_manager.sh start       # 启动智能排队"
        echo "  ./queue_manager.sh status      # 查看详细状态"
        echo "  ./queue_manager.sh stop        # 停止排队"
        echo "  ./queue_manager.sh force-cpu   # 强制用CPU运行"
        ;;
esac
