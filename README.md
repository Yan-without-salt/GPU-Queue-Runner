# GPU-Queue-Runner
一个轻量级的Shell脚本工具，用于服务器上自动检测GPU空闲状态，当GPU满足条件时自动运行指定Python程序（支持多GPU检测、自动重启、日志记录），解决GPU排队等待的痛点。
### 1. 安装
```bash
# 克隆仓库到本地/服务器
git clone https://github.com/你的GitHub用户名/gpu-queue-runner.git
cd gpu-queue-runner

# 赋予脚本执行权限
chmod +x queue_manager.sh queue_pinn.sh

# 启动智能排队
./queue_manager.sh start
# 查看状态
./queue_manager.sh status
# 停止排队
./queue_manager.sh stop
