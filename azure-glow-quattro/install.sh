#!/bin/bash
# One-shot installer for the Azure Glow Quattro theme + Quattro lock plugin.
#
# Installs the Quattro lock plugin (~/.config/omarchy/plugins/quattro.lock),
# makes it the only active lock service, applies the theme, and syncs the
# Plymouth/SDDM boot + login screens to the blue azure glow palette.
#
# Safe to run directly from a clone or after unpacking the exportable zip.
# On a fresh machine: opencode should `bash install.sh` from the unzipped
# theme directory.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_SRC="$REPO_DIR/quattro-lock"
PLUGINS_DIR="$HOME/.config/omarchy/plugins"
THEME_NAME="azure-glow-quattro"

command -v jq >/dev/null || { echo "install.sh: jq is required"; exit 1; }
[[ -f "$PLUGIN_SRC/manifest.json" ]] || { echo "install.sh: quattro-lock/ not found next to install.sh"; exit 1; }

PLUGIN_ID=$(jq -r '.id' "$PLUGIN_SRC/manifest.json")

echo "==> Installing $PLUGIN_ID lock plugin"
if [[ -e "$PLUGINS_DIR/$PLUGIN_ID" ]]; then
  echo "    already installed; leaving it in place"
else
  mkdir -p "$PLUGINS_DIR"
  cp -r "$PLUGIN_SRC" "$PLUGINS_DIR/$PLUGIN_ID"
fi

echo "==> Ensuring $PLUGIN_ID is the only active lock service"
for id in $(omarchy plugin list --json 2>/dev/null | jq -r '.[] | select(.enabled == true) | .id' | grep -E "\.lock$"); do
  if [[ $id != "$PLUGIN_ID" ]]; then
    echo "    disabling $id"
    omarchy plugin disable "$id" >/dev/null 2>&1 || true
  fi
done
omarchy plugin enable "$PLUGIN_ID" >/dev/null 2>&1 || true

echo "==> Applying $THEME_NAME theme"
omarchy theme set "$THEME_NAME"

echo "==> Syncing blue boot/login screen (Plymouth + SDDM)"
if omarchy plymouth current >/dev/null 2>&1; then
  sudo omarchy plymouth set-by-theme "$THEME_NAME" || echo "    (skipped — run manually: omarchy plymouth set-by-theme $THEME_NAME)"
else
  echo "    (Plymouth command unavailable; skipping)"
fi

echo "==> Pinning the blue boot logo so boot-time migrations keep it"
DEFAULT_PLYMOUTH="/usr/share/omarchy/default/plymouth"
if [[ -f "$REPO_DIR/unlock.png" ]] && [[ -d "$DEFAULT_PLYMOUTH" ]]; then
  sudo cp "$REPO_DIR/unlock.png" "$DEFAULT_PLYMOUTH/logo.png" || \
    echo "    (could not write $DEFAULT_PLYMOUTH/logo.png)"
  sudo cp "$REPO_DIR/unlock.png" /usr/share/plymouth/themes/omarchy/logo.png || \
    echo "    (could not write /usr/share/plymouth/themes/omarchy/logo.png)"
else
  echo "    (theme unlock.png or default plymouth dir not found; skipping)"
fi

echo "==> Forcing the browser color to pure black (persistent)"
mkdir -p "$HOME/.config/omarchy/hooks/theme-set.d"
cat > "$HOME/.config/omarchy/hooks/theme-set.d/browser-black.sh" <<'EOF'
#!/bin/bash
sudo omarchy-theme-set-browser-policy 000000
EOF
chmod +x "$HOME/.config/omarchy/hooks/theme-set.d/browser-black.sh"
if sudo -n /usr/bin/omarchy-theme-set-browser-policy 000000 >/dev/null 2>&1; then
  echo "    browser policy set to black"
else
  echo "    (running with sudo instead)"
  sudo omarchy-theme-set-browser-policy 000000 || echo "    (could not set; run manually: sudo omarchy-theme-set-browser-policy 000000)"
fi

echo
echo "Done. Lock the screen (Super+Shift+L) to see the Quattro unlock view."
echo "Reboot for the blue boot logo to take effect."
