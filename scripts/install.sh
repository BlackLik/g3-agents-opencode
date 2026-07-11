#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

OPENCODE_FILES="flow.md subflow.md player.md coach.md"
CLAUDE_FILES="flow.md player.md coach.md"

usage() {
  echo "Usage: $0 <opencode|claude|all> [--global|--local]" >&2
  exit 1
}

[ $# -ge 1 ] || usage
tool="$1"
target="${2:---global}"
case "$tool" in opencode|claude|all) ;; *) usage ;; esac
case "$target" in --global|--local) ;; *) usage ;; esac

install_one() {
  local src="$1" dest="$2" files="$3" f
  mkdir -p "$dest"
  if [ "$(cd "$src" && pwd)" = "$(cd "$dest" && pwd)" ]; then
    echo "skip: $src == $dest"
    return
  fi
  for f in $files; do
    cp "$src/$f" "$dest/$f"
  done
  echo "installed: $dest"
}

if [ "$tool" = "opencode" ] || [ "$tool" = "all" ]; then
  [ "$target" = "--global" ] && dest="$HOME/.config/opencode/agents" || dest="./.opencode/agents"
  install_one "$REPO_ROOT/.opencode/agents" "$dest" "$OPENCODE_FILES"
fi

if [ "$tool" = "claude" ] || [ "$tool" = "all" ]; then
  [ "$target" = "--global" ] && dest="$HOME/.claude/agents" || dest="./.claude/agents"
  install_one "$REPO_ROOT/.claude/agents" "$dest" "$CLAUDE_FILES"
fi
