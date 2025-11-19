#!/bin/bash

# Git Hooks 安装脚本
# 用于安装 Lefthook 并设置 pre-commit hooks

set -e

echo "================================================"
echo "正在设置 Git Hooks 和代码规范检查..."
echo "================================================"
echo ""

# 检测操作系统
OS="$(uname -s)"
case "${OS}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    *)          MACHINE="UNKNOWN:${OS}"
esac

echo "检测到操作系统: $MACHINE"
echo ""

# 安装 Lefthook
install_lefthook() {
    if command -v lefthook &> /dev/null; then
        echo "✓ Lefthook 已安装 ($(lefthook version))"
        return 0
    fi

    echo "正在安装 Lefthook..."

    case "${MACHINE}" in
        Mac)
            if command -v brew &> /dev/null; then
                echo "使用 Homebrew 安装..."
                brew install lefthook
            else
                echo "使用 curl 安装..."
                curl -1sLf 'https://dl.cloudsmith.io/public/evilmartians/lefthook/setup.rpm.sh' | sudo -E bash
                brew install lefthook
            fi
            ;;
        Linux)
            # 使用 curl 下载二进制文件
            echo "下载 Lefthook 二进制文件..."
            LEFTHOOK_VERSION="1.6.1"
            ARCH="$(uname -m)"
            if [ "$ARCH" = "x86_64" ]; then
                ARCH="amd64"
            elif [ "$ARCH" = "aarch64" ]; then
                ARCH="arm64"
            fi

            DOWNLOAD_URL="https://github.com/evilmartians/lefthook/releases/download/v${LEFTHOOK_VERSION}/lefthook_${LEFTHOOK_VERSION}_Linux_${ARCH}"

            curl -L -o /tmp/lefthook "$DOWNLOAD_URL"
            chmod +x /tmp/lefthook
            sudo mv /tmp/lefthook /usr/local/bin/lefthook
            ;;
        *)
            echo "❌ 不支持的操作系统: ${MACHINE}"
            echo "请手动安装 Lefthook: https://github.com/evilmartians/lefthook#install"
            exit 1
            ;;
    esac

    if command -v lefthook &> /dev/null; then
        echo "✓ Lefthook 安装成功 ($(lefthook version))"
    else
        echo "❌ Lefthook 安装失败"
        exit 1
    fi
}

# 安装 Lefthook
install_lefthook

echo ""
echo "正在初始化 Lefthook..."

# 进入项目根目录
cd "$(dirname "$0")/.."

# 安装 Git hooks
lefthook install

echo ""
echo "================================================"
echo "✓ Git Hooks 设置完成！"
echo "================================================"
echo ""
echo "现在每次提交代码时会自动："
echo "  1. 格式化代码 (dart format)"
echo "  2. 检查代码规范 (flutter analyze)"
echo "  3. 检查是否有冲突标记"
echo ""
echo "如需跳过检查，使用: git commit --no-verify"
echo ""
