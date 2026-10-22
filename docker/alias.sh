# docker 版: .bashrc / .zshrc から source する
#   [ -f ~/.config/nvim/docker/alias.sh ] && . ~/.config/nvim/docker/alias.sh

# source 時にこのファイルの場所を覚えておく (bash: BASH_SOURCE, zsh: $0)
_LVIM_ALIAS_SRC="${BASH_SOURCE[0]:-$0}"

# LazyVim Docker イメージのビルド (例: lvim-build --no-cache)
lvim-build() {
  local repo
  repo="$(cd "$(dirname "$_LVIM_ALIAS_SRC")/.." && pwd)"

  echo "Building lazyvim-sandbox with UID=$(id -u) GID=$(id -g)..."
  docker build \
    --build-arg USER_UID="$(id -u)" \
    --build-arg USER_GID="$(id -g)" \
    "$@" \
    -t lazyvim-sandbox \
    -f "$repo/docker/Dockerfile" \
    "$repo"
}

# ホストのクリップボードをコンテナへ中継する socat ブリッジ (2489: copy, 2490: paste)
if [[ "$OSTYPE" == "darwin"* ]]; then
  pgrep -f "TCP-LISTEN:2489" >/dev/null || (socat -u TCP-LISTEN:2489,fork,reuseaddr EXEC:"pbcopy" 2>/dev/null &)
  pgrep -f "TCP-LISTEN:2490" >/dev/null || (socat TCP-LISTEN:2490,fork,reuseaddr EXEC:"pbpaste" 2>/dev/null &)
elif grep -qi -e "microsoft" -e "wsl" /proc/version 2>/dev/null; then
  pgrep -f "TCP-LISTEN:2489" >/dev/null || (socat -u TCP-LISTEN:2489,fork,reuseaddr EXEC:"/mnt/c/Windows/System32/win32yank.exe -i --crlf" 2>/dev/null &)
  pgrep -f "TCP-LISTEN:2490" >/dev/null || (socat TCP-LISTEN:2490,fork,reuseaddr EXEC:"/mnt/c/Windows/System32/win32yank.exe -o --lf" 2>/dev/null &)
fi
