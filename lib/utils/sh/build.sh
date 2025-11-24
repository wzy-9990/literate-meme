#!/bin/bash

set -e

# === 配置项 ===
API_KEY="649e6ec8e43ea014d8e148618745a7b6"
UPLOAD_URL="https://www.pgyer.com/apiv2/app/upload"
EXPORT_OPTIONS_PLIST="./sh/exportOptions.plist"
COMMON_API_FILE="../pinkala_design/lib/api/CommonApi.dart"
# 从 CommonApi.dart 里解析当前使用的 baseUrl 及其注释，便于上传备注
BASE_INFO=$(sed -n "s/^[[:space:]]*static const String baseUrl[[:space:]]*=[[:space:]]*'\\([^']*\\)'[[:space:]]*;[[:space:]]*\\/\\/\\s*\\(.*\\)$/\\1|\\2/p" "${COMMON_API_FILE}" 2>/dev/null | head -n1)
BASE_URL=${BASE_INFO%%|*}
BASE_LABEL=${BASE_INFO#*|}
if [ "$BASE_INFO" = "$BASE_LABEL" ]; then BASE_LABEL=""; fi
PGY_DESCRIPTION="后端接口地址: ${BASE_URL:-未读取到}"
if [ -n "$BASE_LABEL" ]; then
  PGY_DESCRIPTION="${PGY_DESCRIPTION} (${BASE_LABEL})"
fi
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)
if [ -n "$BRANCH" ]; then
  PGY_DESCRIPTION="${PGY_DESCRIPTION} | 前端代码分支: ${BRANCH}"
fi
echo "📎 蒲公英备注: ${PGY_DESCRIPTION}"

# === 参数解析 ===
BUILD_ANDROID=false
BUILD_IOS=false
AUTO_OPEN=false

# 如果没有参数，默认打包 Android 和 iOS
if [ $# -eq 0 ]; then
  BUILD_ANDROID=true
  BUILD_IOS=true
fi

for arg in "$@"; do
  case $arg in
    --apk)
      BUILD_ANDROID=true
      ;;
    --ipa)
      BUILD_IOS=true
      ;;
    --open)
      AUTO_OPEN=true
      ;;
    *)
      echo "❌ 未知参数: $arg"
      echo "用法: ./build_and_upload.sh [--apk] [--ipa] [--open]"
      exit 1
      ;;
  esac
done

if [ "$BUILD_ANDROID" = false ] && [ "$BUILD_IOS" = false ]; then
  echo "⚠️ 请输入参数: --apk 或 --ipa"
  exit 1
fi

# === 构建 Android ===
if [ "$BUILD_ANDROID" = true ]; then
  echo "📦 正在打包 Android..."
  flutter build apk --release || exit 1
  APK_PATH="./build/app/outputs/flutter-apk/app-release.apk"
  echo "📦 Android 打包完成: $APK_PATH"

  echo "🚀 开始上传到蒲公英..."

  response=$(curl --progress-bar --http1.1 \
    -F "file=@${APK_PATH}" \
    -F "_api_key=${API_KEY}" \
    --form-string "buildUpdateDescription=${PGY_DESCRIPTION}" \
    "$UPLOAD_URL")

  echo "📨 上传响应完成，正在解析响应..."

  success=$(echo "$response" | grep -o '"code":0')

  if [ "$success" != "" ]; then
    shortcut=$(echo "$response" | grep -o '"buildShortcutUrl":"[^"]*' | cut -d '"' -f4)
    build_key=$(echo "$response" | grep -o '"buildKey":"[^"]*' | cut -d '"' -f4)
    app_url="https://www.pgyer.com/${build_key}" # 固定使用 buildKey 对应的安装页
    download_url="https://www.pgyer.com/apiv2/app/install?_api_key=${API_KEY}&buildKey=${build_key}"
    echo "✅ Android 上传成功（最新版本）: $app_url"
    echo "✅ Android 下载链接（直接下载）: $download_url"
    
    if [ "$AUTO_OPEN" = true ]; then
      open "$app_url" 2>/dev/null || xdg-open "$app_url" || start "$app_url"
    fi
  else
    echo "❌ Android 上传失败！响应如下："
    echo "$response"
    exit 1
  fi
fi

# === 构建 iOS ===
if [ "$BUILD_IOS" = true ]; then
  echo "📦 正在打包 iOS（使用 flutter build ipa）..."

  flutter build ipa --export-options-plist="$EXPORT_OPTIONS_PLIST" || {
    echo "❌ 构建 IPA 失败"
    exit 1
  }

  IPA_PATH=$(find build/ios/ipa -type f -name "*.ipa" -exec stat -f "%m %N" {} \; | sort -rn | head -n1 | cut -d' ' -f2-)
  if [ ! -f "$IPA_PATH" ]; then
    echo "❌ 未找到 IPA 文件"
    exit 1
  fi
  echo "📦 iOS 打包完成: $IPA_PATH"

  # 如果路径不是英文名才复制
  IPA_ENGLISH_PATH="build/ios/ipa/app.ipa"
  if [ "$IPA_PATH" != "$IPA_ENGLISH_PATH" ]; then
    cp "$IPA_PATH" "$IPA_ENGLISH_PATH"
    IPA_UPLOAD_PATH="$IPA_ENGLISH_PATH"
  else
    IPA_UPLOAD_PATH="$IPA_PATH"
  fi

  echo "🚀 开始上传到蒲公英，可能需要几分钟..."

  response=$(curl --progress-bar --http1.1 \
    -F "file=@${IPA_UPLOAD_PATH}" \
    -F "_api_key=${API_KEY}" \
    --form-string "buildUpdateDescription=${PGY_DESCRIPTION}" \
    "$UPLOAD_URL")

  echo "📨 上传响应完成，正在解析响应..."

  success=$(echo "$response" | grep -o '"code":0')

  if [ "$success" != "" ]; then
    shortcut=$(echo "$response" | grep -o '"buildShortcutUrl":"[^"]*' | cut -d '"' -f4)
    build_key=$(echo "$response" | grep -o '"buildKey":"[^"]*' | cut -d '"' -f4)
    app_url="https://www.pgyer.com/${build_key}"
    download_url="https://www.pgyer.com/apiv2/app/install?_api_key=${API_KEY}&buildKey=${build_key}"

    echo "✅ iOS 上传成功: $app_url"
    echo "✅ iOS 下载链接: $download_url"
    
    if [ "$AUTO_OPEN" = true ]; then
      open "$app_url" 2>/dev/null || xdg-open "$app_url" || start "$app_url"
    fi
  else
    echo "❌ iOS 上传失败！响应如下："
    echo "$response"
    exit 1
  fi
fi
