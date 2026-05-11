#!/usr/bin/env bash
# Carrega variáveis de .env (se existir) e inicia o bot.
# Uso: cp .env.example .env  # edita .env com o token
#       ./run.sh
set -euo pipefail
cd "$(dirname "$0")"

# GUIas / scripts duplos clicados não herdam o PATH do Terminal (Homebrew, asdf, mise).
export PATH="$HOME/.local/share/mise/shims:/opt/homebrew/bin:/usr/local/bin:$PATH"
if [[ -f "${ASDF_DIR:-$HOME/.asdf}/asdf.sh" ]]; then
  # shellcheck disable=SC1090
  source "${ASDF_DIR:-$HOME/.asdf}/asdf.sh"
fi
if [[ -f "$HOME/.local/bin/env" ]]; then
  # shellcheck disable=SC1091
  source "$HOME/.local/bin/env"
fi

if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

if ! command -v mix >/dev/null 2>&1; then
  echo "Erro: 'mix' não encontrado no PATH." >&2
  echo "Instala Elixir (https://elixir-lang.org/install.html) ou abre o Terminal," >&2
  echo "garante que 'mix' funciona com 'mix --version', e volta a correr ./run.sh" >&2
  exit 127
fi

exec mix run --no-halt "$@"
