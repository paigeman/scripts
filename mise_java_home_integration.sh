#!/bin/bash

# ==========================================
# Mise Java -> macOS System Integration Tool
# ==========================================
#
# Based on mise documentation:
# https://mise.jdx.dev/lang/java.html
#
# Note: Not all distributions support this integration (e.g. liberica)
# ==========================================

# 1. 检查 mise 是否存在
if ! command -v mise &> /dev/null; then
    echo "❌ 错误: 未找到 mise 命令，请确保已安装并添加到 PATH。"
    exit 1
fi

# 2. 获取当前 Mise 激活的 Java 信息
# 获取当前激活的版本号 (例如: openjdk-21)
JAVA_VERSION_NAME=$(mise current java 2>/dev/null | awk '{print $1}')
# 获取该版本的绝对安装路径
JAVA_INSTALL_PATH=$(mise where java 2>/dev/null)

if [ -z "$JAVA_INSTALL_PATH" ]; then
    echo "❌ 错误: 当前目录没有激活任何 Mise Java 版本。"
    echo "💡 请先执行: mise use java@21 (或你想要的版本)"
    exit 1
fi

# 额外验证：确保版本名称有效
if [ -z "$JAVA_VERSION_NAME" ]; then
    echo "❌ 错误: 无法获取 Java 版本名称。"
    exit 1
fi

# 3. 定义目标路径 (遵循 mise 官方文档的命名方式，不加前缀)
TARGET_DIR="/Library/Java/JavaVirtualMachines/${JAVA_VERSION_NAME}.jdk"

# ==========================================
# 功能函数
# ==========================================

function do_link() {
    echo "🔍 检测当前 Java: $JAVA_VERSION_NAME"
    echo "📂 源路径: $JAVA_INSTALL_PATH"

    # --- 核心检查：源 JDK 是否有 Contents 目录 ---
    if [ ! -d "$JAVA_INSTALL_PATH/Contents" ]; then
        echo "⚠️  警告: 该 JDK 版本不包含标准的 macOS 'Contents' 目录结构。"
        echo "🚫 这是一个非 macOS 标准构建 (可能是 Linux 版)，无法直接链接到系统。"
        echo "🧹 无需清理，操作已取消。"
        exit 1
    fi

    # 检查目标是否已存在
    if [ -d "$TARGET_DIR" ]; then
        echo "⚠️  目标已存在: $TARGET_DIR"
        read -p "是否覆盖？(y/n): " confirm
        # 使用 tr 转换为小写以兼容旧版 Bash (macOS 默认 Bash 3.2)
        if [[ $(echo "$confirm" | tr '[:upper:]' '[:lower:]') != "y" ]]; then exit 0; fi

        if ! sudo rm -rf "$TARGET_DIR"; then
            echo "❌ 删除旧目录失败，请检查权限。"
            exit 1
        fi
    fi

    echo "🚀 开始链接..."

    # 按照官方文档方式创建目录和链接
    # 使用 && 确保如果 mkdir 成功但 ln 失败时能正确清理
    if sudo mkdir "$TARGET_DIR" && sudo ln -s "$JAVA_INSTALL_PATH/Contents" "$TARGET_DIR/Contents"; then
        echo "✅ 链接创建成功！"
        echo "🔗 映射关系: $TARGET_DIR/Contents -> $JAVA_INSTALL_PATH/Contents"

        # 验证链接是否指向预期的源路径
        # 使用 realpath 规范化路径进行比较（处理可能的相对路径问题）
        REAL_LINK_TARGET=$(realpath "$TARGET_DIR/Contents" 2>/dev/null)
        EXPECTED_TARGET=$(realpath "$JAVA_INSTALL_PATH/Contents" 2>/dev/null)

        # 如果 realpath 不可用或失败，直接比较 readlink 的结果
        if [ -z "$REAL_LINK_TARGET" ] || [ -z "$EXPECTED_TARGET" ]; then
            REAL_LINK_TARGET=$(readlink "$TARGET_DIR/Contents")
            EXPECTED_TARGET="$JAVA_INSTALL_PATH/Contents"
        fi

        if [ "$REAL_LINK_TARGET" != "$EXPECTED_TARGET" ]; then
            echo "❌ 链接目标不匹配！"
            echo "   预期: $EXPECTED_TARGET"
            echo "   实际: $REAL_LINK_TARGET"
            echo "🧹 正在执行清理工作..."
            sudo rm -rf "$TARGET_DIR"
            echo "✅ 清理完成。"
            exit 1
        fi

        # 验证 macOS 是否真正识别到该 JDK
        echo "------------------------------------------------"
        echo "🔎 正在验证 macOS 是否识别此 JDK..."
        # 检查目标目录是否出现在 java_home 的输出中
        # 使用 -Fi 进行不区分大小写的固定字符串匹配
        if /usr/libexec/java_home -V 2>&1 | grep -Fiq "${JAVA_VERSION_NAME}.jdk"; then
            echo "✅ macOS 已成功识别该 JDK！"
            echo "------------------------------------------------"
            echo ""
            echo "💡 使用以下命令查看所有可用的 Java 版本:"
            echo "   /usr/libexec/java_home -V"
        else
            echo "⚠️  macOS 未能识别此 JDK。"
            echo ""
            echo "📚 这通常意味着该发行版不支持与 macOS 系统集成。"
            echo "💡 常见不支持的发行版包括: liberica 等"
            echo ""
            read -p "是否保留链接继续尝试？(y/n): " keep_link
            # 使用 tr 转换为小写以兼容旧版 Bash (macOS 默认 Bash 3.2)
            if [[ $(echo "$keep_link" | tr '[:upper:]' '[:lower:]') != "y" ]]; then
                echo "🧹 正在执行清理工作..."
                sudo rm -rf "$TARGET_DIR"
                echo "✅ 清理完成。"
                exit 1
            fi
        fi
        echo "------------------------------------------------"
    else
        echo "❌ 链接命令执行失败！"
        echo "🧹 正在执行清理工作 (删除空目录)..."
        sudo rm -rf "$TARGET_DIR"
        echo "✅ 清理完成。"
        exit 1
    fi
}

function do_unlink() {
    echo "🗑  准备移除系统映射: $TARGET_DIR"
    
    if [ ! -d "$TARGET_DIR" ]; then
        echo "⚠️  该路径不存在，可能未链接过: $TARGET_DIR"
        exit 0
    fi

    sudo rm -rf "$TARGET_DIR"
    echo "✅ 已移除链接。原 Mise 文件保留，仅断开系统集成。"
}

# ==========================================
# 主逻辑
# ==========================================

ACTION=$1

case "$ACTION" in
    link)
        do_link
        ;;
    unlink)
        do_unlink
        ;;
    *)
        echo "用法: $0 [link | unlink]"
        echo ""
        echo "  link   : 将当前 Mise Java 链接到 macOS 系统目录"
        echo "  unlink : 取消当前 Mise Java 的系统链接"
        echo ""
        echo "当前检测到的版本: $JAVA_VERSION_NAME"
        exit 1
        ;;
esac