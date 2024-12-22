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
read -p "Is Custom build-number (y/n): " is_custom_build_number
if [[ $is_custom_build_number == 'y' ]]; then
    read -p "Build Number: " input_version
fi
read -p "Is Skip Clean (y/n): " is_skip_clean
if [[ $input_platform == 3 ]];
  then
    read -p "Is Reset Build Number (y/n): " input_is_reset_version_main
    echo "(hint): 当大版本更新时，将需要重置build-number"
fi
if [[ -z $input_platform ]];
  then
    default_platform=1
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
        # 自定义build number
        version=$input_version
        echo "            -> Custom Version ($version)"
    fi
fi

echo "===================== start build ====================="

# Build Main
echo "正在构建 ${options[$($platform - 1)]} ..."
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

# 是否递增版本号
if [[ $input_is_reset_version_main == 'n' ]]; then
    new_number_version=$((version + 1))
  else
    new_number_version=$version
fi
set_version "$platform" "$new_number_version"

echo "Updata next build-number: $new_number_version"
echo "END 👋🏻👋🏻"