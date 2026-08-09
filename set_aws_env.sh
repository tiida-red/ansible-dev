#!/bin/bash

# 直前のシェル環境に反映させるため、source 実行されているかチェック
if [ "$0" = "$BASH_SOURCE" ]; then
    echo "【警告】環境変数を現在のターミナルに反映させるため、"
    echo "以下のように 'source' を付けて実行してください:"
    echo "  source $0"
    echo "--------------------------------------------------"
fi

echo "=== AWS Credential 環境変数設定スクリプト ==="

# 1. AWS Access Key ID の入力
read -rp "AWS Access Key ID を入力してください: " input_access_key
if [ -n "$input_access_key" ]; then
    export AWS_ACCESS_KEY_ID="$input_access_key"
fi

# 2. AWS Secret Access Key の入力（入力文字を非表示にするため -s を使用）
read -rsp "AWS Secret Access Key を入力してください: " input_secret_key
echo "" # 改行
if [ -n "$input_secret_key" ]; then
    export AWS_SECRET_ACCESS_KEY="$input_secret_key"
fi

# 3. AWS Default Region の入力（未入力の場合は ap-northeast-1 をデフォルト設定）
read -rp "AWS Default Region [既定値: ap-northeast-1]: " input_region
if [ -z "$input_region" ]; then
    export AWS_DEFAULT_REGION="ap-northeast-1"
    export AWS_REGION="ap-northeast-1"
else
    export AWS_DEFAULT_REGION="$input_region"
    export AWS_REGION="$input_region"
fi

echo "--------------------------------------------------"
echo "設定が完了しました！"
echo "AWS_ACCESS_KEY_ID:     ${AWS_ACCESS_KEY_ID:0:5}*****" # 一部マスク表示
echo "AWS_SECRET_ACCESS_KEY: ********"
echo "AWS_DEFAULT_REGION:    $AWS_DEFAULT_REGION"
echo "--------------------------------------------------"