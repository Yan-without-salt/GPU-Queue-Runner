# GPU-Queue-Runner
一个轻量级的Shell脚本工具，用于服务器上自动检测GPU空闲状态，当GPU满足条件时自动运行指定Python程序（支持多GPU检测、自动重启、日志记录），解决GPU排队等待的痛点。

cd <打开安装目录>
conda activate ML

### 1. 安装
1.1创建第一个脚本 queue_pinn.sh：
cat > queue_pinn.sh << 'EOF'
……
EOF
1.2# 创建第二个脚本 queue_manager.sh
cat > queue_manager.sh << 'EOF'
……
EOF

###2. 赋予脚本执行权限
chmod +x queue_manager.sh queue_pinn.sh

./queue_manager.sh start '<program>'    # 启动智能排队"
./queue_manager.sh status               # 查看详细状态"
./queue_manager.sh stop                 # 停止排队"
./queue_manager.sh force-cpu '<program>' # 强制用CPU运行"
./queue_manager.sh info                 #指令介绍
