#!/usr/bin/env bash
# Meowrch NixOS Installer v3.5.5 - Full Functionality / Minimal Code
set -e

# 1. Environment & Logging
LOG_FILE="$(pwd)/install.log"
exec > >(tee -a "$LOG_FILE") 2>&1
trap 'echo -e "\n\033[0;31m[ERROR] Failed at line $LINENO. Check $LOG_FILE\033[0m"' ERR

# 2. Survey
echo "--- Meowrch Setup ---"
[ -d "/mnt/etc" ] && MODE="install" || MODE="rebuild"
read -p "Hostname [meowrch]: " HOSTNAME; HOSTNAME=${HOSTNAME:-meowrch}
read -p "Username [$USER]: " UNAME; UNAME=${UNAME:-$USER}
echo "GPU: 1) AMD  2) Intel  3) Nvidia"; read -p "> " GPU

# 3. Path Mapping (Based on your Repo Structure)
CONF_DIR="hosts/meowrch"
CONF_NIX="$CONF_DIR/configuration.nix"
USER_NIX="$CONF_DIR/user-local.nix"
HW_NIX="$CONF_DIR/hardware-configuration.nix"

# 4. Configuration Generation
echo "[*] Generating $USER_NIX..."
cat > "$USER_NIX" << EOF
{ meowrch.user = "$UNAME"; meowrch.hostname = "$HOSTNAME"; }
EOF

echo "[*] Patching GPU drivers..."
case "$GPU" in
    1) sed -i 's|.*# GPU_MODULE_LINE|      ../../modules/nixos/system/graphics-amd.nix # GPU_MODULE_LINE|' "$CONF_NIX" ;;
    2) sed -i 's|.*# GPU_MODULE_LINE|      ../../modules/nixos/system/graphics-intel.nix # GPU_MODULE_LINE|' "$CONF_NIX" ;;
    3) sed -i 's|.*# GPU_MODULE_LINE|      ../../modules/nixos/system/graphics-nvidia.nix # GPU_MODULE_LINE|' "$CONF_NIX" ;;
esac

echo "[*] Detecting hardware..."
if [ "$MODE" == "install" ]; then
    sudo nixos-generate-config --show-hardware-config --root /mnt > "$HW_NIX"
else
    sudo nixos-generate-config --show-hardware-config > "$HW_NIX"
fi

# 5. Git Staging (CRITICAL for Flakes to see files)
[ ! -d .git ] && git init -q
git add -A

# 6. Execution (Fixes Permission/Empty Config issues)
export NIXPKGS_ALLOW_UNFREE=1
echo "[*] Building Meowrch NixOS ($MODE)..."

if [ "$MODE" == "install" ]; then
    sudo -E nixos-install --flake ".#meowrch" --root /mnt --impure
else
    # -E prevents sudo from hijacking ~/.cache permissions
    sudo -E nixos-rebuild boot --flake ".#meowrch" --impure
    # Clean up any existing root-owned cache folders
    sudo chown -R "$USER":users "$HOME/.cache" 2>/dev/null || true
fi

echo -e "\n[+] Success! Reboot to enter Meowrch."
