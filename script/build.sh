#!/bin/bash

# 配置文件路径
config_file="version.json"
input_platform="2"
input_version=0

# Get Version
get_version() {
  local platform="$1"
  local input_version=$(jq -r ".[\"$platform\"].version" "$config_file")

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
          '(.["'$platform'"] = {version: $version, buildTime: $build_time})' "$config_file" > temp.json && mv temp.json "$config_file"
}

options=("apk(Android)" "app-bundle(Google Play)" "ipa(Ios Store)")
echo "Select Build Platform:"
for ((i=0; i<${#options[@]}; i++)); do
  echo "  $((i+1)). ${options[$i]}"
done

read -p "Build Platform(1/2/3..): " input_platform
read -p "Build Number: " input_version
if [[ $input_platform == 3 ]];
  then
    read -p "Is Reset Version (y/n): " input_is_reset_version_main
    echo "(hint): 当大版本更新时，将需要重置build-number"
fi

if [[ -z $input_platform ]];
  then
    default_platform=2
    echo "            -> Default Platform ($default_platform)"
    platform=$default_platform
  else
    platform=$input_platform
fi
if [[ $input_is_reset_version_main == 'y' ]];
  then
    # yes reset
    input_version=1
    version=1
    echo "            -> Reset Version ($version)"
  else
    # no
    if [[ -z $input_version ]];
      then
        # 获取当前平台的版本号
        version=$(get_version "$platform")
        echo "            -> Auto Version ($version)"
      else
        version=$input_version
    fi
fi

echo "===================== start build ====================="

# 构建命令
case "$platform" in
  1)
    echo "正在构建$platform..."
    flutter build apk lib/main.prod.dart --release --build-number "$version"
    ;;
  2)
    flutter build appbundle lib/main.prod.dart --release --build-number "$version" --target-platform android-arm,android-arm64,android-x64
    ;;
  3)
    flutter build ipa lib/main.prod.dart --release --build-number "$version"
    ;;
  *)
    echo "不支持的平台: $platform"
    exit 1
    ;;
esac

echo "===================== end build ====================="

# 是否递增版本号
if [[ $input_is_reset_version_main == 'n' ]]; then
    new_version=$((version + 1))
  else
    new_version=$version
fi
set_version "$platform" "$new_version"
echo "Updata build-number: $new_version"
echo "END 👋🏻👋🏻"