#!/bin/bash
curl -L -o voices.json https://huggingface.co/rhasspy/piper-voices/resolve/main/voices.json
echo "The Support Models of en, ja, zh:"
jq -r 'keys[] | select(test("^(en|ja|zh)"))' voices.json
echo "Start to Download Models:"
# -r 防止反斜杠转义
while read -r line || [ -n "$line" ]; do
    # 1. 跳过空行或以 # 开头的注释行（增强脚本健壮性）
    [[ -z "$line" || "$line" =~ ^# ]] && continue

    # 2. 核心拆分：使用短横线 - 拆出前三个部分
    IFS='-' read -r locale voice quality <<< "$line"
    
    # 3. 进一步提取语言前缀（去掉下划线 _ 及其后面的部分）
    lang="${locale%%_*}"

    # 4. 此时 4 个参数完全独立
    echo "----------------------------------------"
    echo "lang   : $lang"
    echo "locale : $locale"
    echo "voice  : $voice"
    echo "quality: $quality"
    opengate-download-models --short-lang "$lang" --lang "$locale" --name "$voice" --size "$quality"
done < $1
echo "----------------------------------------"