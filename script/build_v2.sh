#!/bin/bash

PATH="$PATH":"$HOME/.pub-cache/bin"
CONFIG_FILE="version.json"

# Get Version
get_version() {
  local platform="$1"
  local input_version=$(jq -r ".[\"$platform\"].number" "$CONFIG_FILE")

  # 如果配置文件不存在或版本号为空，则初始化为1
  if [[ -z "$input_version" ]]; then
    input_version=0
  fi

  echo "$input_version"
}

# Updata version
set_version() {
  local platform="$1"
  local version="$2"
  local build_time=$(date +%s)

  jq --argjson platform "\"$platform\"" --argjson version "$version" --argjson build_time "$build_time" \
          '(.["'$platform'"] = {number: $version, buildTime: $build_time})' "$CONFIG_FILE" > temp.json && mv temp.json "$CONFIG_FILE"
}

options=("apk(Android)" "app-bundle(Google Play)" "ipa(Ios Store)")
echo "Select Build Platform:"
for ((i=0; i<${#options[@]}; i++)); do
  echo "  $((i+1)). ${options[$i]}"
done

read -p "Build Platform(1/2/3..): " input_platform
read -p "Is Skip Clean (y/n): " is_skip_clean

platform=$input_platform

echo "===================== start build ====================="

# Build Main
echo "正在构建 ${options[$($platform)]} ..."
skip_clean=''
if [[ $is_skip_clean == 'y' ]]; then
  skip_clean='--skip-clean'
fi
case "$platform" in
  1)
    flutter_distributor release --name android $skip_clean
    ;;
  2)
    flutter_distributor release --name android $skip_clean
    ;;
  3)
    flutter_distributor release --name ios $skip_clean
    ;;
  *)
    echo "不支持的平台: $platform"
    exit 1
    ;;
esac

echo "===================== end build ====================="

echo "END 👋🏻👋🏻"