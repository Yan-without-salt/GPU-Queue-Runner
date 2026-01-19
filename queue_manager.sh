#!/bin/bash
# 排队管理器

case "$1" in
    start)
        if [ $# -lt 2 ]; then
            echo "错误：请指定要运行的程序命令"
            echo "使用方法：./queue_manager.sh start '<程序命令>'"
            echo "示例：./queue_manager.sh start 'python code_pinn-3D'"
            echo "示例：./queue_manager.sh start 'python my_script.py --arg1 value1'"
            exit 1
        fi
        
        echo "启动排队系统..."
        
        # 检查是否已在运行
        if ps aux | grep "queue_pinn.sh" | grep -v grep > /dev/null; then
            echo "排队系统已在运行"
            exit 0
        fi
        
        # 获取要运行的程序命令（从第二个参数开始）
        PROGRAM_CMD="${@:2}"
        
        # 启动排队脚本并传递程序命令
        nohup ./queue_pinn.sh $PROGRAM_CMD > queue_logs/smart_run_$(date +%Y%m%d_%H%M%S).log 2>&1 &
        
        PID=$!
        echo $PID > queue_logs/.smart_pid
        
        # 保存程序命令用于状态显示
        echo "$PROGRAM_CMD" > queue_logs/.smart_program
        
        echo "智能排队已启动，PID: $PID"
        echo "要运行的程序: $PROGRAM_CMD"
        ;;
        
    status)
        echo "=== 排队状态 ==="
        echo "检查时间: $(date)"
        echo ""
    
        # 方法1：检查PID文件
        if [ -f "queue_logs/.smart_pid" ]; then
            PID=$(cat queue_logs/.smart_pid 2>/dev/null)
            if ps -p $PID > /dev/null 2>&1; then
                echo -n "✓ 排队进程运行中（通过PID文件），PID: $PID"
                # 显示排队的代码文件名
                if [ -f "queue_logs/.smart_program" ]; then
                    PROGRAM_NAME=$(cat queue_logs/.smart_program)
                    echo "，\"排队的代码的文件名: $PROGRAM_NAME\""
                else
                    echo ""
                fi
            
                # 显示当前状态
                if [ -f "queue_logs/current_status.txt" ]; then
                    echo "当前状态:"
                    cat queue_logs/current_status.txt
                fi
            else
                echo "✗ 排队进程已结束"
                rm -f queue_logs/.smart_pid queue_logs/.smart_program
            fi
        else
            echo "✗ 没有PID文件"
        fi
    
        echo ""
    
        # 方法2：直接检查进程
        echo "=== 进程检查 ==="
        if ps aux | grep "queue_pinn.sh" | grep -v grep > /dev/null; then
            echo "✓ queue_pinn.sh 进程在运行:"
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
        ;;
            
    stop)
        echo "停止智能排队..."
        if [ -f "queue_logs/.smart_pid" ]; then
            PID=$(cat queue_logs/.smart_pid)
            kill $PID 2>/dev/null
            rm -f queue_logs/.smart_pid queue_logs/.smart_program
            echo "排队已停止"
        else
            echo "没有正在运行的排队任务"
        fi
        ;;
        
    force-cpu)
        if [ $# -lt 2 ]; then
            echo "错误：请指定要运行的程序命令"
            echo "使用方法：./queue_manager.sh force-cpu '<程序命令>'"
            exit 1
        fi
        
        echo "强制使用CPU运行..."
        PROGRAM_CMD="${@:2}"
        CUDA_VISIBLE_DEVICES="" nohup timeout 28800 $PROGRAM_CMD > cpu_force_run_$(date +%Y%m%d_%H%M%S).log 2>&1 &
        
        echo "CPU强制运行已启动，PID: $!"
        echo "要运行的程序: $PROGRAM_CMD"
        ;;
        
    info)
        echo "使用方法:"
        echo "  ./queue_manager.sh start '<program>'    # 启动智能排队"
        echo "  ./queue_manager.sh status               # 查看详细状态"
        echo "  ./queue_manager.sh stop                 # 停止排队"
        echo "  ./queue_manager.sh force-cpu '<program>' # 强制用CPU运行"
        echo ""
        ;;
esac
