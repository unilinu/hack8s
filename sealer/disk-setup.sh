#!/bin/bash
# 设置日志函数
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# 挂盘
setup_disk() {
    local disk="$1"

    # 检查磁盘是否存在
    if [ ! -e "$disk" ]; then
        log "Error: Disk $disk does not exist."
        exit 1
    fi

    log "Starting disk setup：$disk"

    # 进入 parted 配置模式
    parted "$disk" --script \
        mklabel gpt \
        mkpart primary xfs 0% 100%

    if [ $? -ne 0 ]; then
        log "Error: Partition operation failed"
        exit 1
    fi

    log "Partition successful：$disk"

    # 创建 LVM 卷组和逻辑卷
    sleep 5
    vgcreate vg1 "$disk"1 -y
    if [ $? -ne 0 ]; then
        log "Error: Failed to create volume group."
        exit 1
    fi

    lvcreate -l 100%FREE -n lv_apps vg1
    if [ $? -ne 0 ]; then
        log "Error:  Failed to create logical volume"
        exit 1
    fi

    log "LVM configuration successful."

    # 格式化逻辑卷
    mkfs.xfs /dev/vg1/lv_apps
    if [ $? -ne 0 ]; then
        log "Error: Failed to format logical volume"
        exit 1
    fi

    log "Formatting successful"

    # 挂载到 /apps
    echo '/dev/mapper/vg1-lv_apps /apps xfs defaults 0 0' >> /etc/fstab
    mkdir -p /apps
    mount -a
    if [ $? -ne 0 ]; then
        log "Error: Mount failed"
        exit 1
    fi

    log "Mount successful：/apps"
}

# 检查挂盘状态
check_disk() {
    log "Checking disk mount status：/apps"
    df -h /apps
}

source_dir="/etcd_data/etcd"
target_dir="/apps/data"

# 创建软连接
setup_symlink() {
    # 检查源目录是否存在
    if [ ! -d "$source_dir" ]; then
        log "Source directory $source_dir does not exist, creating"
        mkdir -p "$source_dir"
        if [ $? -ne 0 ]; then
            log "Error: Failed to create source directory $source_dir"
            exit 1
        fi
        chmod -R 777 "$source_dir"
        log "Source directory $source_dir created successfully"
    else
        log "Source directory $source_dir already exists"
    fi

    # 检查目标目录是否存在
    if [ ! -d "$target_dir" ]; then
        log "Target directory $target_dir does not exist, creating"
        mkdir -p "$target_dir"
        if [ $? -ne 0 ]; then
            log "Error: Failed to create target directory $target_dir"
            exit 1
        fi
        chmod -R 777 "$target_dir"
        log "Target directory $target_dir created successfully"
    else
        log "Target directory $target_dir already exists"
    fi

    # 检查目标是否是一个软连接
    if [ -L "$target_dir" ]; then
        log "Target $target_dir is already a symlink"
        exit 0
    fi

    # 创建软连接
    ln -s "$source_dir" "$target_dir/etcd"
    if [ $? -ne 0 ]; then
        log "Error: Failed to create symlink $target_dir -> $source_dir "
        exit 1
    fi

    log "Symlink created successfully：$target_dir -> $source_dir"
}

# 检查软连接状态
check_symlink() {
    log "Checking symlink status：$target_dir/etcd -> $source_dir"
    ls -l "$target_dir/etcd"
    ls -l "$source_dir"
}

# 取消软连接
remove_symlink() {
    log "Removing symlink：$target_dir"
    unlink "$target_dir/etcd"
    if [ $? -ne 0 ]; then
        log "Error: ailed to remove symlink, error code：$?"
        exit 1
    fi

    # 删除目录
    if [ -d "$source_dir" ]; then
        log "Removing directory：$source_dir"
        rm -rf "$source_dir"
        if [ $? -ne 0 ]; then
            log "Error: Failed to remove directory"
            exit 1
        fi
    fi

    log "Symlink removed：$target_dir/etcd"
}

# 主函数
main() {
    if [ $# -eq 0 ]; then
        log "Error: Please provide an operation parameter"
        echo "Usage: $0 <setup|check|symlink|remove> [parameter]"
        exit 1
    fi

    case "$1" in
        setup)
            if [ $# -ne 2 ]; then
                log "Error: setup requires a disk path parameter"
                exit 1
            fi
            setup_disk "$2"
            ;;
        check)
            check_disk
            ;;
        symlink)
            setup_symlink
            check_symlink
            ;;
        remove)
            remove_symlink
            ;;
        *)
            log "Error: Invalid operation parameter"
            echo "Usage: $0 <setup|check|symlink|remove> [parameter]"
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"
