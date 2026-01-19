# GPU-Queue-Runner

一个轻量级的Shell脚本工具，用于服务器上自动检测GPU空闲状态，当GPU满足条件时自动运行指定Python程序（支持多GPU检测、自动重启、日志记录），解决GPU排队等待的痛点。

---

## ✨ 特性

- 🎯 **GPU检测** - 自动检测GPU空闲内存和利用率，满足条件时自动启动程序
- 🔄 **通用化设计** - 支持任何Python程序或脚本，可传递任意参数
- 📊 **实时状态监控** - 提供详细的排队状态、GPU使用情况和进程信息
- ⏱️ **超时控制** - 默认8小时超时保护，防止程序无限运行
- 💾 **日志记录** - 自动记录运行日志，便于调试和追溯
- 🚀 **CPU备用模式** - GPU繁忙时可强制使用CPU运行
- 🔧 **灵活配置** - 可自定义GPU检测阈值和等待时间

---

## 📦 快速开始

### 环境准备

```bash
# 进入项目目录
cd <安装目录>

# 激活conda环境（如有需要）
conda activate ML
```
🎯 基本命令
```bash
# 启动智能GPU排队
./queue_manager.sh start '<program>'

# 查看详细状态（推荐常用）
./queue_manager.sh status

# 停止排队任务
./queue_manager.sh stop

# 强制使用CPU运行（GPU繁忙时备用）
./queue_manager.sh force-cpu '<program>'

# 查看完整的指令手册
./queue_manager.sh info
```
