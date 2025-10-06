#!/bin/bash

# Knowledge Chain - 启动依赖服务脚本
# 启动 Redis、Zookeeper、MinIO 服务

echo "=========================================="
echo "Knowledge Chain - 启动依赖服务"
echo "=========================================="

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查服务是否已运行
check_service() {
    local service_name=$1
    local port=$2
    local pid_file=$3
    
    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if ps -p $pid > /dev/null 2>&1; then
            log_warning "$service_name 已在运行 (PID: $pid)"
            return 0
        else
            rm -f "$pid_file"
        fi
    fi
    
    if lsof -i :$port > /dev/null 2>&1; then
        log_warning "$service_name 端口 $port 已被占用"
        return 0
    fi
    
    return 1
}

# 启动 Redis
start_redis() {
    log_info "启动 Redis 服务..."
    
    local redis_path="/Users/wuzhangyin/soft/redis-6.2.14"
    local redis_pid_file="/tmp/redis.pid"
    local redis_port=6379
    
    if check_service "Redis" $redis_port $redis_pid_file; then
        return 0
    fi
    
    if [ ! -d "$redis_path" ]; then
        log_error "Redis 路径不存在: $redis_path"
        return 1
    fi
    
    # 启动 Redis 服务器
    cd "$redis_path"
    nohup ./src/redis-server redis.conf --daemonize yes --pidfile $redis_pid_file > /tmp/redis.log 2>&1 &
    
    # 等待启动
    sleep 2
    
    # 检查是否启动成功
    if [ -f "$redis_pid_file" ] && ps -p $(cat $redis_pid_file) > /dev/null 2>&1; then
        log_success "Redis 启动成功 (PID: $(cat $redis_pid_file))"
        return 0
    else
        log_error "Redis 启动失败"
        return 1
    fi
}

# 启动 Zookeeper
start_zookeeper() {
    log_info "启动 Zookeeper 服务..."
    
    local zk_path="/Users/wuzhangyin/soft/apache-zookeeper-3.8.4-bin"
    local zk_pid_file="/tmp/zookeeper.pid"
    local zk_port=2181
    
    if check_service "Zookeeper" $zk_port $zk_pid_file; then
        return 0
    fi
    
    if [ ! -d "$zk_path" ]; then
        log_error "Zookeeper 路径不存在: $zk_path"
        return 1
    fi
    
    # 检查配置文件
    local zk_conf="$zk_path/conf/zoo.cfg"
    if [ ! -f "$zk_conf" ]; then
        log_warning "Zookeeper 配置文件不存在，创建默认配置..."
        cat > "$zk_conf" << EOF
tickTime=2000
dataDir=$zk_path/data
clientPort=2181
initLimit=5
syncLimit=2
EOF
        mkdir -p "$zk_path/data"
    fi
    
    # 启动 Zookeeper
    cd "$zk_path"
    nohup ./bin/zkServer.sh start > /tmp/zookeeper.log 2>&1 &
    
    # 等待启动
    sleep 3
    
    # 检查是否启动成功
    if lsof -i :$zk_port > /dev/null 2>&1; then
        log_success "Zookeeper 启动成功 (端口: $zk_port)"
        return 0
    else
        log_error "Zookeeper 启动失败"
        return 1
    fi
}

# 启动 MinIO
start_minio() {
    log_info "启动 MinIO 服务..."
    
    local minio_data_dir="/Users/wuzhangyin/opt/ZSMART_HOME/minio/data"
    local minio_pid_file="/tmp/minio.pid"
    local minio_port=9000
    local minio_console_port=9001
    
    if check_service "MinIO" $minio_port $minio_pid_file; then
        return 0
    fi
    
    # 创建数据目录
    mkdir -p "$minio_data_dir"
    
    # 检查 MinIO 命令是否可用
    if ! command -v minio &> /dev/null; then
        log_error "MinIO 命令未找到，请确保 MinIO 已安装并在 PATH 中"
        return 1
    fi
    
    # 启动 MinIO
    nohup minio server "$minio_data_dir" --address ":9000" --console-address ":9001" > /tmp/minio.log 2>&1 &
    local minio_pid=$!
    echo $minio_pid > $minio_pid_file
    
    # 等待启动
    sleep 3
    
    # 检查是否启动成功
    if ps -p $minio_pid > /dev/null 2>&1 && lsof -i :$minio_port > /dev/null 2>&1; then
        log_success "MinIO 启动成功 (PID: $minio_pid)"
        log_info "MinIO 服务地址: http://localhost:9000"
        log_info "MinIO 控制台地址: http://localhost:9001"
        return 0
    else
        log_error "MinIO 启动失败"
        return 1
    fi
}

# 停止所有服务
stop_services() {
    log_info "停止所有服务..."
    
    # 停止 Redis
    if [ -f "/tmp/redis.pid" ]; then
        local redis_pid=$(cat /tmp/redis.pid)
        if ps -p $redis_pid > /dev/null 2>&1; then
            kill $redis_pid
            log_info "Redis 已停止"
        fi
        rm -f /tmp/redis.pid
    fi
    
    # 停止 Zookeeper
    if lsof -i :2181 > /dev/null 2>&1; then
        pkill -f "zookeeper" || true
        log_info "Zookeeper 已停止"
    fi
    
    # 停止 MinIO
    if [ -f "/tmp/minio.pid" ]; then
        local minio_pid=$(cat /tmp/minio.pid)
        if ps -p $minio_pid > /dev/null 2>&1; then
            kill $minio_pid
            log_info "MinIO 已停止"
        fi
        rm -f /tmp/minio.pid
    fi
}

# 检查服务状态
check_status() {
    log_info "检查服务状态..."
    
    # 检查 Redis
    if lsof -i :6379 > /dev/null 2>&1; then
        log_success "Redis: 运行中 (端口: 6379)"
    else
        log_error "Redis: 未运行"
    fi
    
    # 检查 Zookeeper
    if lsof -i :2181 > /dev/null 2>&1; then
        log_success "Zookeeper: 运行中 (端口: 2181)"
    else
        log_error "Zookeeper: 未运行"
    fi
    
    # 检查 MinIO
    if lsof -i :9000 > /dev/null 2>&1; then
        log_success "MinIO: 运行中 (端口: 9000)"
        log_info "MinIO 控制台: http://localhost:9001"
    else
        log_error "MinIO: 未运行"
    fi
}

# 主函数
main() {
    case "${1:-start}" in
        "start")
            log_info "启动所有依赖服务..."
            start_redis
            start_zookeeper
            start_minio
            echo
            check_status
            ;;
        "stop")
            stop_services
            ;;
        "restart")
            stop_services
            sleep 2
            main start
            ;;
        "status")
            check_status
            ;;
        "help"|"-h"|"--help")
            echo "用法: $0 [start|stop|restart|status|help]"
            echo
            echo "命令:"
            echo "  start   - 启动所有服务 (默认)"
            echo "  stop    - 停止所有服务"
            echo "  restart - 重启所有服务"
            echo "  status  - 检查服务状态"
            echo "  help    - 显示帮助信息"
            ;;
        *)
            log_error "未知命令: $1"
            echo "使用 '$0 help' 查看帮助信息"
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"
