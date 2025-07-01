#!/usr/bin/env bash
# depth_counts.sh: 统计 1×…10× 覆盖 CpG 数目及占总 CpG (58607920) 的比例

file="$1"
total=58607920

# 选择解压或直接读取
if [[ "$file" == *.gz ]]; then
  reader="zcat"
else
  reader="cat"
fi

$reader "$file" | \
awk -v TOTAL="$total" '
  BEGIN {
    # 初始化 1…10 桶
    for (i = 1; i <= 10; i++) count[i] = 0
  }
  # 跳过注释行
  /^#/ || /^browser/ || /^track/ { next }
  {
    # 计算当前行 depth
    depth = $3 + $4
    # depth >= i 则累加 count[i]
    for (i = 1; i <= 10; i++) {
      if (depth >= i) count[i]++
    }
  }
  END {
    # 输出表头
    printf "Depth\tCpGs\tProportion_of_total_CpG\n"
    # 按 1…10 输出覆盖数及比例
    for (i = 1; i <= 10; i++) {
      prop = count[i] / TOTAL
      # 比例保留四位小数
      printf "%2d×\t%d\t%.4f\n", i, count[i], prop
    }
  }
'
