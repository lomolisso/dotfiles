#!/usr/bin/env bash
# NVIDIA GPU load (`gpu.sh util`) or VRAM use (`gpu.sh vram`) for waybar. Without an
# NVIDIA GPU it prints nothing and fails, which hides the module.
command -v nvidia-smi >/dev/null || exit 1
IFS=', ' read -r util used total < <(nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total --format=csv,noheader,nounits 2>/dev/null)
[[ ${total:-} =~ ^[0-9]+$ && $total -gt 0 ]] || exit 1
case "$1" in
  util) printf '<span color="#8c1625">gpu</span> %02d%%\n' "$util" ;;
  vram) printf '<span color="#8c1625">vram</span> %02d%%\n' $((used * 100 / total)) ;;
esac
