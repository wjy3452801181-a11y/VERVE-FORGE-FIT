#!/bin/bash
# VerveForge 一键环境搭建脚本

set -e

echo "========================================="
echo "  VerveForge 环境搭建"
echo "========================================="

# 检查 Flutter
if ! command -v flutter &> /dev/null; then
    echo "错误：Flutter 未安装，请先安装 Flutter SDK"
    echo "https://docs.flutter.dev/get-started/install"
    exit 1
fi

echo "Flutter 版本："
flutter --version

# 安装依赖
echo ""
echo "正在安装 Flutter 依赖..."
flutter pub get

# 生成多语言文件
echo ""
echo "正在生成多语言文件..."
flutter gen-l10n

# 生成代码（freezed / json_serializable / riverpod_generator）
echo ""
echo "正在生成代码..."
dart run build_runner build --delete-conflicting-outputs

# 检查 .env 文件
if [ ! -f .env ]; then
    echo ""
    echo "警告：.env 文件不存在，正在从 .env.example 复制..."
    cp .env.example .env
    echo "请编辑 .env 文件填入你的 Supabase 配置"
fi

echo ""
echo "========================================="
echo "  环境搭建完成！"
echo "  运行 'flutter run' 启动应用"
echo "========================================="
