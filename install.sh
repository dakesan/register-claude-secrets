#!/bin/bash

# register-claude-secretsのインストールスクリプト

set -e

# インストール先
INSTALL_DIR="$HOME/.local/bin"
SCRIPT_NAME="register-claude-secrets"
SCRIPT_PATH="$(pwd)/register-claude-secrets.sh"

# 色付き出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# .local/binディレクトリが存在しない場合は作成
if [ ! -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}Creating $INSTALL_DIR directory...${NC}"
    mkdir -p "$INSTALL_DIR"
fi

# スクリプトが存在するか確認
if [ ! -f "$SCRIPT_PATH" ]; then
    echo -e "${RED}Error: register-claude-secrets.sh not found in current directory${NC}"
    exit 1
fi

# 既存のファイルがある場合は確認
if [ -f "$INSTALL_DIR/$SCRIPT_NAME" ]; then
    echo -e "${YELLOW}$SCRIPT_NAME already exists in $INSTALL_DIR${NC}"
    read -p "Overwrite? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled"
        exit 0
    fi
fi

# スクリプトをコピー
echo -e "${GREEN}Installing $SCRIPT_NAME to $INSTALL_DIR...${NC}"
cp "$SCRIPT_PATH" "$INSTALL_DIR/$SCRIPT_NAME"
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

# PATHの確認
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo -e "${YELLOW}Note: $INSTALL_DIR is not in your PATH${NC}"
    echo "Add the following line to your ~/.bashrc or ~/.zshrc:"
    echo -e "${GREEN}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
fi

echo -e "${GREEN}✅ Installation complete!${NC}"
echo ""
echo "Usage: $SCRIPT_NAME -r <owner/repo>"