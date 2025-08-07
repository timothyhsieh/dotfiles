#!/bin/bash

# The .oh-my-zsh can be overwritten as a clean directory in a codespace rather
# the retain the symlink to the dotfiles repository. This fixes that if
# needed.

# Define paths
ORIG="$HOME/.oh-my-zsh"
TARGET="/workspaces/.codespaces/.persistedshare/dotfiles/.oh-my-zsh"
P10K_RELATIVE_PATH="custom/themes/powerlevel10k"

# Check if ~/.oh-my-zsh is a symlink
if [ ! -L "$ORIG" ]; then
  echo "🔍 ~/.oh-my-zsh is not a symlink."

  # Save original directory
  TEMP="${HOME}/.oh-my-zsh.bak.$(date +%s)"
  echo "📦 Backing up existing ~/.oh-my-zsh to $TEMP"
  mv "$ORIG" "$TEMP"

  # Create symlink
  echo "🔗 Creating symlink: $ORIG → $TARGET"
  ln -s "$TARGET" "$ORIG"

  # Migrate powerlevel10k if it existed in backup
  OLD_P10K="$TEMP/$P10K_RELATIVE_PATH"
  NEW_P10K="$ORIG/$P10K_RELATIVE_PATH"

  if [ -d "$OLD_P10K" ]; then
    if [ -d "$NEW_P10K" ] && [ -z "$(ls -A "$NEW_P10K")" ]; then
      echo "🚚 Overwriting empty $NEW_P10K with contents from backup"
      rm -rf "$NEW_P10K"
      mv "$OLD_P10K" "$NEW_P10K"
    elif [ -d "$NEW_P10K" ]; then
      echo "⚠️ $NEW_P10K exists and is not empty — skipping move"
    else
      echo "🚚 Moving $OLD_P10K → $NEW_P10K"
      mkdir -p "$(dirname "$NEW_P10K")"
      mv "$OLD_P10K" "$NEW_P10K"
    fi
  else
    echo "ℹ️ No powerlevel10k theme found in backup"
  fi

  # Reload Zsh config
  echo "🔄 Sourcing ~/.zshrc"
  zsh - c "source ~/.zshrc"

else
  echo "✅ ~/.oh-my-zsh is already a symlink — no changes made."
fi
